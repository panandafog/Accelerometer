//
//  WatchRecorder.swift
//  Accelerometer Watch Watch App
//
//  Created by OpenAI on 07.06.2026.
//

import Combine
import CryptoKit
import Foundation
import WatchConnectivity
import WatchKit
import WidgetKit

@MainActor
final class WatchRecorder: NSObject, ObservableObject {
    @Published private(set) var activeRecording: ActiveRecording?
    @Published private(set) var recordings: [StoredRecording] = []
    @Published private(set) var transferringIDs: Set<String> = []
    @Published private(set) var transferProgress: [String: Double] = [:]
    @Published private(set) var awaitingImportIDs: Set<String> = []
    @Published var lastTransferError: String?

    private let measurer: Measurer
    private let session: WCSession?
    private var subscriptions: [MeasurementType: AnyCancellable] = [:]
    private var measurerSubscription: AnyCancellable?
    private var activeEntries: [RecordingTransferPayload.Entry] = []
    private var extendedRuntimeSession: WKExtendedRuntimeSession?
    private var activeFileTransfers: [String: WCSessionFileTransfer] = [:]
    private var chunkTransferSessions: [String: WatchChunkTransferSession] = [:]

    private var transferredIDs: Set<String> {
        get {
            Set(UserDefaults.standard.stringArray(forKey: StorageKey.transferredIDs) ?? [])
        }
        set {
            UserDefaults.standard.set(Array(newValue), forKey: StorageKey.transferredIDs)
            reloadRecordings()
        }
    }

    init(measurer: Measurer) {
        self.measurer = measurer
        if WCSession.isSupported() {
            session = .default
        } else {
            session = nil
        }

        super.init()

        session?.delegate = self
        session?.activate()
        awaitingImportIDs = Set(
            UserDefaults.standard.stringArray(forKey: StorageKey.awaitingImportIDs) ?? []
        )
        transferringIDs = awaitingImportIDs
        restoreChunkTransferSessions()
        restoreOutstandingTransfers()
        reloadRecordings()
        updateRecordingWidget()
    }

    var isRecording: Bool {
        activeRecording != nil
    }

    func start(measurements: Set<MeasurementType>) {
        guard activeRecording == nil, !measurements.isEmpty else {
            return
        }

        activeEntries = []
        let activeRecording = ActiveRecording(
            start: Date(),
            measurementTypes: measurements
        )
        self.activeRecording = activeRecording
        startExtendedRuntimeSession()
        updateRecordingWidget(
            start: activeRecording.start,
            measurementCount: activeRecording.measurementTypes.count
        )
        attachMissingSubscriptions()

        measurerSubscription = measurer.objectWillChange.sink { [weak self] _ in
            Task { @MainActor in
                self?.attachMissingSubscriptions()
            }
        }
    }

    func stop() {
        guard let activeRecording else {
            return
        }

        let payload = RecordingTransferPayload(
            id: activeRecording.id,
            start: activeRecording.start,
            end: Date(),
            measurementTypes: activeRecording.measurementTypes.map(\.rawValue),
            entries: activeEntries
        )

        do {
            try persist(payload)
        } catch {
            lastTransferError = error.localizedDescription
        }

        self.activeRecording = nil
        stopExtendedRuntimeSession()
        updateRecordingWidget()
        activeEntries = []
        subscriptions.removeAll()
        measurerSubscription = nil
        reloadRecordings()
    }

    func send(recordingID: String) {
        guard let session,
              let recording = recordings.first(where: { $0.id == recordingID }),
              !transferringIDs.contains(recordingID) else {
            lastTransferError = "Recording is unavailable"
            return
        }

        guard session.isCompanionAppInstalled else {
            lastTransferError = "Install the iPhone app first"
            return
        }

        lastTransferError = nil
        removeFailedTransferSessions(recordingID: recordingID)
        removeAwaitingImport(recordingID: recordingID)
        transferringIDs.insert(recordingID)
        transferProgress[recordingID] = 0

        Task { [weak self] in
            do {
                let preparedSession = try await Task.detached(priority: .userInitiated) {
                    try WatchChunkTransferStorage.prepare(
                        recordingID: recordingID,
                        sourceURL: recording.fileURL
                    )
                }.value

                guard let self else {
                    return
                }

                chunkTransferSessions[preparedSession.transferID] = preparedSession
                enqueuePendingChunks(transferID: preparedSession.transferID, session: session)
            } catch {
                self?.transferringIDs.remove(recordingID)
                self?.transferProgress.removeValue(forKey: recordingID)
                self?.lastTransferError = "Could not prepare recording: \(error.localizedDescription)"
            }
        }
    }

