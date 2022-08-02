//
//  RecordingsView.swift
//  Accelerometer
//
//  Created by Andrey on 29.07.2022.
//

import SwiftUI

struct RecordingsView: View {
    
    @ObservedObject var recorder = Recorder.shared
    
    @State var presentingNewRecordingSheet = false
    
    var recordingTitle: String {
        if recorder.recordingInProgress {
            return "Recording in progress"
        } else {
            return "Start new recording"
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
    
    func recordingView(recording: Recording) -> some View {
        switch recording.state {
        case .completed:
            return AnyView(completedRecordingView(recording: recording))
        case .inProgress:
            return AnyView(activeRecordingView(recording: recording))
        }
    }
    
    func activeRecordingView(recording: Recording) -> some View {
        Text("in progress")
    }
    
    func completedRecordingView(recording: Recording) -> some View {
        NavigationLink {
            RecordingView(recording: recording)
        } label: {
            RecordingSummaryView(recording: recording)
                .padding(.vertical)
        }
    }
    
    var body: some View {
        List {
            Section(header: Spacer()) {
                HStack {
                    ZStack(alignment: .topLeading) {
                        Text(recordingTitle)
                            .font(.title2)
                        Color.clear
                    }
                    .padding(.vertical)
                    Spacer()
                    startStopButton
                        .padding(.vertical)
                }
            }
            Section(header: Text("Last recordings")) {
                ForEach(recorder.recordings) { recording in
                    recordingView(recording: recording)
                }
            }
        }
        .sheet(isPresented: $presentingNewRecordingSheet) {
            NewRecordingView()
        }
    }
}

struct RecordingsView_Previews: PreviewProvider {
    
    static let recorder1: Recorder = {
       let recorder = Recorder()
        recorder.record(measurements: [.acceleration, .deviceMotion])
        recorder.stopRecording()
        recorder.record(measurements: [.magneticField])
        return recorder
    }()
    
    static var previews: some View {
        RecordingsView(recorder: recorder1)
    }
}
