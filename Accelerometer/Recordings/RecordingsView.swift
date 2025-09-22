//
//  RecordingsView.swift
//  Accelerometer
//
//  Created by Andrey on 29.07.2022.
//

import SwiftUI

struct RecordingsView: View {
    
    @EnvironmentObject var recorder: Recorder
    
    @State private var presentingNewRecordingSheet = false
    @State private var isEditMode = false
    @State private var selectedRecordings = Set<Recording.ID>()
    
    // MARK: Recording info
    
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
        } else if !recorder.hasEnoughMemory {
            return "Not enough memory on device"
        } else {
            return nil
        }
    }
    
    var lastRecordings: [Recording] {
        var recordings = recorder.recordingsMetadata
        if let activeRecording = recorder.activeRecording {
            recordings.removeAll { $0.id == activeRecording.id }
        }
        return recordings
    }
    
    // MARK: Selection
    
    var selectableRecordings: [Recording] {
        lastRecordings.filter { $0.state == .completed }
    }
    
    var allSelected: Bool {
        let ids = Set(selectableRecordings.map(\.id))
        return !ids.isEmpty && selectedRecordings == ids
    }
    
    func toggleSelectAll() {
        if (allSelected) {
            selectedRecordings.removeAll()
        } else {
            selectedRecordings = Set(selectableRecordings.map(\.id))
        }
    }
    
    func deleteSelected() {
        recorder.delete(recordingIDs: Array(selectedRecordings))
        selectedRecordings.removeAll()
        isEditMode = false
    }
    
    // MARK: Views
    
    var startStopButton: some View {
        let enabled = !isEditMode && recorder.hasEnoughMemory
        
        return Button(
            action: {
                if recorder.recordingInProgress {
                    recorder.stopRecording()
                } else {
                    presentingNewRecordingSheet = true
                }
            },
            label: {
                Image(
                    systemName: recorder.recordingInProgress ? "stop.fill" : "play.fill"
                )
                .padding(13)
                .foregroundColor(Color.background)
                .background(enabled ? Color.accentColor : Color.gray)
                .clipShape(Circle())
                .font(.title2)
            }
        )
        .disabled(!enabled)
    }
    
    @ViewBuilder
    func recordingPreview(recording: Recording) -> some View {
        if recording.state == .inProgress || isEditMode {
            RecordingPreview(recording: recording)
        } else {
            NavigationLink {
                RecordingSummaryView(recordingMetadata: recording)
            } label: {
                RecordingPreview(recording: recording)
            }
        }
    }
    
    @ViewBuilder
    func recordingRow(recording: Recording) -> some View {
        HStack {
            if isEditMode {
                Button {
                    if selectedRecordings.contains(recording.id) {
                        selectedRecordings.remove(recording.id)
                    } else {
                        selectedRecordings.insert(recording.id)
                    }
                } label: {
                    Image(
                        systemName: selectedRecordings.contains(recording.id) ? "checkmark.circle.fill" : "circle"
                    )
                    .foregroundColor(
                        selectedRecordings.contains(recording.id) ? .accentColor : .gray
                    )
                    .font(.title2)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            recordingPreview(recording: recording)
                .padding(.vertical)
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack {
            List {
                Section(header: Spacer()) {
                    HStack {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(recordingTitle)
                                .font(.title2)
                            if let subtitle = secondaryRecordingTitle {
                                Text(subtitle)
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                                    .padding(.leading)
                            }
                        }
                        Spacer()
                        startStopButton
                    }
                }
                
                if let activeRecording = recorder.activeRecording {
                    Section(header: Text("Recording in progress")) {
                        recordingRow(recording: activeRecording)
                    }
                }
                
                if !lastRecordings.isEmpty {
                    Section(header: Text("Last recordings")) {
                        ForEach(lastRecordings) { recording in
                            recordingRow(recording: recording)
                        }
                    }
                }
            }
            .environment(\.editMode, .constant(isEditMode ? .active : .inactive))
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                if isEditMode {
                    Button(allSelected ? "Deselect All" : "Select All") {
                        toggleSelectAll()
                    }
                    .disabled(selectableRecordings.isEmpty)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                if isEditMode {
                    Button("Done") {
                        isEditMode = false
                        selectedRecordings.removeAll()
                    }
                } else if recorder.activeRecording == nil {
                    Button("Edit") {
                        isEditMode = true
                    }
                    .disabled(selectableRecordings.isEmpty)
                }
            }
            ToolbarItem(placement: .bottomBar) {
                if isEditMode && !selectedRecordings.isEmpty {
                    Button(role: .destructive, action: deleteSelected) {
                        Label("Delete (\(selectedRecordings.count))", systemImage: "trash")
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .toolbar(isEditMode ? .hidden : .visible,  for: .tabBar)
        .environment(\.editMode, .constant(isEditMode ? .active : .inactive))
        .sheet(isPresented: $presentingNewRecordingSheet) {
            NewRecordingView()
        }
    }
}

struct RecordingsView_Previews: PreviewProvider {
    
    static let settings = Settings()
    static let measurer = Measurer(settings: settings)
    
    static let recorder: Recorder = {
        let recorder = Recorder(measurer: measurer, settings: settings)
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
