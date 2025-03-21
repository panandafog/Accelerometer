//
//  RecordingSummaryView.swift
//  Accelerometer
//
//  Created by Andrey on 30.07.2022.
//

import SwiftUI
import SwiftUICharts

struct RecordingSummaryView: View {
    
    let recording: Recording
    
    @EnvironmentObject var settings: Settings
    @EnvironmentObject var recorder: Recorder
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var isPresentingDeleteConfirmation = false
    
    @State private var isPresentingExporter = false
    @State private var exportMeasurementType: MeasurementType = .acceleration
    
    let deleteAlertTitleText = "Are you sure?"
    
    var entriesView: some View {
        GeometryReader { geometry in
            List {
                Section(header: Text("Info")) {
                    RecordingPreview(recording: recording)
                        .padding(.vertical)
                }
                Section(header: Text("Measurements")) {
                    ForEach(Array(recording.sortedMeasurementTypes), id: \.self) { measurementType in
                        HStack {
                            RecordingMeasurementView(
                                recording: recording,
                                measurementType: measurementType,
                                screenSize: geometry.size
                            ) {
                                isPresentingExporter = true
                                exportMeasurementType = measurementType
                            }
                        }
                    }
                }
            }
        }
    }
    
    var body: some View {
        entriesView
            .navigationTitle("Recording")
        
        // MARK: Toolbar
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    if #available(iOS 15.0, *) {
                        Button(role: .destructive, action: {
                            isPresentingDeleteConfirmation = true
                        }) {
                            Label("Delete", systemImage: "trash")
                        }
                    } else {
                        Button(action: {
                            isPresentingDeleteConfirmation = true
                        }) {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
        
        // MARK: Delete confirmation
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
        
        // MARK: Exporter
            .fileExporter(
                isPresented: $isPresentingExporter,
                document: recording.csv(
                    of: exportMeasurementType,
                    dateFormat: settings.exportDateFormat
                ),
                contentType: TextFile.readableContentTypes.first ?? .plainText,
                defaultFilename: exportMeasurementType.name + ".csv"
            ) { result in
                switch result {
                case .success(let url):
                    print("Saved to \(url)")
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
    }
    
    func deleteRecording() {
        recorder.delete(recordingID: recording.id)
        presentationMode.wrappedValue.dismiss()
    }
}

private extension ChartStyle {
    
    static var recordingEntry: ChartStyle {
        ChartStyle(
            backgroundColor: Color.secondaryBackground,
            accentColor: Color.accentColor,
            gradientColor: .init(
                start: Color.accentColor,
                end: Color.accentColor
            ),
            textColor: Color.primary,
            legendTextColor: Color.primary,
            dropShadowColor: Color.clear
        )
    }
    
    static var recordingEntryDarkMode: ChartStyle {
        ChartStyle(
            backgroundColor: Color.accentColor,
            accentColor: Color.accentColor,
            gradientColor: .init(
                start: Color.accentColor,
                end: Color.accentColor
            ),
            textColor: Color.primary,
            legendTextColor: Color.primary,
            dropShadowColor: Color.clear
        )
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
