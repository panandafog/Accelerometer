//
//  RecordingMeasurementChartView.swift
//  Accelerometer
//
//  Created by Andrey Pantyuhin on 22.03.2025.
//

import Charts
import SwiftUI

struct RecordingMeasurementChartView: View {
    
    let recording: Recording
    let measurementType: MeasurementType
    
    let presentExporter: () -> Void
    
    private var startDate: Date {
        chartEntries.first?.date ?? Date()
    }
    
    var title: String { measurementType.name.capitalizingFirstLetter() }
    
    var chartEntries: [Recording.Entry] {
        recording.chartValues(of: measurementType)
    }
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.headline)
                .padding(.top, 4)
            
            Chart(chartEntries) { entry in
                CustomChartContent(entry: entry, startDate: startDate)
            }
            .frame(height: 200)
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
        }
    }
}

private struct CustomChartContent: ChartContent {
    let entry: Recording.Entry
    let startDate: Date
    
    var body: AnyChartContent {
        let axes = entry.axes
        AnyChartContent(erasing: createLineMarks(axes: axes))
    }
    
    @ChartContentBuilder
    private func createLineMarks(axes: some Axes) -> some ChartContent {
        
        let axesTypes = type(of: axes).sortedAxesTypes
        
        ForEach(axesTypes) { axeType in
            if let yAxis = axes.values[axeType] {
                let elapsed = entry.date.timeIntervalSince(startDate)
                let xName = "elapsed"
                let yName = yAxis.type_.name
                
                LineMark(
                    x: .value(xName, elapsed),
                    y: .value(yName, yAxis.value)
                )
                .foregroundStyle(by: .value("name", yName))
            }
        }
    }
}

struct RecordingMeasurementChartView_Previews: PreviewProvider {
    
    static var axesTemplate: TriangleAxes {
        var axes = TriangleAxes.zero
        let xValue = Double.random(in: -1.0...1.0)
        let yValue = Double.random(in: -1.0...1.0)
        let zValue = Double.random(in: -1.0...1.0)

        axes.displayableAbsMax = 1.0
        axes.values = [
            .x: Axis(type_: .x, value: xValue),
            .y: Axis(type_: .y, value: yValue),
            .z: Axis(type_: .z, value: zValue)
        ]
        return axes
    }
    
    static var secondsEntries: [Recording.Entry] {
        let totalPoints = 60
        let pointsPerSecond = 30.0
        let startDate = Date()
        
        return (0..<totalPoints).map { index in
            let timeOffset = Double(index) / pointsPerSecond
            let date = startDate.addingTimeInterval(timeOffset)
            
            return Recording.Entry(
                measurementType: .acceleration,
                date: date,
                axes: axesTemplate
            )
        }
    }
    
    static var minutesEntries: [Recording.Entry] {
        let totalPoints = 20 * 60
        let samplesPerSecond = 1.0
        let start = Date()
        return (0..<totalPoints).map { i in
            let t = Double(i) / samplesPerSecond
            let date = start.addingTimeInterval(t)
            return .init(
                measurementType: .acceleration,
                date: date,
                axes: axesTemplate
            )
        }
    }
    
    static var hoursEntries: [Recording.Entry] {
        let totalPoints = (2 * 60 * 60) / 5
        let interval = 5.0
        let start = Date()
        return (0..<totalPoints).map { i in
            let t = Double(i) * interval
            let date = start.addingTimeInterval(t)
            return .init(
                measurementType: .acceleration,
                date: date,
                axes: axesTemplate
            )
        }
    }

    
    static var previews: some View {
        VStack {
            Text("2 sec")
                .padding(.bottom, 40)
            RecordingMeasurementChartView(
                recording: Recording(
                    entries: secondsEntries,
                    state: .completed,
                    measurementTypes: [.acceleration]
                ),
                measurementType: .acceleration,
                presentExporter: {}
            )
            .frame(width: 300, height: 150)
            .background(Color(.systemBackground))
            .padding(.bottom, 40)
            
            Text("20 min")
                .padding(.bottom, 40)
            RecordingMeasurementChartView(
                recording: Recording(
                    entries: minutesEntries,
                    state: .completed,
                    measurementTypes: [.acceleration]
                ),
                measurementType: .acceleration,
                presentExporter: {}
            )
            .frame(width: 300, height: 150)
            .background(Color(.systemBackground))
            .padding(.bottom, 40)
            
            Text("2 h")
                .padding(.bottom, 40)
            RecordingMeasurementChartView(
                recording: Recording(
                    entries: hoursEntries,
                    state: .completed,
                    measurementTypes: [.acceleration]
                ),
                measurementType: .acceleration,
                presentExporter: {}
            )
            .frame(width: 300, height: 150)
            .background(Color(.systemBackground))
            .padding(.bottom, 40)
        }
        .previewLayout(.sizeThatFits)
    }
}
