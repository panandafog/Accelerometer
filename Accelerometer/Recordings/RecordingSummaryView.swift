//
//  RecordingSummaryView.swift
//  Accelerometer
//
//  Created by Andrey on 30.07.2022.
//

import SwiftUI
import UniformTypeIdentifiers

struct RecordingSummaryView: View {
    
    let recording: Recording
    
    @EnvironmentObject private var settings: Settings
    @EnvironmentObject private var recorder: Recorder
    @Environment(\.presentationMode) private var presentationMode
    
    @State private var isPresentingDeleteConfirmation = false
    @State private var isPresentingExporter = false
    @State private var exportURL: URL? = nil
    @State private var exportLoading = false
    
    private let processor = RecordingProcessor()
    
    var body: some View {
        List {
            Section("Info") {
                RecordingPreview(recording: recording)
            }
            Section("Measurements") {
                ForEach(recording.sortedMeasurementTypes, id: \.self) { type in
                    RecordingMeasurementChartView(
                        recording: recording,
                        measurementType: type
                    ) {
                        export(type: type)
                    }
                }
            }
        }
        .navigationTitle("Recording")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(role: .destructive) {
                    isPresentingDeleteConfirmation = true
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
            // TODO: export
//            ToolbarItem(placement: .primaryAction) {
//                Button {
//                } label: {
//                    Label("Export", systemImage: "square.and.arrow.up")
//                }
//                .disabled(true)
//            }
        }
        .confirmationDialog(
            "Are you sure?",
            isPresented: $isPresentingDeleteConfirmation
        ) {
            Button("Delete", role: .destructive, action: deleteRecording)
        }
        .fileExporter(
            isPresented: $isPresentingExporter,
            document: exportURL.map { FileDocumentWrapper(url: $0) },
            contentType: UTType.plainText,
            defaultFilename: defaultFilename()
        ) { _ in }
    }
    
    private func deleteRecording() {
        recorder.delete(recordingID: recording.id)
        presentationMode.wrappedValue.dismiss()
    }
    
    private func export(type: MeasurementType) {
        guard !exportLoading else { return }
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
        (exportURL?.lastPathComponent ?? recording.id) + ".csv"
    }
}


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


struct RecordingView_Previews: PreviewProvider {
    
    static let settings = Settings()
    static let measurer = Measurer(settings: settings)
    static let recorder = Recorder(measurer: measurer)
    
    static let axes: TriangleAxes = {
        var axes = TriangleAxes.zero
        axes.displayableAbsMax = 1.0
        return axes
    }()
    
    static var previews: some View {
        RecordingSummaryView(
            recording: Recording(
                entries: [
                    .init(
                        measurementType: .acceleration,
                        date: .init(),
                        axes: axes
                    )
                ],
                state: .completed,
                measurementTypes: [.acceleration]
            )
        )
        .preferredColorScheme(.light)
        .environmentObject(recorder)
        .environmentObject(settings)
        
        RecordingSummaryView(
            recording: Recording(
                entries: [
                    .init(
                        measurementType: .acceleration,
                        date: .init(),
                        axes: axes
                    )
                ],
                state: .completed,
                measurementTypes: [.acceleration]
            )
        )
        .preferredColorScheme(.dark)
        .environmentObject(recorder)
        .environmentObject(settings)
    }
}
