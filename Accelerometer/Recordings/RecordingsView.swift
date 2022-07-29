//
//  RecordingsView.swift
//  Accelerometer
//
//  Created by Andrey on 29.07.2022.
//

import SwiftUI

struct RecordingsView: View {
    @ObservedObject var recorder = Recorder.shared
    
    var body: some View {
        List {
            Section(header: Spacer()) {
                VStack {
                    Text("Recording now: \(String(recorder.recordingInProgress))")
                    Button.init(
                        "start / stop",
                        action: {
                            if recorder.recordingInProgress {
                                recorder.stopRecording()
                            } else {
                                recorder.record(measurements: [.acceleration])
                            }
                        }
                    )
                    .padding()
                }
                .padding()
            }
            Section(header: Text("Last recordings")) {
                ForEach(recorder.recordings) { recording in
                    Text(recording.id)
                }
            }
        }
    }
}

struct RecordingsView_Previews: PreviewProvider {
    static var previews: some View {
        RecordingsView()
    }
}