    func delete(recordingID: String) {
        guard let recording = recordings.first(where: { $0.id == recordingID }) else {
            return
        }

        try? FileManager.default.removeItem(at: recording.fileURL)
        var updatedTransferredIDs = transferredIDs
        updatedTransferredIDs.remove(recordingID)
        transferredIDs = updatedTransferredIDs
        transferringIDs.remove(recordingID)
        transferProgress.removeValue(forKey: recordingID)
        removeAwaitingImport(recordingID: recordingID)
        cancelTransferSessions(recordingID: recordingID)
        removeTransferSessions(recordingID: recordingID, transferID: nil)
        reloadRecordings()
    }

    private func attachMissingSubscriptions() {
        guard let activeRecording else {
            return
        }

        for type in activeRecording.measurementTypes where subscriptions[type] == nil {
            guard let observableAxes = measurer.observableAxes[type] else {
                continue
            }

            subscriptions[type] = observableAxes.$axes
                .dropFirst()
                .sink { [weak self] axes in
                    self?.activeEntries.append(
                        RecordingTransferPayload.Entry(
                            measurementType: type,
                            axes: axes
                        )
                    )
                }
        }
    }

    private func persist(_ payload: RecordingTransferPayload) throws {
        let data = try JSONEncoder.recordingTransfer.encode(payload)
        try FileManager.default.createDirectory(
            at: Self.recordingsDirectory,
            withIntermediateDirectories: true
        )
        try data.write(
            to: Self.recordingsDirectory.appendingPathComponent("\(payload.id).json"),
            options: .atomic
        )
    }

    private func reloadRecordings() {
        let urls = (try? FileManager.default.contentsOfDirectory(
            at: Self.recordingsDirectory,
            includingPropertiesForKeys: nil
        )) ?? []
        let transferredIDs = transferredIDs

        recordings = urls
            .filter { $0.pathExtension == "json" }
            .compactMap { url in
                guard let data = try? Data(contentsOf: url),
                      let payload = try? JSONDecoder.recordingTransfer.decode(
                        RecordingTransferPayload.self,
                        from: data
                      ) else {
                    return nil
                }

                return StoredRecording(
                    payload: payload,
                    fileURL: url,
                    isTransferred: transferredIDs.contains(payload.id)
                )
            }
            .sorted { $0.payload.start > $1.payload.start }
    }

    private func markTransferred(recordingID: String) {
        transferringIDs.remove(recordingID)
        transferProgress.removeValue(forKey: recordingID)
        removeAwaitingImport(recordingID: recordingID)
        cancelTransferSessions(recordingID: recordingID)
        removeTransferSessions(recordingID: recordingID, transferID: nil)
        var updatedTransferredIDs = transferredIDs
        updatedTransferredIDs.insert(recordingID)
        transferredIDs = updatedTransferredIDs
    }

    private func restoreChunkTransferSessions() {
        for session in WatchChunkTransferStorage.loadSessions() {
            chunkTransferSessions[session.transferID] = session

            guard !session.isFailed else {
                continue
            }

            transferringIDs.insert(session.recordingID)
            if session.isAwaitingImport || session.allChunksDelivered {
                addAwaitingImport(recordingID: session.recordingID)
            } else {
                transferProgress[session.recordingID] = session.progress
            }
        }
    }

