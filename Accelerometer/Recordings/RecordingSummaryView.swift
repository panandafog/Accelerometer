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
    
    @State private var isPresentingExporter = false
    @State private var exportURL: URL?
    @State private var exportLoading = false
    
    private let processor = RecordingProcessor()
    
    // MARK: - Body
    
    var body: some View {
        let recording = fullRecording ?? recordingMetadata
        
        List {
            Section("Info") {
                RecordingPreview(recording: recording)
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

        .fileExporter(
            isPresented: $isPresentingExporter,
            document: exportURL.map { FileDocumentWrapper(url: $0) },
            contentType: UTType.plainText,
            defaultFilename: defaultFilename()
        ) { _ in }
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
                isPresentingExporter = true
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
