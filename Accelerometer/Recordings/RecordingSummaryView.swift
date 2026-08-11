//
//  RecordingSummaryView.swift
//  Accelerometer
//
//  Created by Andrey on 30.07.2022.
//

import SwiftUI
import UniformTypeIdentifiers

struct RecordingSummaryView: View {
    
    // MARK: - Properties
    
    let recordingMetadata: Recording
    
    @EnvironmentObject private var settings: Settings
    @EnvironmentObject private var recorder: Recorder
    @Environment(\.presentationMode) private var presentationMode
    
    @State private var fullRecording: Recording?
    @State private var isLoading = false
    
    @State private var exportingMeasurement: MeasurementType? = nil
    @State private var exportURL: URL?
    @State private var exportLoading = false
    
    private let processor = RecordingProcessor()
    
    // MARK: - Body
    
    var body: some View {
        let recording = fullRecording ?? recordingMetadata
        let detectedGaps = recording.detectedGaps
        
        List {
            Section("Info") {
                RecordingPreview(recording: recording)
            }
            if recording.state == .interrupted || !detectedGaps.isEmpty {
                Section("Data Quality") {
                    RecordingIntegrityWarningView(
                        recording: recording,
                        gaps: detectedGaps
                    )
                }
            }
            Section("Measurements") {
                if isLoading {
                    ProgressView()
                } else {
                    ForEach(
                        recording.sortedMeasurementTypes,
                        id: \.self
                    ) { type in
                        VStack {
                            Text(
                                type
                                    .name
                                    .capitalizingFirstLetter()
                            )
                            .font(.headline)
                            RecordingSmallChartView(
                                recording: recording,
                                measurementType: type
                            )
                        }
                    }
                    .navigationLinkIndicatorVisibility(.hidden)
                }
            }
        }
        .navigationTitle("Recording")
        .toolbar {
            // MARK: Toolbar Items
            
            ToolbarItem(placement: .secondaryAction) {
                Button(
                    role: .destructive,
                    action: deleteRecording
                ) {
                    Label("Delete", systemImage: "trash")
                }
                .disabled(fullRecording == nil)
            }
            
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Text("Export")
                        .font(.headline)
                        .padding(.vertical, 4)
                    Divider()
                    ForEach(
                        fullRecording?.sortedMeasurementTypes ?? [],
                        id: \.self
                    ) { type in
                        Button {
                            export(type: type)
                        } label: {
                            Label(
                                type.name,
                                systemImage: type.iconName
                            )
                        }
                    }
                } label: {
                    Label(
                        "Export",
                        systemImage: "square.and.arrow.up"
                    )
                }
                .disabled(fullRecording == nil)
            }
        }
        .exportable(
            isPresented: .init(
                get: { exportingMeasurement != nil },
                set: { presented in
                    if !presented { exportingMeasurement = nil }
                }
            ),
            url: $exportURL,
            measurementType: exportingMeasurement ?? recording.measurementTypes.first!
        )
        .task {
            await loadFullRecordingIfNeeded()
        }
    }
    
    // MARK: - Private Methods
    
    private func loadFullRecordingIfNeeded() async {
        if recordingMetadata.entries == nil {
            isLoading = true
            fullRecording = await recorder.loadFullRecording(
                id: recordingMetadata.id
            )
            isLoading = false
        }
    }
    
    private func export(type: MeasurementType) {
        guard !exportLoading, let recording = fullRecording else { return }
        exportLoading = true
        Task {
            defer { exportLoading = false }
            do {
                let url = try await processor.generateCSV(
                    from: recording,
                    for: type,
                    dateFormat: settings.exportDateFormat
                )
                exportURL = url
                exportingMeasurement = type
            } catch {
                print("Export failed:", error)
            }
        }
    }
    
    private func defaultFilename() -> String {
        (exportURL?.lastPathComponent ?? recordingMetadata.id) + ".csv"
    }
    
    private func deleteRecording() {
        recorder.delete(recordingID: recordingMetadata.id)
        presentationMode.wrappedValue.dismiss()
    }
}

private struct RecordingIntegrityWarningView: View {

    let recording: Recording
    let gaps: [RecordingGap]

    private var displayedGaps: [RecordingGap] {
        Array(
            gaps
                .sorted { lhs, rhs in lhs.duration > rhs.duration }
                .prefix(3)
        )
    }