    private func restoreOutstandingTransfers() {
        guard let session else {
            return
        }

        for transfer in session.outstandingFileTransfers {
            if let metadata = RecordingChunkMetadata(dictionary: transfer.file.metadata) {
                activeFileTransfers[chunkTransferKey(metadata)] = transfer
                transferringIDs.insert(metadata.recordingID)
                continue
            }

            guard let recordingID = transfer.file.metadata?[TransferKey.recordingID] as? String else {
                continue
            }

            activeFileTransfers[legacyTransferKey(recordingID: recordingID)] = transfer
            transferringIDs.insert(recordingID)
        }
    }

    private func reconcileChunkTransfers() {
        guard let session else {
            return
        }

        for transferID in chunkTransferSessions.keys {
            enqueuePendingChunks(transferID: transferID, session: session)
        }
    }

    private func requestImportStatuses() {
        guard let session, session.activationState == .activated else {
            return
        }

        let requests = chunkTransferSessions.values.reduce(
            into: [String: String]()
        ) { result, transferSession in
            guard !transferSession.isFailed,
                  transferSession.isAwaitingImport
                    || transferSession.allChunksDelivered else {
                return
            }
            result[transferSession.transferID] = transferSession.recordingID
        }
        guard !requests.isEmpty else {
            return
        }

        session.transferUserInfo([
            TransferKey.transferStatusRequests: requests
        ])
    }

    private func handleImportAcknowledgements(
        importedTransfers: [String: String],
        recordingID: String?
    ) {
        for recordingID in importedTransfers.values {
            markTransferred(recordingID: recordingID)
        }

        guard let recordingID else {
            return
        }
        markTransferred(recordingID: recordingID)
    }

    private func enqueuePendingChunks(transferID: String, session: WCSession) {
        guard let transferSession = chunkTransferSessions[transferID],
              !transferSession.isFailed,
              !transferSession.isAwaitingImport else {
            return
        }

        for chunk in transferSession.chunks
        where !transferSession.completedChunkIndices.contains(chunk.index) {
            let metadata = transferSession.metadata(for: chunk)
            let key = chunkTransferKey(metadata)
            guard activeFileTransfers[key] == nil else {
                continue
            }

            let transfer = session.transferFile(
                WatchChunkTransferStorage.chunkURL(
                    transferID: transferID,
                    chunkIndex: chunk.index
                ),
                metadata: metadata.dictionary
            )
            activeFileTransfers[key] = transfer
        }
    }

    private func handleChunkTransferFinished(
        metadata: RecordingChunkMetadata,
        error: Error?
    ) {
        let key = chunkTransferKey(metadata)
        activeFileTransfers.removeValue(forKey: key)

        guard var transferSession = chunkTransferSessions[metadata.transferID],
              transferSession.recordingID == metadata.recordingID,
              !transferSession.isFailed else {
            return
        }

        if let error {
            let retries = transferSession.retryCounts[metadata.chunkIndex, default: 0] + 1
            transferSession.retryCounts[metadata.chunkIndex] = retries

            if retries <= WatchChunkTransferStorage.maximumRetryCount,
               let session,
               session.isCompanionAppInstalled {
                chunkTransferSessions[metadata.transferID] = transferSession
                try? WatchChunkTransferStorage.save(transferSession)
                enqueuePendingChunks(transferID: metadata.transferID, session: session)
            } else {
                transferSession.isFailed = true
                transferSession.failureMessage = error.localizedDescription
                chunkTransferSessions[metadata.transferID] = transferSession
                try? WatchChunkTransferStorage.save(transferSession)
                cancelTransferSession(transferID: metadata.transferID)
                transferringIDs.remove(metadata.recordingID)
                transferProgress.removeValue(forKey: metadata.recordingID)
                removeAwaitingImport(recordingID: metadata.recordingID)
                lastTransferError = "Sending failed: \(error.localizedDescription)"
            }
            return
        }

        transferSession.completedChunkIndices.insert(metadata.chunkIndex)
        transferSession.retryCounts.removeValue(forKey: metadata.chunkIndex)

        if transferSession.allChunksDelivered {
            transferSession.isAwaitingImport = true
            transferProgress.removeValue(forKey: metadata.recordingID)
            addAwaitingImport(recordingID: metadata.recordingID)
        } else {
            transferProgress[metadata.recordingID] = transferSession.progress
        }

        chunkTransferSessions[metadata.transferID] = transferSession
        try? WatchChunkTransferStorage.save(transferSession)
        if transferSession.isAwaitingImport {
            requestImportStatuses()
        }
    }

