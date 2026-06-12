//
//  Recorder.swift
//  Accelerometer
//
//  Created by Andrey on 29.07.2022.
//

import DequeModule
import Combine
import SwiftUI

@MainActor
class Recorder: ObservableObject {
    
    private static let memoryCheckCooldownNs: UInt64 = 5_000_000_000
    
    @Published var isInEditMode = false
    @Published var hasEnoughMemory = true
    
    @Published private(set) var recordingsMetadata: [Recording] = []
    @Published private(set) var activeRecording: Recording? = nil
    private var activeRecordingEntries: Deque<Recording.Entry> = []
    private var isStoppingRecording = false
    
    @ObservedObject private var measurer: Measurer
    @ObservedObject private var settings: Settings
    
    private let repository = RecordingsRepository()
    private let memoryMonitor = MemoryMonitor()
    private let transferReceiver = PhoneRecordingTransferReceiver()
    
    private let disableIdleTimer = true
    private var subscriptions: [AnyCancellable] = []
    private var backgroundTaskID: UIBackgroundTaskIdentifier = .invalid

    private var watchRecordingIDs: Set<String> {
        get {
            Set(UserDefaults.standard.stringArray(forKey: StorageKey.watchRecordingIDs) ?? [])
        }
        set {
            UserDefaults.standard.set(Array(newValue), forKey: StorageKey.watchRecordingIDs)
        }
    }
    
    init(measurer: Measurer, settings: Settings) {
        self.measurer = measurer
        self.settings = settings
        
        Task {
            await refreshRecordings()
        }
        Task {
            await watchFreeSpace()
        }

        transferReceiver.onRecordingReceived = { [weak self] data in
            Task { @MainActor in
                await self?.importTransferredRecording(data)
            }
        }
        transferReceiver.activate()
    }
    
    var recordingInProgress: Bool {
        activeRecording != nil
    }
    
    // MARK: - Recordings management
    
    func record(measurements types: Set<MeasurementType>) {
        guard hasEnoughMemory, !recordingInProgress, !types.isEmpty else {
            return
        }

        if disableIdleTimer {
            UIApplication.shared.isIdleTimerDisabled = true
        }
        beginRecordingBackgroundTask()

        activeRecording = Recording(
            entries: [],
            state: .inProgress,
            measurementTypes: types
        )
        activeRecordingEntries = []

        types.forEach(subscribeForChanges)

        objectWillChange.send()
    }
    
    func stopRecording() {
        guard !isStoppingRecording, activeRecording != nil else {
            return
        }
        isStoppingRecording = true

        Task {
            guard var activeRecording = activeRecording else { return }
            activeRecording.state = .completed
            activeRecording.end = Date.now
            activeRecording.entries = Array(activeRecordingEntries)
            
#if (DEBUG)
            print("--- Recording stopped ---")
            for measurementType in activeRecording.sortedMeasurementTypes {
                let count = activeRecordingEntries.filter { $0.measurementType == measurementType }.count
                print("\(measurementType.name): \(count) entries")
            }
            let totalCount = activeRecordingEntries.count
            print("Total entries: \(totalCount)")
            print("-------------------------")
#endif
            
            activeRecordingEntries = []
            
            await repository.save([activeRecording])
            await repository.updateMetadata()
            await refreshRecordings()
            
            await MainActor.run {
                self.activeRecording = nil
                subscriptions.removeAll()
                objectWillChange.send()
            }

            await MainActor.run {
                finishRecordingRuntime()
                isStoppingRecording = false
            }
        }
    }
    
    func delete(recordingID: String) {
        Task {
            await repository.delete(recordingID: recordingID)
            watchRecordingIDs.remove(recordingID)
            await repository.updateMetadata()
            await refreshRecordings()
        }
    }
    
    func delete(recordingIDs: [String]) {
        Task {
            await repository.delete(recordingIDs: recordingIDs)
            watchRecordingIDs.subtract(recordingIDs)
            await repository.updateMetadata()
            await refreshRecordings()
        }
    }
    
