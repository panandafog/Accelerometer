//
//  WatchRecordingsView.swift
//  Accelerometer Watch Watch App
//
//  Created by OpenAI on 07.06.2026.
//

import SwiftUI

struct WatchRecordingsView: View {
    @EnvironmentObject private var recorder: WatchRecorder

    var body: some View {
        Group {
            if let activeRecording = recorder.activeRecording {
                WatchActiveRecordingView(recording: activeRecording)
            } else {
                recordingsList
            }
        }
        .navigationTitle(recorder.isRecording ? "Recording" : "Recordings")
    }

    private var recordingsList: some View {
        List {
            Section {
                NavigationLink {
                    WatchNewRecordingView()
                } label: {
                    Label("New recording", systemImage: "record.circle")
                }
            }

            if !recorder.recordings.isEmpty {
                Section("Saved") {
                    ForEach(recorder.recordings) { recording in
                        NavigationLink {
                            WatchRecordingDetailView(recordingID: recording.id)
                        } label: {
                            WatchStoredRecordingRow(recording: recording)
                        }
                    }
                }
            }

            if let error = recorder.lastTransferError {
                Section {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }
        }
    }
}

private struct WatchNewRecordingView: View {
    @EnvironmentObject private var recorder: WatchRecorder
    @Environment(\.dismiss) private var dismiss

    @State private var selectedTypes = Set(MeasurementType.allShownCases)

    var body: some View {
        List {
            ForEach(MeasurementType.allShownCases, id: \.self) { type in
                Toggle(
                    type.name.capitalizingFirstLetter(),
                    isOn: Binding(
                        get: { selectedTypes.contains(type) },
                        set: { selected in
                            if selected {
                                selectedTypes.insert(type)
                            } else {
                                selectedTypes.remove(type)
                            }
                        }
                    )
                )
            }

            Button {
                recorder.start(measurements: selectedTypes)
                dismiss()
            } label: {
                Label("Start", systemImage: "record.circle.fill")
            }
            .disabled(selectedTypes.isEmpty)
        }
        .navigationTitle("New recording")
    }
}

private struct WatchRecordingDetailView: View {
    @EnvironmentObject private var recorder: WatchRecorder
    @Environment(\.dismiss) private var dismiss

    let recordingID: String

    private var recording: WatchRecorder.StoredRecording? {
        recorder.recordings.first { $0.id == recordingID }
    }

    var body: some View {
        List {
            if let recording {
                Section {
                    WatchStoredRecordingRow(recording: recording)
                }

                Section("Measurements") {
                    ForEach(recording.payload.measurementTypes.sorted(), id: \.self) { rawType in
                        if let type = MeasurementType(rawValue: rawType) {
                            HStack {
                                Text(type.name.capitalizingFirstLetter())
                                Spacer()
                                Text(entryCount(type: type), format: .number)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }

                Section {
                    let isTransferring = recorder.transferringIDs.contains(recording.id)

                    if isTransferring {
                        TransferProgressLabel(
                            progress: recorder.transferProgress[recording.id],
                            isAwaitingImport: recorder.awaitingImportIDs.contains(recording.id)
                        )
                        .foregroundStyle(.primary)
                        .tint(.accentColor)
                    } else {
                        Button {
                            recorder.send(recordingID: recording.id)
                        } label: {
                            Label(
                                recording.isTransferred ? "Send again" : "Send to iPhone",
                                systemImage: "square.and.arrow.up"
                            )
                        }
                    }

                    Button(role: .destructive) {
                        recorder.delete(recordingID: recording.id)
                        dismiss()
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    .disabled(isTransferring)
                }
            }
        }
        .navigationTitle("Recording")
    }

    private func entryCount(type: MeasurementType) -> Int {
        recording?.payload.entries.filter {
            $0.measurementType == type.rawValue
        }.count ?? 0
    }
}

private struct TransferProgressLabel: View {
    let progress: Double?
    let isAwaitingImport: Bool

    private var percentage: Int {
        Int(((progress ?? 0) * 100).rounded())
    }

    var body: some View {
        HStack(spacing: 8) {
            if let progress {
                ProgressView(value: progress)
                    .progressViewStyle(.circular)
            } else {
                ProgressView()
                    .progressViewStyle(.circular)
            }

            VStack(alignment: .leading, spacing: 1) {
                Text(isAwaitingImport ? "Importing on iPhone" : "Sending to iPhone")

                if progress != nil {
                    Text("\(percentage)%")
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

private struct WatchActiveRecordingView: View {
    @EnvironmentObject private var recorder: WatchRecorder

    let recording: WatchRecorder.ActiveRecording

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            VStack(spacing: 6) {
                HStack(spacing: 5) {
                    Circle()
                        .fill(.red)
                        .frame(width: 8, height: 8)

                    Text("Recording")
                        .font(.caption)
                        .foregroundStyle(.red)

                    Spacer(minLength: 4)

                    Text("\(recording.measurementTypes.count) sensors")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                Text(duration(from: recording.start, to: context.date))
                    .font(.system(.title2, design: .rounded, weight: .semibold))
                    .monospacedDigit()
                    .minimumScaleFactor(0.7)

                Button(role: .destructive) {
                    recorder.stop()
                } label: {
                    Label("Stop", systemImage: "stop.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
                .tint(.red)
            }
            .padding(.horizontal, 6)
            .padding(.bottom, 2)
        }
    }
}

private struct WatchStoredRecordingRow: View {
    @EnvironmentObject private var recorder: WatchRecorder

    let recording: WatchRecorder.StoredRecording

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if recording.payload.wasInterrupted == true {
                Label("Recording interrupted", systemImage: "exclamationmark.circle.fill")
                    .font(.caption)
                    .foregroundStyle(.orange)
            }

            Text(recording.payload.start, style: .date)
            Text(recording.payload.start, style: .time)
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack {
                Text(duration(from: recording.payload.start, to: recording.payload.end))
                    .monospacedDigit()

                Spacer()

                if recorder.transferringIDs.contains(recording.id) {
                    if let progress = recorder.transferProgress[recording.id] {
                        ProgressView(value: progress)
                            .progressViewStyle(.circular)

                        Text("\(Int((progress * 100).rounded()))%")
                            .monospacedDigit()
                            .foregroundStyle(.secondary)
                    } else {
                        ProgressView()
                            .progressViewStyle(.circular)

                        Image(
                            systemName: recorder.awaitingImportIDs.contains(recording.id)
                                ? "iphone"
                                : "arrow.up"
                        )
                        .foregroundStyle(.secondary)
                    }
                } else if recording.isTransferred {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                }
            }
            .font(.caption)
        }
    }
}

private func duration(from start: Date, to end: Date) -> String {
    let totalSeconds = max(0, Int(end.timeIntervalSince(start)))
    let hours = totalSeconds / 3600
    let minutes = (totalSeconds % 3600) / 60
    let seconds = totalSeconds % 60

    if hours > 0 {
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    return String(format: "%02d:%02d", minutes, seconds)
}
