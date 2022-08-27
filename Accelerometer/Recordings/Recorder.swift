//
//  Recorder.swift
//  Accelerometer
//
//  Created by Andrey on 29.07.2022.
//

import Combine
import SwiftUI

class Recorder: ObservableObject {
    static let shared = Recorder()
    // private init() { }
    
    @ObservedObject private var measurer = Measurer.shared
    private let repository = RecordingsRepository()
    private let disableIdleTimer = true
    
    @Published private (set) var activeRecording: Recording? = nil
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
        }
        
        activeRecording = nil
        cancelSubscriptions()
    }
    
    func delete(recordingID: String) {
        repository.delete(recordingID: recordingID)
        objectWillChange.send()
    }
    
    private func subscribeForChanges(of measurementType: MeasurementType) {
        switch measurementType {
        case .acceleration:
            subscriptions.append(measurer.acceleration?.objectWillChange.sink { [ weak self ] in
                self?.save(value: self?.measurer.acceleration?.properties, of: .acceleration)
            })
        case .rotation:
            subscriptions.append(measurer.rotation?.objectWillChange.sink { [ weak self ] in
                self?.save(value: self?.measurer.rotation?.properties, of: .rotation)
            })
        case .deviceMotion:
            subscriptions.append(measurer.deviceMotion?.objectWillChange.sink { [ weak self ] in
                self?.save(value: self?.measurer.deviceMotion?.properties, of: .deviceMotion)
            })
        case .magneticField:
            subscriptions.append(measurer.magneticField?.objectWillChange.sink { [ weak self ] in
                self?.save(value: self?.measurer.magneticField?.properties, of: .magneticField)
            })
        }
    }
    
    private func save(value: Axes?, of type: MeasurementType) {
        let newEntry = Recording.Entry(measurementType: type, date: Date(), value: value)
        
        activeRecording?.entries.append(newEntry)
        
        guard let activeRecording = activeRecording else {
            return
        }
        
//        repository.save([activeRecording])
    }
    
    private func cancelSubscriptions() {
        subscriptions = []
    }
}
