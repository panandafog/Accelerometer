//
//  ActiveRecordingManager.swift
//  Accelerometer
//
//  Created by Andrey Pantyuhin on 25.09.2025.
//

import Foundation

// TODO: refactor this and save active recorgding in persist memory
actor ActiveRecordingManager {
    private(set) var activeRecording: Recording?
    
    func startRecording(_ recording: Recording) {
        activeRecording = recording
    }
    
    func appendEntry(_ entry: Recording.Entry) -> Recording? {
        guard var current = activeRecording else {
            return nil
        }
        
        if current.entries == nil {
            current.entries = []
        }
        current.entries?.append(entry)
        activeRecording = current
        
        return current
    }
    
    func stopRecording() -> Recording? {
        guard var current = activeRecording else {
            return nil
        }
        
        current.state = .completed
        current.end = Date.now
        activeRecording = nil
        
        return current
    }
}