    private func handleRemoteTransferFailure(
        recordingID: String,
        transferID: String,
        reason: String?
    ) {
        guard var transferSession = chunkTransferSessions[transferID],
              transferSession.recordingID == recordingID else {
            return
        }

        if transferSession.assemblyRetryCount < 1,
           let session,
           session.isCompanionAppInstalled {
            transferSession.assemblyRetryCount += 1
            transferSession.completedChunkIndices = []
            transferSession.retryCounts = [:]
            transferSession.isAwaitingImport = false
            chunkTransferSessions[transferID] = transferSession
            try? WatchChunkTransferStorage.save(transferSession)
            removeAwaitingImport(recordingID: recordingID)
            transferringIDs.insert(recordingID)
            transferProgress[recordingID] = 0
            enqueuePendingChunks(transferID: transferID, session: session)
        } else {
            transferSession.isFailed = true
            transferSession.failureMessage = reason
            chunkTransferSessions[transferID] = transferSession
            try? WatchChunkTransferStorage.save(transferSession)
            cancelTransferSession(transferID: transferID)
            transferringIDs.remove(recordingID)
            transferProgress.removeValue(forKey: recordingID)
            removeAwaitingImport(recordingID: recordingID)
            lastTransferError = reason.map { "iPhone rejected transfer: \($0)" }
                ?? "iPhone rejected transfer"
        }
    }

    private func addAwaitingImport(recordingID: String) {
        transferringIDs.insert(recordingID)
        awaitingImportIDs.insert(recordingID)
        persistAwaitingImportIDs()
    }

    private func removeAwaitingImport(recordingID: String) {
        awaitingImportIDs.remove(recordingID)
        persistAwaitingImportIDs()
    }

    private func persistAwaitingImportIDs() {
        UserDefaults.standard.set(
            Array(awaitingImportIDs),
            forKey: StorageKey.awaitingImportIDs
        )
    }

    private func removeTransferSessions(recordingID: String, transferID: String?) {
        let matchingIDs = chunkTransferSessions.values.compactMap { session -> String? in
            guard session.recordingID == recordingID,
                  transferID == nil || session.transferID == transferID else {
                return nil
            }
            return session.transferID
        }

        for matchingID in matchingIDs {
            chunkTransferSessions.removeValue(forKey: matchingID)
            try? WatchChunkTransferStorage.remove(transferID: matchingID)
        }
    }

    private func removeFailedTransferSessions(recordingID: String) {
        let failedTransferIDs = chunkTransferSessions.values.compactMap { session in
            session.recordingID == recordingID && session.isFailed
                ? session.transferID
                : nil
        }

        for transferID in failedTransferIDs {
            cancelTransferSession(transferID: transferID)
            chunkTransferSessions.removeValue(forKey: transferID)
            try? WatchChunkTransferStorage.remove(transferID: transferID)
        }
    }

    private func cancelTransferSessions(recordingID: String) {
        for transferSession in chunkTransferSessions.values
        where transferSession.recordingID == recordingID {
            cancelTransferSession(transferID: transferSession.transferID)
        }
    }

    private func cancelTransferSession(transferID: String) {
        let keys = activeFileTransfers.keys.filter {
            $0.hasPrefix("\(transferID):")
        }
        for key in keys {
            activeFileTransfers.removeValue(forKey: key)?.cancel()
        }
    }

    private func chunkTransferKey(_ metadata: RecordingChunkMetadata) -> String {
        "\(metadata.transferID):\(metadata.chunkIndex)"
    }

    private func legacyTransferKey(recordingID: String) -> String {
        "legacy:\(recordingID)"
    }

    private func updateRecordingWidget(start: Date? = nil, measurementCount: Int = 0) {
        if let start {
            WatchRecordingWidgetState.save(
                start: start,
                measurementCount: measurementCount
            )
        } else {
            WatchRecordingWidgetState.clear()
        }

        WidgetCenter.shared.reloadTimelines(ofKind: WatchRecordingWidgetState.widgetKind)
        WidgetCenter.shared.invalidateRelevance(ofKind: WatchRecordingWidgetState.widgetKind)
    }

