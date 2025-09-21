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
    @Published var isInEditMode = false
    @Published private(set) var recordings: [Recording] = []
    @Published private(set) var activeRecording: Recording? = nil
    
    @ObservedObject private var measurer: Measurer
    private let repository = RecordingsRepository()
    private let memoryMonitor = MemoryMonitor()
    
    private let disableIdleTimer = true
    private var subscriptions: [AnyCancellable] = []
    
    init(measurer: Measurer) {
        self.measurer = measurer
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
    
    func record(measurements types: Set<MeasurementType>) {
        Task {
            if await !hasEnoughMemory() { return }
            
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
            
            guard let current = activeRecording else { return }
            
            var completed = current
            completed.state = .completed
            
            await repository.save([completed])
            await repository.update()
            await refreshRecordings()
            
            await MainActor.run {
                activeRecording = nil
                subscriptions.removeAll()
                objectWillChange.send()
            }
        }
    }
    
    func delete(recordingID: String) {
        Task {
            await repository.delete(recordingID: recordingID)
            await repository.update()
            await refreshRecordings()
        }
    }
    
    func delete(recordingIDs: [String]) {
        Task {
            await repository.delete(recordingIDs: recordingIDs)
            await repository.update()
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
            if await !hasEnoughMemory() { return }
            
            guard let axes = measurer.observableAxes[type]?.axes,
                  var current = activeRecording
            else { return }
            
            let entry = Recording.Entry(
                measurementType: type,
                date: Date(),
                axes: axes
            )
            current.entries.append(entry)
            
            await MainActor.run {
                activeRecording = current
                objectWillChange.send()
            }
        }
    }
    
    private func watchFreeSpace() async {
        while true {
            try? await Task.sleep(nanoseconds: 10_000_000_000)
            
            if await !hasEnoughMemory() {
                await MainActor.run { stopRecording() }
            }
        }
    }
    
    private func refreshRecordings() async {
        await repository.update()
        let stored = await repository.recordings
        var list = stored
        if let current = activeRecording {
            list.insert(current, at: 0)
        }
        
        await MainActor.run { recordings = list }
    }
    
    private func hasEnoughMemory() async -> Bool {
        let freeMB = await memoryMonitor.freeSpaceMB()
        return freeMB >= Double(Settings.minFreeSpaceMB)
    }
}
