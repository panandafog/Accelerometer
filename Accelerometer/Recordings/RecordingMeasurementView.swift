//
//  RecordingMeasurementView.swift
//  Accelerometer
//
//  Created by Andrey on 03.08.2022.
//

import SwiftUI
import SwiftUICharts

struct RecordingMeasurementView: View {
    
    private static let maxRate = 999
    private static let minRate = -999
    
    let recording: Recording
    let measurementType: MeasurementType
    let screenSize: CGSize
    
    let presentExporter: () -> Void
    
    func chartForm(generalSize: CGSize) -> CGSize {
        CGSize(width: generalSize.width * 0.7, height: 240)
    }
    
    var values: [Double] {
        let entries = recording.doubleValues(of: measurementType)
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
    
    var rateValue: Int {
        let allValues = values
        guard let first = allValues.first,
              let last = allValues.last else {
            return 0
        }
        guard first != 0.0 else {
            if last == 0.0 {
                return 0
            } else if last > 0.0 {
                return Self.maxRate
            } else {
                return Self.minRate
            }
        }
        let rate = Int((((last - first) / first) * 100.0).rounded())
        return max(min(rate, Self.maxRate), Self.minRate)
    }
    
    var title: String { measurementType.name.capitalizingFirstLetter() }
    
    var body: some View {
        HStack {
            // TODO: common title
            if measurementType.supportsChartRepresentation {
                ScrollView {
                    MultiLineChartView(
                        data: [(values, GradientColor(
                            start: .intensity(0.0),
                            end: .intensity(1.0)
                        ))],
                        title: title,
                        legend: nil,
                        style: .recordingEntry,
                        form: chartForm(generalSize: screenSize),
                        rateValue: rateValue,
                        dropShadow: false
                    )
                }.disabled(true)
            } else {
                Text(title)
            }
            Spacer()
            VStack {
                Menu {
                    Section {
                        Button(action: {
                            presentExporter()
                        }) {
                            Label("Export to .csv", systemImage: "folder")
                        }
                    }
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
                .padding([.vertical, .leading])
                .buttonStyle(BorderlessButtonStyle())
                Spacer()
            }
        }
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

struct RecordingMeasurementView_Previews: PreviewProvider {
    
    static let axes: TriangleAxes = {
        var axes = TriangleAxes.zero
        axes.displayableAbsMax = 1.0
        return axes
    }()
    
    static var previews: some View {
        RecordingMeasurementView(
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
            ),
            measurementType: .acceleration,
            screenSize: CGSize(width: 300, height: 700),
            presentExporter: {}
        )
    }
}