    private var remainingGapCount: Int {
        max(0, gaps.count - displayedGaps.count)
    }

    private var affectedMeasurementNames: String {
        Array(Set(gaps.map(\.measurementType)))
            .sorted { lhs, rhs in lhs.name < rhs.name }
            .map(\.name)
            .joined(separator: ", ")
    }

    private var longestGapDurationString: String {
        guard let longestGap = gaps.max(by: { lhs, rhs in
            lhs.duration < rhs.duration
        }) else {
            return "0:00"
        }

        return formatDuration(longestGap.duration)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if recording.state == .interrupted {
                warningLabel(
                    title: "Recording was interrupted",
                    message: "The system stopped recording before it was completed. The saved data may be incomplete."
                )
            }

            if !gaps.isEmpty {
                warningLabel(
                    title: "Missing samples detected",
                    message: "\(gaps.count) gap(s) in \(affectedMeasurementNames). Longest gap: \(longestGapDurationString)."
                )

                Text("Orange bands on the charts mark time ranges where no samples were written.")
                    .font(.caption)
                    .foregroundColor(.secondary)

                VStack(alignment: .leading, spacing: 6) {
                    ForEach(displayedGaps) { gap in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(gap.measurementType.name.capitalizingFirstLetter())
                                .font(.caption)
                                .fontWeight(.semibold)

                            Text("\(elapsedRangeString(for: gap)) - \(formatDuration(gap.duration)) without samples")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    if remainingGapCount > 0 {
                        Text("+ \(remainingGapCount) more")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }

    private func warningLabel(title: String, message: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Label(title, systemImage: "exclamationmark.triangle.fill")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.orange)

            Text(message)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    private func elapsedRangeString(for gap: RecordingGap) -> String {
        let start = gap.start.timeIntervalSince(recording.start)
        let end = gap.end.timeIntervalSince(recording.start)
        return "\(formatDuration(start)) to \(formatDuration(end))"
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let totalSeconds = max(0, Int(duration.rounded()))
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        }

        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Debug Preview

#if DEBUG
extension RecordingSummaryView {
    
    init(previewRecording: Recording) {
        self.recordingMetadata = Recording(
            id: previewRecording.id,
            start: previewRecording.start,
            end: previewRecording.end,
            entries: nil,
            state: previewRecording.state,
            source: previewRecording.source,
            measurementTypes: previewRecording.measurementTypes
        )
        
        _fullRecording = State(initialValue: previewRecording)
        _isLoading = State(initialValue: false)
    }
}
#endif

// MARK: - FileDocument Wrapper

struct FileDocumentWrapper: FileDocument {
    
    let url: URL
    
    static var readableContentTypes: [UTType] { [.plainText] }
    
    init(url: URL) { self.url = url }
    
    init(configuration: ReadConfiguration) throws {
        throw CocoaError(.coderReadCorrupt)
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        try FileWrapper(url: url, options: .immediate)
    }
}

// MARK: - Previews

#if DEBUG
struct RecordingSummaryView_Previews: PreviewProvider {
    
    static let settings = Settings()
    static let recorder = Recorder(
        measurer: Measurer(settings: settings),
        settings: settings
    )
    
    static let axes: TriangleAxes = {
        var a = TriangleAxes.zero
        a.displayableAbsMax = 1.0
        return a
    }()
    
    static let sampleRecording = Recording(
        id: UUID().uuidString,
        start: Date().addingTimeInterval(-60),
        end: Date(),
        entries: [
            .init(
                measurementType: .acceleration,
                date: Date().addingTimeInterval(-60),
                axes: axes
            ),
            .init(
                measurementType: .acceleration,
                date: Date(),
                axes: axes
            )
        ],
        state: .completed,
        measurementTypes: [.acceleration]
    )
    
    static var previews: some View {
        NavigationView {
            RecordingSummaryView(previewRecording: sampleRecording)
                .environmentObject(settings)
                .environmentObject(recorder)
        }
        .preferredColorScheme(.light)
        
        NavigationView {
            RecordingSummaryView(previewRecording: sampleRecording)
                .environmentObject(settings)
                .environmentObject(recorder)
        }
        .preferredColorScheme(.dark)
    }
}
#endif
