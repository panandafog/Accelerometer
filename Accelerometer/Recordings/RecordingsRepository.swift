//
//  RecordingsRepository.swift
//  Accelerometer
//
//  Created by Andrey on 29.07.2022.
//

import SwiftUI

class RecordingsRepository: ObservableObject {
    
    private (set) var recordings: [Recording] = []
    
    func saveRecording(_ newRecording: Recording) {
        if let index = recordings.firstIndex(where: { $0.id == newRecording.id }) {
            recordings[index] = newRecording
        } else {
            recordings.append(newRecording)
        }
    }
}
