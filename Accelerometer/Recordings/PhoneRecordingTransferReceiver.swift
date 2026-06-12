//
//  PhoneRecordingTransferReceiver.swift
//  Accelerometer
//
//  Created by OpenAI on 07.06.2026.
//

import CryptoKit
import Foundation
import WatchConnectivity

final class PhoneRecordingTransferReceiver: NSObject, WCSessionDelegate, @unchecked Sendable {
    var onRecordingReceived: (@Sendable (Data, String?) -> Void)?

    private let session: WCSession?
    private let processingQueue = DispatchQueue(
        label: "com.panandafog.Accelerometer.watch-transfer"
    )
    private var deliveringTransferIDs: Set<String> = []
    private var statusCheckTokens: [String: UUID] = [:]

    override init() {
        if WCSession.isSupported() {
            session = .default
        } else {
            session = nil
        }

        super.init()
        session?.delegate = self
    }

    func activate() {
        session?.activate()
        processingQueue.async { [weak self] in
            self?.removeStaleTransfers()
            self?.resumePendingTransfers()
        }
    }

    func acknowledge(recordingID: String, transferID: String?) {
        guard let transferID else {
            sendAcknowledgement(recordingID: recordingID, transferID: nil)
            return
        }

        processingQueue.async { [weak self] in
            guard let self else {
                return
            }

            var acknowledgedTransfers = self.acknowledgedTransfers
            acknowledgedTransfers[transferID] = Date().timeIntervalSince1970
            self.acknowledgedTransfers = acknowledgedTransfers
            var acknowledgedRecordingIDs = self.acknowledgedRecordingIDs
            acknowledgedRecordingIDs[transferID] = recordingID
            self.acknowledgedRecordingIDs = acknowledgedRecordingIDs
            self.sendAcknowledgement(recordingID: recordingID, transferID: transferID)
            self.deliveringTransferIDs.remove(transferID)
            self.statusCheckTokens.removeValue(forKey: transferID)
            try? FileManager.default.removeItem(
                at: Self.transferDirectory(transferID: transferID)
            )
        }
    }

    func reportImportFailure(transferID: String?, reason: String) {
        guard let transferID else {
            return
        }

        processingQueue.async { [weak self] in
            guard let self,
                  let manifest = loadManifest(transferID: transferID) else {
                return
            }

            reject(
                recordingID: manifest.recordingID,
                transferID: transferID,
                reason: reason
            )
        }
    }

    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        guard activationState == .activated, error == nil else {
            return
        }

