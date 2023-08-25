//
//  LiveActivitiesService.swift
//  Accelerometer
//
//  Created by Andrey on 16.04.2023.
//

import Foundation
import ActivityKit

class LiveActivitiesService {
    private var activityStartTime: Date?
    private var activityUpdateTimer: Timer?
    private var recordingActivity: Activity<RecordingWidgetAttributes>?
    
    private var recordingActivityState: RecordingWidgetAttributes.ContentState? {
        guard let activity = recordingActivity else { return nil }
        guard let start = activityStartTime else { return nil }
        return RecordingWidgetAttributes.ContentState(start: start)
    }
    
    private var recordingActivityStaleDate: Date? {
        Calendar.current.date(byAdding: .hour, value: 3, to: Date())
    }
    
    @available(iOS 16.1, *)
    func startRecordingActivity(recording: Recording) {
        let recordingActivityAttributes = RecordingWidgetAttributes(measurementTypes: recording.sortedMeasurementTypes)
        let recordingActivityState = RecordingWidgetAttributes.ContentState()
        activityStartTime = Date()
        
        do {
            recordingActivity = try Activity<RecordingWidgetAttributes>.request(
                attributes: recordingActivityAttributes,
                contentState: recordingActivityState
            )
            startActivityUpdates()
        } catch (let error) {
            print("Error requesting Live Activity \(error.localizedDescription)")
        }
    }
    
    @available(iOS 16.1, *)
    func updateRecordingActivity(
        state: RecordingWidgetAttributes.ContentState? = nil
    ) {
        guard let activity = recordingActivity else { return }
        guard let state = state ?? recordingActivityState else { return }
        Task {
            await activity.update(using: state)
        }
    }
    
    @available(iOS 16.1, *)
    func stopRecordingActivity(
        state: RecordingWidgetAttributes.ContentState? = nil
    ) {
        guard let activity = recordingActivity else { return }
        Task {
            await activity.end(dismissalPolicy: .immediate)
        }
        stopActivityUpdates()
    }
    
    private func startActivityUpdates() {
        activityUpdateTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [ weak self ] _ in
            self?.updateRecordingActivity()
        }
    }
    
    private func stopActivityUpdates() {
        activityUpdateTimer?.invalidate()
        activityUpdateTimer = nil
        activityStartTime = nil
        recordingActivity = nil
    }
}
