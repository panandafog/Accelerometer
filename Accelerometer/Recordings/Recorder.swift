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
    @ObservedObject private var measurer: Measurer
    
    private let repository: RecordingsRepository = {
        let repository = RecordingsRepository()
        repository.update()
        return repository
    }()
    
    private let disableIdleTimer = true
    
    private(set) var activeRecording: Recording? = nil
    var recordingInProgress: Bool {
        activeRecording != nil
    }
    
    var recordings: [Recording] {
        var savedRecordings = repository.recordings
        if let activeRecording = activeRecording {
            savedRecordings.insert(activeRecording, at: 0)
        }
        return savedRecordings
    }
    
    private var subscriptions: [AnyCancellable?] = []
    
    init(measurer: Measurer) {
        self.measurer = measurer
    }
    
    func record(measurements measurementTypes: Set<MeasurementType>) {
        if disableIdleTimer {
            UIApplication.shared.isIdleTimerDisabled = true
        }
        
        guard !recordingInProgress, !measurementTypes.isEmpty else {
            return
        }
        
        let newRecording = Recording(entries: [], state: .inProgress, measurementTypes: measurementTypes)
        activeRecording = newRecording
//        repository.save([newRecording])
        
        for type in measurementTypes {
            subscribeForChanges(of: type)
        }
    }
    
    func stopRecording() {
        if disableIdleTimer {
            UIApplication.shared.isIdleTimerDisabled = false
        }
        
        guard recordingInProgress else {
            return
        }
        
        if var activeRecording = activeRecording {
            activeRecording.state = .completed
            repository.save([activeRecording])
            repository.update()
        }
        
        activeRecording = nil
        cancelSubscriptions()
        
        objectWillChange.send()
    }
    
    func delete(recordingID: String) {
        repository.delete(recordingID: recordingID)
        repository.update()
        
        objectWillChange.send()
    }
    
    func delete(recordingIDs: [String]) {
        repository.delete(recordingIDs: recordingIDs)
        repository.update()
        
        objectWillChange.send()
    }
    
    private func subscribeForChanges(of measurementType: MeasurementType) {
        let newSubsription = measurer.observableAxes[measurementType]?.objectWillChange.sink { [ weak self ] in
            self?.save(axes: self?.measurer.observableAxes[measurementType]?.axes, of: measurementType)
        }
        subscriptions.append(newSubsription)
    }
    
    private func save(axes: (any Axes)?, of type: MeasurementType) {
        guard let axes = axes else { return }
        save(axes: axes, of: type)
    }
    
    private func save(axes: any Axes, of type: MeasurementType) {
        let newEntry = Recording.Entry(measurementType: type, date: Date(), axes: axes)
        activeRecording?.entries.append(newEntry)
        
        objectWillChange.send()
    }
    
    private func cancelSubscriptions() {
        subscriptions = []
    }
}