    private func startExtendedRuntimeSession() {
        guard extendedRuntimeSession == nil else {
            return
        }

        let session = WKExtendedRuntimeSession()
        session.delegate = self
        extendedRuntimeSession = session
        session.start()
    }

    private func stopExtendedRuntimeSession() {
        let session = extendedRuntimeSession
        extendedRuntimeSession = nil

        guard session?.state != .invalid else {
            return
        }
        session?.invalidate()
    }

    private func handleExtendedRuntimeEnd(
        reason: WKExtendedRuntimeSessionInvalidationReason,
        error: Error?
    ) {
        extendedRuntimeSession = nil

        if let error {
            lastTransferError = "Background recording unavailable: \(error.localizedDescription)"
        }

        if reason != .none, isRecording {
            stop()
        }
    }

    private static var recordingsDirectory: URL {
        FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        )[0].appendingPathComponent("WatchRecordings", isDirectory: true)
    }
}

extension WatchRecorder {
    struct ActiveRecording: Identifiable {
        let id: String
        let start: Date
        let measurementTypes: Set<MeasurementType>

        init(
            id: String = UUID().uuidString,
            start: Date,
            measurementTypes: Set<MeasurementType>
        ) {
            self.id = id
            self.start = start
            self.measurementTypes = measurementTypes
        }
    }

    struct StoredRecording: Identifiable {
        let payload: RecordingTransferPayload
        let fileURL: URL
        let isTransferred: Bool

        var id: String { payload.id }
    }

    private enum StorageKey {
        static let transferredIDs = "watchTransferredRecordingIDs"
        static let awaitingImportIDs = "watchAwaitingImportRecordingIDs"
    }
}

extension WatchRecorder: WCSessionDelegate {
    nonisolated func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        guard activationState == .activated, error == nil else {
            return
        }

        Task { @MainActor [weak self] in
            self?.restoreOutstandingTransfers()
            self?.reconcileChunkTransfers()
            if let context = self?.session?.receivedApplicationContext {
                self?.handleImportAcknowledgements(
                    importedTransfers: context[TransferKey.importedTransfers]
                        as? [String: String] ?? [:],
                    recordingID: context[TransferKey.importedRecordingID] as? String
                )
            }
            self?.requestImportStatuses()
        }
    }

    nonisolated func session(
        _ session: WCSession,
        didFinish fileTransfer: WCSessionFileTransfer,
        error: Error?
    ) {
        if let metadata = RecordingChunkMetadata(dictionary: fileTransfer.file.metadata) {
            Task { @MainActor [weak self] in
                self?.handleChunkTransferFinished(metadata: metadata, error: error)
            }
            return
        }

        guard let recordingID = fileTransfer.file.metadata?[TransferKey.recordingID] as? String else {
            return
        }

        Task { @MainActor [weak self] in
            self?.activeFileTransfers.removeValue(
                forKey: self?.legacyTransferKey(recordingID: recordingID) ?? ""
            )
            self?.transferProgress.removeValue(forKey: recordingID)
            if let error {
                self?.transferringIDs.remove(recordingID)
                self?.removeAwaitingImport(recordingID: recordingID)
                self?.lastTransferError = error.localizedDescription
            } else if self?.transferredIDs.contains(recordingID) == false {
                self?.addAwaitingImport(recordingID: recordingID)
            }
        }
    }

    nonisolated func session(
        _ session: WCSession,
        didReceiveUserInfo userInfo: [String: Any] = [:]
    ) {
        if let recordingID = userInfo[TransferKey.failedRecordingID] as? String,
           let transferID = userInfo[TransferKey.failedTransferID] as? String {
            let reason = userInfo[TransferKey.transferFailureReason] as? String
            Task { @MainActor [weak self] in
                self?.handleRemoteTransferFailure(
                    recordingID: recordingID,
                    transferID: transferID,
                    reason: reason
                )
            }
            return
        }

        let importedTransfers = userInfo[TransferKey.importedTransfers]
            as? [String: String] ?? [:]
        let importedRecordingID = userInfo[TransferKey.importedRecordingID] as? String
        Task { @MainActor [weak self] in
            self?.handleImportAcknowledgements(
                importedTransfers: importedTransfers,
                recordingID: importedRecordingID
            )
        }
    }

    nonisolated func session(
        _ session: WCSession,
        didReceiveApplicationContext applicationContext: [String: Any]
    ) {
        let importedTransfers = applicationContext[TransferKey.importedTransfers]
            as? [String: String] ?? [:]
        let importedRecordingID = applicationContext[TransferKey.importedRecordingID] as? String
        Task { @MainActor [weak self] in
            self?.handleImportAcknowledgements(
                importedTransfers: importedTransfers,
                recordingID: importedRecordingID
            )
        }
    }
}

