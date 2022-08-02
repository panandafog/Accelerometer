//
//  RecordingSummaryView.swift
//  Accelerometer
//
//  Created by Andrey on 30.07.2022.
//

import SwiftUI

struct RecordingSummaryView: View {
    
    let recording: Recording
    @ObservedObject var recorder: Recorder = .shared
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var isPresentingDeleteConfirmation: Bool = false
    
    let deleteAlertTitleText = "Are you sure?"
    
    func string(from date: Date?) -> String? {
        guard let date = date else {
            return nil
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd yyyy, HH:mm:ss.SSS"
        
        return dateFormatter.string(from: date)
    }
    
    var entriesView: some View {
        List {
            Section(header: Text("Info")) {
                RecordingPreview(recording: recording)
                    .padding(.vertical)
            }
            Section(header: Text("Records")) {
                ForEach(recording.entries) { entry in
                    VStack(alignment: .leading) {
                        Text(entry.measurementType.name)
                            .padding(.top)
                            .font(.title2)
                        if let axes = entry.value {
                            Text(String(axes.vector))
                                .padding(.top)
                                .font(.title2)
                            Text(String(axes.x))
                                .padding(.top)
                            Text(String(axes.y))
                                .padding(.top)
                            Text(String(axes.z))
                                .padding(.top)
                        }
                        Text(string(from: entry.date) ?? "???")
                            .padding(.vertical)
                    }
                }
            }
        }
    }
    
    var body: some View {
        VStack {
            entriesView
        }
        .navigationTitle("Recording")
        .toolbar {
            Button("Delete") {
                isPresentingDeleteConfirmation = true
            }
        }
        .modify {
            if #available(iOS 15.0, *) {
                $0.confirmationDialog(
                    deleteAlertTitleText,
                    isPresented: $isPresentingDeleteConfirmation
                ) {
                    Button("Delete", role: .destructive) {
                        deleteRecording()
                    }
                }
            } else {
                $0.alert(isPresented: $isPresentingDeleteConfirmation) {
                    Alert(
                        title: Text(deleteAlertTitleText),
                        primaryButton: .destructive(
                            Text("Delete"),
                            action: {
                                deleteRecording()
                            }
                        ),
                        secondaryButton: .cancel(
                            Text("Cancel"),
                            action: { }
                        )
                    )
                }
            }
        }
    }
    
    func deleteRecording() {
        recorder.delete(recordingID: recording.id)
        presentationMode.wrappedValue.dismiss()
    }
}

struct RecordingView_Previews: PreviewProvider {
    static var previews: some View {
        RecordingSummaryView(
            recording: Recording(
                entries: [
                    .init(
                        measurementType: .acceleration,
                        date: .init(),
                        value: Axes.getZero(displayableAbsMax: 1.0)
                    )
                ],
                state: .completed,
                measurementTypes: [.acceleration]
            ),
            recorder: .shared
        )
    }
}
