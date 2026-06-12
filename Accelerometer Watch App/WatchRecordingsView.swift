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
                    Button {
                        recorder.send(recordingID: recording.id)
                    } label: {
                        if recorder.transferringIDs.contains(recording.id) {
                            TransferProgressLabel(
                                progress: recorder.transferProgress[recording.id] ?? 0
                            )
                        } else {
                            Label(
                                recording.isTransferred ? "Send again" : "Send to iPhone",
                                systemImage: "square.and.arrow.up"
                            )
                        }
                    }
                    .disabled(recorder.transferringIDs.contains(recording.id))

                    Button(role: .destructive) {
                        recorder.delete(recordingID: recording.id)
                        dismiss()
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    .disabled(recorder.transferringIDs.contains(recording.id))
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
    let progress: Double

    private var percentage: Int {
        Int((progress * 100).rounded())
    }

    var body: some View {
        HStack(spacing: 8) {
            ProgressView(value: progress)
                .progressViewStyle(.circular)

            VStack(alignment: .leading, spacing: 1) {
                Text("Sending")
                Text("\(percentage)%")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
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

    private var transferProgress: Double? {
        guard recorder.transferringIDs.contains(recording.id) else {
            return nil
        }
        return recorder.transferProgress[recording.id] ?? 0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(recording.payload.start, style: .date)
            Text(recording.payload.start, style: .time)
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack {
                Text(duration(from: recording.payload.start, to: recording.payload.end))
                    .monospacedDigit()

                Spacer()

                if let transferProgress {
                    ProgressView(value: transferProgress)
                        .progressViewStyle(.circular)

                    Text("\(Int((transferProgress * 100).rounded()))%")
                        .monospacedDigit()
                        .foregroundStyle(.secondary)
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
