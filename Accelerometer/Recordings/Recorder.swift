//
//  Recorder.swift
//  Accelerometer
//
//  Created by Andrey on 29.07.2022.
//

import Combine
import SwiftUI

@MainActor
class Recorder: ObservableObject {
    
    private static let memoryCheckCooldownNs: UInt64 = 5_000_000_000
    
    @Published var isInEditMode = false
    @Published var hasEnoughMemory = true
    
    @Published private(set) var recordingsMetadata: [Recording] = []
    @Published private(set) var activeRecording: Recording? = nil
    
    @ObservedObject private var measurer: Measurer
    @ObservedObject private var settings: Settings
    
    private let repository = RecordingsRepository()
    private let memoryMonitor = MemoryMonitor()
    
    private let disableIdleTimer = true
    private var subscriptions: [AnyCancellable] = []
    
    init(measurer: Measurer, settings: Settings) {
        self.measurer = measurer
        self.settings = settings
        
        Task {
            await refreshRecordings()
        }
        Task {
            await watchFreeSpace()
        }
    }
    
    var recordingInProgress: Bool {
        activeRecording != nil
    }
    
    // MARK: - Recordings management
    
    func record(measurements types: Set<MeasurementType>) {
        Task {
            if !hasEnoughMemory { return }
            
            await MainActor.run {
                if disableIdleTimer {
                    UIApplication.shared.isIdleTimerDisabled = true
                }
                
                guard !recordingInProgress, !types.isEmpty else { return }
                activeRecording = Recording(
                    entries: [],
                    state: .inProgress,
                    measurementTypes: types
                )
                
                types.forEach(subscribeForChanges)
                
                objectWillChange.send()
            }
        }
    }
    
    func stopRecording() {
        Task {
            await MainActor.run {
                if disableIdleTimer {
                    UIApplication.shared.isIdleTimerDisabled = false
                }
            }
            
            guard var activeRecording = activeRecording else { return }
            activeRecording.state = .completed
            activeRecording.end = Date.now
            
            await repository.save([activeRecording])
            await repository.updateMetadata()
            await refreshRecordings()
            
            await MainActor.run {
                self.activeRecording = nil
                subscriptions.removeAll()
                objectWillChange.send()
            }
        }
    }
    
    func delete(recordingID: String) {
        Task {
            await repository.delete(recordingID: recordingID)
            await repository.updateMetadata()
            await refreshRecordings()
        }
    }
    
    func delete(recordingIDs: [String]) {
        Task {
            await repository.delete(recordingIDs: recordingIDs)
            await repository.updateMetadata()
            await refreshRecordings()
        }
    }
    
    private func subscribeForChanges(of type: MeasurementType) {
        guard let obs = measurer.observableAxes[type] else { return }
        
        let sub = obs.objectWillChange.sink { [weak self] in
            self?.appendEntry(for: type)
        }
        subscriptions.append(sub)
    }
    
    private func appendEntry(for type: MeasurementType) {
        Task {
            if !hasEnoughMemory { return }
            
            guard let axes = measurer.observableAxes[type]?.axes,
                  var current = activeRecording
            else { return }
            
            let entry = Recording.Entry(
                measurementType: type,
                date: Date(),
                axes: axes
            )
            
            if current.entries == nil {
                current.entries = []
            }
            current.entries?.append(entry)
            
            await MainActor.run {
                activeRecording = current
                objectWillChange.send()
            }
        }
    }
    
    private func refreshRecordings() async {
        await repository.updateMetadata()
        let stored = await repository.recordingsMetadata
        await MainActor.run { recordingsMetadata = stored }
    }
    
    // MARK: -  Recordings cache menagement
    
    func loadFullRecording(id: String) async -> Recording? {
        return await repository.loadFullRecording(id: id)
    }
    
    func clearRecordingCache(id: String) async {
        await repository.clearCache(for: id)
    }
    
    func clearAllRecordingCache() async {
        await repository.clearAllCache()
    }
    
    func getCacheSize() async -> Int {
        return await repository.cacheSize
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
}