extension WatchRecorder: WKExtendedRuntimeSessionDelegate {
    nonisolated func extendedRuntimeSessionDidStart(
        _ extendedRuntimeSession: WKExtendedRuntimeSession
    ) { }

    nonisolated func extendedRuntimeSessionWillExpire(
        _ extendedRuntimeSession: WKExtendedRuntimeSession
    ) {
        Task { @MainActor [weak self] in
            self?.stop()
        }
    }

    nonisolated func extendedRuntimeSession(
        _ extendedRuntimeSession: WKExtendedRuntimeSession,
        didInvalidateWith reason: WKExtendedRuntimeSessionInvalidationReason,
        error: Error?
    ) {
        Task { @MainActor [weak self] in
            self?.handleExtendedRuntimeEnd(reason: reason, error: error)
        }
    }
}

private struct WatchChunkTransferSession: Codable, Sendable {
    let transferID: String
    let recordingID: String
    let totalByteCount: Int
    let fileHash: String
    let chunks: [Chunk]
    let createdAt: Date
    var completedChunkIndices: Set<Int>
    var retryCounts: [Int: Int]
    var assemblyRetryCount: Int
    var isAwaitingImport: Bool
    var isFailed: Bool
    var failureMessage: String?

    var allChunksDelivered: Bool {
        completedChunkIndices.count == chunks.count
    }

    var progress: Double {
        guard totalByteCount > 0 else {
            return allChunksDelivered ? 1 : 0
        }

        let deliveredBytes = chunks
            .filter { completedChunkIndices.contains($0.index) }
            .reduce(0) { $0 + $1.byteCount }

        return min(1, Double(deliveredBytes) / Double(totalByteCount))
    }

    func metadata(for chunk: Chunk) -> RecordingChunkMetadata {
        RecordingChunkMetadata(
            transferID: transferID,
            recordingID: recordingID,
            chunkIndex: chunk.index,
            chunkCount: chunks.count,
            chunkByteCount: chunk.byteCount,
            totalByteCount: totalByteCount,
            chunkHash: chunk.hash,
            fileHash: fileHash
        )
    }

    struct Chunk: Codable, Sendable {
        let index: Int
        let byteCount: Int
        let hash: String
    }
}

private enum WatchChunkTransferStorage {
    static let maximumRetryCount = 3
    private static let targetChunkCount = 100
    private static let minimumChunkSize = 524_288
    private static let maximumChunkSize = 8_388_608
    private static let manifestName = "manifest.json"

