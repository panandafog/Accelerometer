//
//  WatchRecorder.swift
//  Accelerometer Watch Watch App
//
//  Created by OpenAI on 07.06.2026.
//

import Combine
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
    @Published var lastTransferError: String?

    private let measurer: Measurer
    private let session: WCSession?
    private var subscriptions: [MeasurementType: AnyCancellable] = [:]
    private var measurerSubscription: AnyCancellable?
    private var activeEntries: [RecordingTransferPayload.Entry] = []
    private var extendedRuntimeSession: WKExtendedRuntimeSession?
    private var activeFileTransfers: [String: WCSessionFileTransfer] = [:]
    private var transferProgressTimer: AnyCancellable?

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
              let recording = recordings.first(where: { $0.id == recordingID }) else {
            lastTransferError = "Recording is unavailable"
            return
        }

        guard session.isCompanionAppInstalled else {
            lastTransferError = "Install the iPhone app first"
            return
        }

        lastTransferError = nil
        transferringIDs.insert(recordingID)
        let transfer = session.transferFile(
            recording.fileURL,
            metadata: [TransferKey.recordingID: recordingID]
        )
        activeFileTransfers[recordingID] = transfer
        updateTransferProgress()
        startTransferProgressUpdates()
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
        activeFileTransfers.removeValue(forKey: recordingID)
        transferProgress.removeValue(forKey: recordingID)
        stopTransferProgressUpdatesIfNeeded()
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
        activeFileTransfers.removeValue(forKey: recordingID)
        transferProgress.removeValue(forKey: recordingID)
        stopTransferProgressUpdatesIfNeeded()
        var updatedTransferredIDs = transferredIDs
        updatedTransferredIDs.insert(recordingID)
        transferredIDs = updatedTransferredIDs
    }

    private func restoreOutstandingTransfers() {
        guard let session else {
            return
        }

        for transfer in session.outstandingFileTransfers {
            guard let recordingID = transfer.file.metadata?[TransferKey.recordingID] as? String else {
                continue
            }

            activeFileTransfers[recordingID] = transfer
            transferringIDs.insert(recordingID)
        }

        updateTransferProgress()
        startTransferProgressUpdates()
    }

    private func startTransferProgressUpdates() {
        guard !activeFileTransfers.isEmpty, transferProgressTimer == nil else {
            return
        }

        transferProgressTimer = Timer.publish(
            every: 0.25,
            on: .main,
            in: .common
        )
        .autoconnect()
        .sink { [weak self] _ in
            self?.updateTransferProgress()
        }
    }

    private func updateTransferProgress() {
        for (recordingID, transfer) in activeFileTransfers {
            transferProgress[recordingID] = min(
                1,
                max(0, transfer.progress.fractionCompleted)
            )
        }
    }

    private func stopTransferProgressUpdatesIfNeeded() {
        guard activeFileTransfers.isEmpty else {
            return
        }

        transferProgressTimer?.cancel()
        transferProgressTimer = nil
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
    }
}

extension WatchRecorder: WCSessionDelegate {
    nonisolated func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) { }

    nonisolated func session(
        _ session: WCSession,
        didFinish fileTransfer: WCSessionFileTransfer,
        error: Error?
    ) {
        guard let recordingID = fileTransfer.file.metadata?[TransferKey.recordingID] as? String else {
            return
        }

        Task { @MainActor [weak self] in
            self?.transferringIDs.remove(recordingID)
            self?.activeFileTransfers.removeValue(forKey: recordingID)
            self?.transferProgress.removeValue(forKey: recordingID)
            self?.stopTransferProgressUpdatesIfNeeded()
            if let error {
                self?.lastTransferError = error.localizedDescription
            }
        }
    }

    nonisolated func session(
        _ session: WCSession,
        didReceiveUserInfo userInfo: [String: Any] = [:]
    ) {
        guard let recordingID = userInfo[TransferKey.importedRecordingID] as? String else {
            return
        }

        Task { @MainActor [weak self] in
            self?.markTransferred(recordingID: recordingID)
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
