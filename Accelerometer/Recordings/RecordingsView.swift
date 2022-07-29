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
        VStack {
            Text("Active recording: \(String(recorder.recordingInProgress))")
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
        }
    }
}

struct RecordingsView_Previews: PreviewProvider {
    static var previews: some View {
        RecordingsView()
    }
}
