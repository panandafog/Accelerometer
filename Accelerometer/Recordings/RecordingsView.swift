//
//  RecordingsView.swift
//  Accelerometer
//
//  Created by Andrey on 29.07.2022.
//

import SwiftUI

struct RecordingsView: View {
    
    @EnvironmentObject var recorder: Recorder
    
    @State var presentingNewRecordingSheet = false
    
    var recordingTitle: String {
        if recorder.recordingInProgress {
            return "Recording in progress"
        } else {
            return "Start new recording"
        }
    }
    
    var secondaryRecordingTitle: String? {
        if recorder.recordingInProgress {
            return "Do not close the app"
        } else {
            return nil
        }
    }
    
    var startStopButtonImage: some View {
        if recorder.recordingInProgress {
            return Image(systemName: "stop.fill")
        } else {
            return Image(systemName: "play.fill")
        }
    }
    
    var startStopButton: some View {
        Button(
            action: {
                if recorder.recordingInProgress {
                    recorder.stopRecording()
                } else {
                    presentingNewRecordingSheet = true
                }
            },
            label: {
                startStopButtonImage
                    .padding(13)
                    .foregroundColor(Color.background)
                    .background(Color.accentColor)
                    .clipShape(Circle())
                    .font(.title2)
            }
        )
    }
    
    var activeRecording: Recording? {
        guard let firstRecording = recorder.recordings.first else {
            return nil
        }
        if firstRecording.state == .inProgress {
            return firstRecording
        } else {
            return nil
        }
    }
    
    var lastRecordings: [Recording] {
        var recordings = recorder.recordings
        if activeRecording != nil {
            recordings.removeFirst()
        }
        return recordings
    }
    
    func recordingView(recording: Recording) -> some View {
        switch recording.state {
        case .completed:
            return AnyView(completedRecordingView(recording: recording))
        case .inProgress:
            return AnyView(activeRecordingView(recording: recording))
        }
    }
    
    func activeRecordingView(recording: Recording) -> some View {
        RecordingPreview(recording: recording)
            .padding(.vertical)
    }
    
    func completedRecordingView(recording: Recording) -> some View {
        NavigationLink {
            RecordingSummaryView(recording: recording)
        } label: {
            RecordingPreview(recording: recording)
                .padding(.vertical)
        }
    }
    
    var body: some View {
        List {
            Section(header: Spacer()) {
                HStack {
                    ZStack(alignment: .topLeading) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(recordingTitle)
                                .font(.title2)
                            if let secondaryRecordingTitle = secondaryRecordingTitle {
                                Text(secondaryRecordingTitle)
                                    .font(.footnote)
                                    .padding([.leading])
                                    .foregroundColor(Color.secondary)
                            }
                        }
                        Color.clear
                    }
                    .padding(.vertical)
                    Spacer()
                    startStopButton
                        .padding(.vertical)
                }
            }
            if let activeRecording = activeRecording {
                Section(header: Text("Recording in progress")) {
                    recordingView(recording: activeRecording)
                }
            }
            if !lastRecordings.isEmpty {
                Section(header: Text("Last recordings")) {
                    ForEach(lastRecordings) { recording in
                        recordingView(recording: recording)
                    }
                }
            }
        }
        .sheet(isPresented: $presentingNewRecordingSheet) {
            NewRecordingView()
        }
    }
}

struct RecordingsView_Previews: PreviewProvider {
    
    static let settings = Settings()
    static let measurer = Measurer(settings: settings)
    
    static let recorder: Recorder = {
        let recorder = Recorder(measurer: measurer)
        recorder.record(measurements: [.acceleration, .userAcceleration])
        recorder.stopRecording()
        recorder.record(measurements: [.magneticField])
        return recorder
    }()
    
    static var previews: some View {
        RecordingsView()
            .environmentObject(recorder)
    }
}