    static func prepare(
        recordingID: String,
        sourceURL: URL
    ) throws -> WatchChunkTransferSession {
        let transferID = UUID().uuidString
        let directory = transferDirectory(transferID: transferID)

        do {
            try FileManager.default.createDirectory(
                at: directory,
                withIntermediateDirectories: true
            )

            let source = try FileHandle(forReadingFrom: sourceURL)
            defer {
                try? source.close()
            }

            let sourceByteCount = ((try? FileManager.default.attributesOfItem(
                atPath: sourceURL.path
            )[.size]) as? NSNumber)?.intValue ?? 0
            let chunkSize = min(
                maximumChunkSize,
                max(
                    minimumChunkSize,
                    Int(ceil(Double(sourceByteCount) / Double(targetChunkCount)))
                )
            )
            var fileHasher = SHA256()
            var chunks: [WatchChunkTransferSession.Chunk] = []
            var totalByteCount = 0

            while let data = try source.read(upToCount: chunkSize), !data.isEmpty {
                fileHasher.update(data: data)
                let index = chunks.count
                let chunk = WatchChunkTransferSession.Chunk(
                    index: index,
                    byteCount: data.count,
                    hash: hash(data)
                )
                try data.write(
                    to: chunkURL(transferID: transferID, chunkIndex: index),
                    options: .atomic
                )
                chunks.append(chunk)
                totalByteCount += data.count
            }

            if chunks.isEmpty {
                let data = Data()
                fileHasher.update(data: data)
                try data.write(
                    to: chunkURL(transferID: transferID, chunkIndex: 0),
                    options: .atomic
                )
                chunks.append(
                    WatchChunkTransferSession.Chunk(
                        index: 0,
                        byteCount: 0,
                        hash: hash(data)
                    )
                )
            }

            let transferSession = WatchChunkTransferSession(
                transferID: transferID,
                recordingID: recordingID,
                totalByteCount: totalByteCount,
                fileHash: hex(fileHasher.finalize()),
                chunks: chunks,
                createdAt: .now,
                completedChunkIndices: [],
                retryCounts: [:],
                assemblyRetryCount: 0,
                isAwaitingImport: false,
                isFailed: false,
                failureMessage: nil
            )
            try save(transferSession)
            return transferSession
        } catch {
            try? FileManager.default.removeItem(at: directory)
            throw error
        }
    }

    static func loadSessions() -> [WatchChunkTransferSession] {
        let directories = (try? FileManager.default.contentsOfDirectory(
            at: rootDirectory,
            includingPropertiesForKeys: nil
        )) ?? []
        let failedSessionCutoff = Date().addingTimeInterval(-7 * 24 * 60 * 60)

        return directories.compactMap { directory in
            guard let data = try? Data(
                contentsOf: directory.appendingPathComponent(manifestName)
            ), let session = try? JSONDecoder().decode(
                WatchChunkTransferSession.self,
                from: data
            ) else {
                try? FileManager.default.removeItem(at: directory)
                return nil
            }
            if session.isFailed, session.createdAt < failedSessionCutoff {
                try? FileManager.default.removeItem(at: directory)
                return nil
            }
            return session
        }
    }

    static func save(_ session: WatchChunkTransferSession) throws {
        let directory = transferDirectory(transferID: session.transferID)
        try FileManager.default.createDirectory(
            at: directory,
            withIntermediateDirectories: true
        )
        let data = try JSONEncoder().encode(session)
        try data.write(
            to: directory.appendingPathComponent(manifestName),
            options: .atomic
        )
    }

    static func remove(transferID: String) throws {
        let directory = transferDirectory(transferID: transferID)
        guard FileManager.default.fileExists(atPath: directory.path) else {
            return
        }
        try FileManager.default.removeItem(at: directory)
    }

    static func chunkURL(transferID: String, chunkIndex: Int) -> URL {
        transferDirectory(transferID: transferID)
            .appendingPathComponent(String(format: "chunk-%06d.data", chunkIndex))
    }

    private static var rootDirectory: URL {
        FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        )[0].appendingPathComponent("WatchRecordingTransfers", isDirectory: true)
    }

    private static func transferDirectory(transferID: String) -> URL {
        rootDirectory.appendingPathComponent(transferID, isDirectory: true)
    }

    private static func hash(_ data: Data) -> String {
        hex(SHA256.hash(data: data))
    }

    private static func hex<Digest: Sequence>(_ digest: Digest) -> String
    where Digest.Element == UInt8 {
        digest.map { String(format: "%02x", $0) }.joined()
    }
}

private extension JSONEncoder {
    static var recordingTransfer: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .millisecondsSince1970
        return encoder
    }
}

private extension JSONDecoder {
    static var recordingTransfer: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .millisecondsSince1970
        return decoder
    }
}