    func loadFullRecording(id: String) async -> Recording? {
        guard var recording = await repository.loadFullRecording(id: id) else {
            return nil
        }

        recording.source = source(for: id)
        return recording
    }
    
    private func subscribeForChanges(of type: MeasurementType) {
        guard let obs = measurer.observableAxes[type] else { return }
        
        let sub = obs.objectWillChange.sink { [weak self] in
            self?.appendEntry(for: type)
        }
        subscriptions.append(sub)
    }
    
    private func appendEntry(for type: MeasurementType) {
        guard
            let axes = measurer.observableAxes[type]?.axes,
            activeRecording != nil,
            hasEnoughMemory
        else { return }
        
        activeRecordingEntries.append(
            Recording.Entry(
                measurementType: type,
                date: Date(),
                axes: axes
            )
        )
    }
    
    private func refreshRecordings() async {
        await repository.updateMetadata()
        let stored = await repository.recordingsMetadata
        await MainActor.run {
            recordingsMetadata = Array(stored.values)
                .map { recording in
                    var recording = recording
                    recording.source = source(for: recording.id)
                    return recording
                }
                .sorted { $0.start > $1.start }
        }
    }

    private func importTransferredRecording(_ data: Data) async {
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .millisecondsSince1970
            let payload = try decoder.decode(
                RecordingTransferPayload.self,
                from: data
            )
            let recording = try payload.recording()

            await repository.save([recording])
            watchRecordingIDs.insert(recording.id)
            await refreshRecordings()
            transferReceiver.acknowledge(recordingID: recording.id)
        } catch {
            print("Watch recording import failed:", error)
        }
    }

    private func source(for recordingID: String) -> Recording.Source {
        watchRecordingIDs.contains(recordingID) ? .appleWatch : .iPhone
    }
    
    // MARK: - Memory control
    
    private func watchFreeSpace() async {
        while true {
            await checkMemory()
            
            try? await Task.sleep(
                nanoseconds: Self.memoryCheckCooldownNs
            )
        }
    }
    
    private func checkMemory() async {
#if (DEBUG)
        let hasEnoughMemory = if settings.alwaysNotEnoughMemory {
            false
        } else {
            await hasEnoughMemory()
        }
#else
        let hasEnoughMemory = await hasEnoughMemory()
#endif
        
        if !hasEnoughMemory {
            await MainActor.run { stopRecording() }
        }
        
        await MainActor.run { self.hasEnoughMemory = hasEnoughMemory }
    }
    
    
    private func hasEnoughMemory() async -> Bool {
        let freeMB = await memoryMonitor.freeSpaceMB()
        let hasEnoughMemory = freeMB >= Double(Settings.minFreeSpaceMB)
        return hasEnoughMemory
    }
    
    // MARK: - Recording runtime

    private func beginRecordingBackgroundTask() {
        endRecordingBackgroundTask()
        backgroundTaskID = UIApplication.shared.beginBackgroundTask(
            withName: "Finish sensor recording"
        ) { [weak self] in
            Task { @MainActor in
                self?.stopRecording()
            }
        }
    }

    private func finishRecordingRuntime() {
        if disableIdleTimer {
            UIApplication.shared.isIdleTimerDisabled = false
        }
        endRecordingBackgroundTask()
    }

    private func endRecordingBackgroundTask() {
        guard backgroundTaskID != .invalid else {
            return
        }

        UIApplication.shared.endBackgroundTask(backgroundTaskID)
        backgroundTaskID = .invalid
    }
    
    // MARK: - Debug
    
#if (DEBUG)
    func createDebugSamples() {
        Task {
            await repository.save(
                PreviewUtils.allSampleCompletedRecordings
            )
            await refreshRecordings()
            await MainActor.run {
                objectWillChange.send()
            }
        }
    }
#endif

    private enum StorageKey {
        static let watchRecordingIDs = "watchRecordingIDs"
    }
}
