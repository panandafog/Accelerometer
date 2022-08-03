//
//  RecordingsRepository.swift
//  Accelerometer
//
//  Created by Andrey on 29.07.2022.
//

import SwiftUI

class RecordingsRepository: ObservableObject {
    
    private (set) var recordings: [Recording] = []
    
    func save(recording newRecording: Recording) {
        if let index = recordings.firstIndex(where: { $0.id == newRecording.id }) {
            recordings[index] = newRecording
        } else {
            recordings.insert(newRecording, at: 0)
        }
    }
    
    func delete(recordingID: String) {
        recordings.removeAll { recording in
            recording.id == recordingID
        }
    }
}
