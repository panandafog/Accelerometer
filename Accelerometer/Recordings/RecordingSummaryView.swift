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
    @ObservedObject var recorder: Recorder = .shared
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var isPresentingDeleteConfirmation: Bool = false
    
    let deleteAlertTitleText = "Are you sure?"
    
    func chartForm(generalSize: CGSize) -> CGSize {
        CGSize(width: generalSize.width * 0.75, height: 240)
    }
    
    func values(of type: MeasurementType) -> [Double] {
        let entries = recording.entries
            .filter({ $0.measurementType == type })
            .map({ $0.value?.vector ?? 0.0 })
        let limit = 100
        if entries.count > limit {
            return entries
                .chunked(into: Int((Double(entries.count) / 100.0).rounded()))
                .map({ chunk -> Double in
                    let sumArray = chunk.reduce(0, +)
                    return sumArray / Double(chunk.count)
                })
        } else {
            return entries
        }
    }
    
    var entriesView: some View {
        VStack {
            GeometryReader { geometry in
                List {
                    Section(header: Text("Info")) {
                        RecordingPreview(recording: recording)
                            .padding(.vertical)
                    }
                    Section(header: Text("Measurements")) {
                        ForEach(Array(recording.measurementTypes), id: \.self) { measurementType in
                            HStack {
                                Spacer()
                                ScrollView {
                                    MultiLineChartView(
                                        data: [(values(of: measurementType), GradientColor(
                                            start: .intensity(0.0),
                                            end: .intensity(1.0)
                                        ))],
                                        title: measurementType.name.capitalized,
                                        legend: nil,
                                        style: .recordingEntry,
                                        form: chartForm(generalSize: geometry.size),
                                        rateValue: 5,
                                        dropShadow: false
                                    )
                                }.disabled(true)
                                Spacer()
                            }
                        }
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
        .preferredColorScheme(.light)
        
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
        .preferredColorScheme(.dark)
    }
}
