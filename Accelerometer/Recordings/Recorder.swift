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
    
    @Published private (set) var activeRecording: Recording? = nil
    var recordingInProgress: Bool {
        activeRecording != nil
    }
    
    var recordings: [Recording] {
        repository.recordings
    }
    
    private var subscriptions: [AnyCancellable?] = []
    
    func record(measurements measurementTypes: [MeasurementType]) {
        guard !recordingInProgress, !measurementTypes.isEmpty else {
            return
        }
        
        activeRecording = Recording(entries: [], state: .inProgress, measuremntTypes: measurementTypes)
        
        for type in measurementTypes {
            subscribeForChanges(of: type)
        }
    }
    
    func stopRecording() {
        guard recordingInProgress else {
            return
        }
        
        if var activeRecording = activeRecording {
            activeRecording.state = .completed
            repository.save(recording: activeRecording)
        }
        
        activeRecording = nil
        cancelSubscriptions()
    }
    
    func delete(recordingID: String) {
        repository.delete(recordingID: recordingID)
    }
    
    private func subscribeForChanges(of measurementType: MeasurementType) {
        switch measurementType {
        case .acceleration:
            subscriptions.append(measurer.acceleration?.objectWillChange.sink { [ weak self ] in
                self?.save(value: self?.measurer.acceleration, of: .acceleration)
            })
        case .rotation:
            subscriptions.append(measurer.rotation?.objectWillChange.sink { [ weak self ] in
                self?.save(value: self?.measurer.rotation, of: .rotation)
            })
        case .deviceMotion:
            subscriptions.append(measurer.deviceMotion?.objectWillChange.sink { [ weak self ] in
                self?.save(value: self?.measurer.deviceMotion, of: .deviceMotion)
            })
        case .magneticField:
            subscriptions.append(measurer.magneticField?.objectWillChange.sink { [ weak self ] in
                self?.save(value: self?.measurer.magneticField, of: .magneticField)
            })
        }
    }
    
    private func save(value: Axes?, of type: MeasurementType) {
        let newEntry = Recording.Entry(measurementType: type, date: Date(), value: value)
        activeRecording?.entries.append(newEntry)
        
        guard let activeRecording = activeRecording else {
            return
        }
        repository.save(recording: activeRecording)
    }
    
    private func cancelSubscriptions() {
        subscriptions = []
    }
}