        processingQueue.async { [weak self] in
            self?.removeStaleTransfers()
            self?.resumePendingTransfers()
            self?.flushAcknowledgements()
        }
    }

    func sessionDidBecomeInactive(_ session: WCSession) { }

    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }

    func session(_ session: WCSession, didReceive file: WCSessionFile) {
        guard let data = try? Data(contentsOf: file.fileURL) else {
            return
        }
        let chunkMetadata = RecordingChunkMetadata(dictionary: file.metadata)
        let hasChunkProtocol = file.metadata?[TransferKey.chunkProtocolVersion] != nil
        let recordingID = file.metadata?[TransferKey.recordingID] as? String
        let transferID = file.metadata?[TransferKey.transferID] as? String

        processingQueue.async { [weak self] in
            guard let self else {
                return
            }

            if let chunkMetadata {
                receiveChunk(data, metadata: chunkMetadata)
            } else if hasChunkProtocol, let recordingID, let transferID {
                reject(
                    recordingID: recordingID,
                    transferID: transferID,
                    reason: "Transferred block metadata was invalid"
                )
            } else {
                onRecordingReceived?(data, nil)
            }
        }
    }

    func session(
        _ session: WCSession,
        didReceiveUserInfo userInfo: [String: Any] = [:]
    ) {
        guard let requests = userInfo[TransferKey.transferStatusRequests]
            as? [String: String] else {
            return
        }

        processingQueue.async { [weak self] in
            guard let self else {
                return
            }

            resumePendingTransfers()
            let acknowledgements = acknowledgedTransfers
            var recordingIDs = acknowledgedRecordingIDs
            let confirmedRequests = requests.filter {
                acknowledgements[$0.key] != nil
            }
            for (transferID, recordingID) in confirmedRequests {
                recordingIDs[transferID] = recordingID
            }
            acknowledgedRecordingIDs = recordingIDs
            for (transferID, recordingID) in confirmedRequests {
                sendAcknowledgement(
                    recordingID: recordingID,
                    transferID: transferID
                )
            }

            let unresolvedRequests = requests.filter {
                acknowledgements[$0.key] == nil
            }
            var tokens: [String: UUID] = [:]
            for transferID in unresolvedRequests.keys {
                let token = UUID()
                statusCheckTokens[transferID] = token
                tokens[transferID] = token
            }
            scheduleStatusCheck(unresolvedRequests, tokens: tokens)
        }
    }

    private func receiveChunk(_ data: Data, metadata: RecordingChunkMetadata) {
        guard acknowledgedTransfers[metadata.transferID] == nil else {
            return
        }

        guard data.count == metadata.chunkByteCount,
              Self.hash(data) == metadata.chunkHash else {
            reject(metadata: metadata, reason: "A transferred block was corrupted")
            return
        }

        do {
            var manifest = try loadOrCreateManifest(metadata: metadata)
            guard manifest.matches(metadata) else {
                reject(metadata: metadata, reason: "Transfer metadata did not match")
                return
            }

            let existingHash = manifest.chunkHashes[metadata.chunkIndex]
            guard existingHash == nil || existingHash == metadata.chunkHash else {
                reject(metadata: metadata, reason: "Conflicting duplicate block")
                return
            }

            try data.write(
                to: Self.chunkURL(
                    transferID: metadata.transferID,
                    chunkIndex: metadata.chunkIndex
                ),
                options: .atomic
            )
            manifest.chunkHashes[metadata.chunkIndex] = metadata.chunkHash
            manifest.chunkByteCounts[metadata.chunkIndex] = metadata.chunkByteCount
            try save(manifest)

            if manifest.chunkHashes.count == manifest.chunkCount {
                try assemble(manifest)
            }
        } catch {
            reject(metadata: metadata, reason: error.localizedDescription)
        }
    }

    private func loadOrCreateManifest(
        metadata: RecordingChunkMetadata
    ) throws -> IncomingChunkTransferManifest {
        let directory = Self.transferDirectory(transferID: metadata.transferID)
        try FileManager.default.createDirectory(
            at: directory,
            withIntermediateDirectories: true
        )

        let manifestURL = Self.manifestURL(transferID: metadata.transferID)
        if let data = try? Data(contentsOf: manifestURL),
           let manifest = try? JSONDecoder().decode(
               IncomingChunkTransferManifest.self,
               from: data
           ) {
            return manifest
        }

        let manifest = IncomingChunkTransferManifest(
            transferID: metadata.transferID,
            recordingID: metadata.recordingID,
            chunkCount: metadata.chunkCount,
            totalByteCount: metadata.totalByteCount,
            fileHash: metadata.fileHash,
            createdAt: .now,
            chunkHashes: [:],
            chunkByteCounts: [:]
        )
        try save(manifest)
        return manifest
    }

    private func save(_ manifest: IncomingChunkTransferManifest) throws {
        let data = try JSONEncoder().encode(manifest)
        try data.write(
            to: Self.manifestURL(transferID: manifest.transferID),
            options: .atomic
        )
    }

    private func assemble(_ manifest: IncomingChunkTransferManifest) throws {
        let assembledURL = Self.assembledURL(transferID: manifest.transferID)
        if FileManager.default.fileExists(atPath: assembledURL.path) {
            deliver(manifest: manifest, assembledURL: assembledURL)
            return
        }

        let temporaryURL = Self.transferDirectory(transferID: manifest.transferID)
            .appendingPathComponent("assembled.tmp")
        try? FileManager.default.removeItem(at: temporaryURL)
        _ = FileManager.default.createFile(atPath: temporaryURL.path, contents: nil)

        let output = try FileHandle(forWritingTo: temporaryURL)
        defer {
            try? output.close()
        }

        var fileHasher = SHA256()
        var assembledByteCount = 0

        for chunkIndex in 0..<manifest.chunkCount {
            guard let expectedHash = manifest.chunkHashes[chunkIndex],
                  let expectedByteCount = manifest.chunkByteCounts[chunkIndex] else {
                throw TransferAssemblyError.missingChunk
            }

            let data = try Data(
                contentsOf: Self.chunkURL(
                    transferID: manifest.transferID,
                    chunkIndex: chunkIndex
                )
            )
            guard data.count == expectedByteCount,
                  Self.hash(data) == expectedHash else {
                throw TransferAssemblyError.corruptedChunk
            }

            try output.write(contentsOf: data)
            fileHasher.update(data: data)
            assembledByteCount += data.count
        }

        guard assembledByteCount == manifest.totalByteCount,
              Self.hex(fileHasher.finalize()) == manifest.fileHash else {
            throw TransferAssemblyError.corruptedFile
        }

        try output.synchronize()
        try output.close()
        try? FileManager.default.removeItem(at: assembledURL)
        try FileManager.default.moveItem(at: temporaryURL, to: assembledURL)
        deliver(manifest: manifest, assembledURL: assembledURL)
    }

    private func deliver(manifest: IncomingChunkTransferManifest, assembledURL: URL) {
        guard !deliveringTransferIDs.contains(manifest.transferID),
              let data = try? Data(contentsOf: assembledURL) else {
            return
        }

        deliveringTransferIDs.insert(manifest.transferID)
        onRecordingReceived?(data, manifest.transferID)
    }

    private func resumePendingTransfers() {
        for manifest in loadManifests() {
            let assembledURL = Self.assembledURL(transferID: manifest.transferID)
            if FileManager.default.fileExists(atPath: assembledURL.path) {
                deliver(manifest: manifest, assembledURL: assembledURL)
                continue
            }

            do {
                var recoveredManifest = manifest

                for (chunkIndex, expectedHash) in manifest.chunkHashes {
                    guard chunkIndex >= 0,
                          chunkIndex < manifest.chunkCount,
                          let expectedByteCount = manifest.chunkByteCounts[chunkIndex] else {
                        throw TransferAssemblyError.missingChunk
                    }
                    let data = try Data(
                        contentsOf: Self.chunkURL(
                            transferID: manifest.transferID,
                            chunkIndex: chunkIndex
                        )
                    )
                    guard Self.hash(data) == expectedHash,
                          data.count == expectedByteCount else {
                        throw TransferAssemblyError.corruptedChunk
                    }
                }

                for chunkIndex in 0..<manifest.chunkCount
                where recoveredManifest.chunkHashes[chunkIndex] == nil {
                    let chunkURL = Self.chunkURL(
                        transferID: manifest.transferID,
                        chunkIndex: chunkIndex
                    )
                    guard let data = try? Data(contentsOf: chunkURL) else {
                        continue
                    }
                    recoveredManifest.chunkHashes[chunkIndex] = Self.hash(data)
                    recoveredManifest.chunkByteCounts[chunkIndex] = data.count
                }

                try save(recoveredManifest)
                if recoveredManifest.chunkHashes.count == recoveredManifest.chunkCount {
                    try assemble(recoveredManifest)
                }
            } catch {
                reject(
                    recordingID: manifest.recordingID,
                    transferID: manifest.transferID,
                    reason: error.localizedDescription
                )
            }
        }
    }

    private func reject(metadata: RecordingChunkMetadata, reason: String) {
        reject(
            recordingID: metadata.recordingID,
            transferID: metadata.transferID,
            reason: reason
        )
    }

    private func reject(recordingID: String, transferID: String, reason: String) {
        try? FileManager.default.removeItem(
            at: Self.transferDirectory(transferID: transferID)
        )
        deliveringTransferIDs.remove(transferID)
        statusCheckTokens.removeValue(forKey: transferID)
        session?.transferUserInfo([
            TransferKey.failedRecordingID: recordingID,
            TransferKey.failedTransferID: transferID,
            TransferKey.transferFailureReason: reason
        ])
    }

    private func sendAcknowledgement(recordingID: String, transferID: String?) {
        guard let session, session.activationState == .activated else {
            return
        }

        var acknowledgement: [String: Any] = [
            TransferKey.importedRecordingID: recordingID
        ]
        if let transferID {
            acknowledgement[TransferKey.importedTransferID] = transferID
        }
        session.transferUserInfo(acknowledgement)

        let importedTransfers = acknowledgedRecordingIDs
        guard !importedTransfers.isEmpty else {
            return
        }
        try? session.updateApplicationContext([
            TransferKey.importedTransfers: importedTransfers
        ])
    }

    private func flushAcknowledgements() {
        let recordingIDs = acknowledgedRecordingIDs
        for (transferID, recordingID) in recordingIDs {
            sendAcknowledgement(
                recordingID: recordingID,
                transferID: transferID
            )
        }
    }

    private func scheduleStatusCheck(
        _ requests: [String: String],
        tokens: [String: UUID]
    ) {
        processingQueue.asyncAfter(deadline: .now() + 15) { [weak self] in
            guard let self else {
                return
            }

            let acknowledgements = acknowledgedTransfers
            for (transferID, recordingID) in requests
            where acknowledgements[transferID] == nil {
                guard statusCheckTokens[transferID] == tokens[transferID] else {
                    continue
                }
                if deliveringTransferIDs.contains(transferID) {
                    continue
                }

                if let manifest = loadManifest(transferID: transferID) {
                    let assembledURL = Self.assembledURL(transferID: transferID)
                    if FileManager.default.fileExists(atPath: assembledURL.path) {
                        deliver(manifest: manifest, assembledURL: assembledURL)
                        continue
                    }
                }

                reject(
                    recordingID: recordingID,
                    transferID: transferID,
                    reason: "iPhone did not receive every recording block"
                )
            }
        }
    }

    private func removeStaleTransfers() {
        let cutoff = Date().addingTimeInterval(-7 * 24 * 60 * 60)
        for manifest in loadManifests() where manifest.createdAt < cutoff {
            session?.transferUserInfo([
                TransferKey.failedRecordingID: manifest.recordingID,
                TransferKey.failedTransferID: manifest.transferID,
                TransferKey.transferFailureReason: "The incomplete transfer expired"
            ])
            try? FileManager.default.removeItem(
                at: Self.transferDirectory(transferID: manifest.transferID)
            )
        }

        let cutoffTimestamp = cutoff.timeIntervalSince1970
        let existingAcknowledgements = acknowledgedTransfers
        let recentAcknowledgements = existingAcknowledgements.filter {
            $0.value >= cutoffTimestamp
        }
        if recentAcknowledgements.count != existingAcknowledgements.count {
            acknowledgedTransfers = recentAcknowledgements
        }

        let recordingIDs = acknowledgedRecordingIDs
        let recentRecordingIDs = recordingIDs.filter {
            recentAcknowledgements[$0.key] != nil
        }
        if recentRecordingIDs.count != recordingIDs.count {
            acknowledgedRecordingIDs = recentRecordingIDs
        }
    }

    private func loadManifests() -> [IncomingChunkTransferManifest] {
        let directories = (try? FileManager.default.contentsOfDirectory(
            at: Self.rootDirectory,
            includingPropertiesForKeys: nil
        )) ?? []

        return directories.compactMap {
            loadManifest(
                at: $0.appendingPathComponent(Self.manifestName)
            )
        }
    }

    private func loadManifest(transferID: String) -> IncomingChunkTransferManifest? {
        loadManifest(at: Self.manifestURL(transferID: transferID))
    }

    private func loadManifest(at url: URL) -> IncomingChunkTransferManifest? {
        guard let data = try? Data(contentsOf: url) else {
            return nil
        }
        return try? JSONDecoder().decode(
            IncomingChunkTransferManifest.self,
            from: data
        )
    }

    private static let manifestName = "manifest.json"
    private static let acknowledgedTransfersKey = "acknowledgedWatchChunkTransfers"
    private static let acknowledgedRecordingIDsKey = "acknowledgedWatchRecordingIDs"

    private var acknowledgedTransfers: [String: Double] {
        get {
            let stored = UserDefaults.standard.dictionary(
                forKey: Self.acknowledgedTransfersKey
            ) ?? [:]
            return stored.reduce(into: [:]) { result, item in
                if let timestamp = item.value as? NSNumber {
                    result[item.key] = timestamp.doubleValue
                }
            }
        }
        set {
            UserDefaults.standard.set(
                newValue,
                forKey: Self.acknowledgedTransfersKey
            )
        }
    }

    private var acknowledgedRecordingIDs: [String: String] {
        get {
            UserDefaults.standard.dictionary(
                forKey: Self.acknowledgedRecordingIDsKey
            ) as? [String: String] ?? [:]
        }
        set {
            UserDefaults.standard.set(
                newValue,
                forKey: Self.acknowledgedRecordingIDsKey
            )
        }
    }

    private static var rootDirectory: URL {
        FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        )[0].appendingPathComponent("IncomingWatchRecordingTransfers", isDirectory: true)
    }

    private static func transferDirectory(transferID: String) -> URL {
        rootDirectory.appendingPathComponent(transferID, isDirectory: true)
    }

    private static func manifestURL(transferID: String) -> URL {
        transferDirectory(transferID: transferID).appendingPathComponent(manifestName)
    }

    private static func assembledURL(transferID: String) -> URL {
        transferDirectory(transferID: transferID).appendingPathComponent("assembled.json")
    }

    private static func chunkURL(transferID: String, chunkIndex: Int) -> URL {
        transferDirectory(transferID: transferID)
            .appendingPathComponent(String(format: "chunk-%06d.data", chunkIndex))
    }

    private static func hash(_ data: Data) -> String {
        hex(SHA256.hash(data: data))
    }

    private static func hex<Digest: Sequence>(_ digest: Digest) -> String
    where Digest.Element == UInt8 {
        digest.map { String(format: "%02x", $0) }.joined()
    }
}

private struct IncomingChunkTransferManifest: Codable {
    let transferID: String
    let recordingID: String
    let chunkCount: Int
    let totalByteCount: Int
    let fileHash: String
    let createdAt: Date
    var chunkHashes: [Int: String]
    var chunkByteCounts: [Int: Int]

    func matches(_ metadata: RecordingChunkMetadata) -> Bool {
        transferID == metadata.transferID
            && recordingID == metadata.recordingID
            && chunkCount == metadata.chunkCount
            && totalByteCount == metadata.totalByteCount
            && fileHash == metadata.fileHash
    }
}

private enum TransferAssemblyError: LocalizedError {
    case missingChunk
    case corruptedChunk
    case corruptedFile

    var errorDescription: String? {
        switch self {
        case .missingChunk:
            "A recording block is missing"
        case .corruptedChunk:
            "A recording block is corrupted"
        case .corruptedFile:
            "The assembled recording is corrupted"
        }
    }
}
