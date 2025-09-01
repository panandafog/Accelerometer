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
    
    var title: String { measurementType.name.capitalizingFirstLetter() }
    
    var chartEntries: [Recording.Entry] {
        recording.chartValues2(of: measurementType)
    }
    
    var body: some View {
        VStack {
            Text(title)
                .padding(.top, 4)
                .padding(.bottom, 2)
            
            Chart(chartEntries) { entry in
                CustomChartContent(entry: entry)
            }
            .padding(.bottom, 4)
        }
    }
}

private struct CustomChartContent: ChartContent {
    let entry: Recording.Entry
    
    var body: AnyChartContent {
        let axes = entry.axes
        
        AnyChartContent(erasing: createLineMarks(axes: axes))
    }
    
    @ChartContentBuilder
    private func createLineMarks(axes: some Axes) -> some ChartContent {
        
        let axesTypes = type(of: axes).sortedAxesTypes
        
        ForEach(axesTypes) { axeType in
            if let yAxis = axes.values[axeType] {
                
                let xName = "date"
                let yName = yAxis.type_.name
                
                LineMark(
                    x: .value(xName, entry.date),
                    y: .value(yName, yAxis.value)
                )
                .foregroundStyle(by: .value("name", yName))
            }
        }
    }
}

struct RecordingMeasurementChartView_Previews: PreviewProvider {
    
    static let axes1: TriangleAxes = {
        var axes = TriangleAxes.zero
        axes.displayableAbsMax = 1.0
        axes.values = [
            .x: Axis(type_: .x, value: 0.0),
            .y: Axis(type_: .y, value: 0.0),
            .z: Axis(type_: .z, value: 0.0)
        ]
        return axes
    }()
    
    static let axes2: TriangleAxes = {
        var axes = TriangleAxes.zero
        axes.displayableAbsMax = 1.0
        axes.values = [
            .x: Axis(type_: .x, value: 1.0),
            .y: Axis(type_: .y, value: 0.1),
            .z: Axis(type_: .z, value: 0.1)
        ]
        return axes
    }()
    
    static let axes3: TriangleAxes = {
        var axes = TriangleAxes.zero
        axes.displayableAbsMax = 1.0
        axes.values = [
            .x: Axis(type_: .x, value: 0.2),
            .y: Axis(type_: .y, value: 0.2),
            .z: Axis(type_: .z, value: 0.2)
        ]
        return axes
    }()
    
    static let baseAxes: [TriangleAxes] = [axes1, axes2, axes3]
    
    static var allEntries: [Recording.Entry] {
        let repeats = 5
        let interval: TimeInterval = 60
        return (0..<repeats).flatMap { round in
            baseAxes.enumerated().map { index, axes in
                .init(
                    measurementType: .acceleration,
                    date: .init() + interval * TimeInterval(
                        round * baseAxes.count + index
                    ),
                    axes: axes
                )
            }
        }
    }
    
    static var previews: some View {
        RecordingMeasurementChartView(
            recording: Recording(
                entries: allEntries,
                state: .completed,
                measurementTypes: [.acceleration]
            ),
            measurementType: .acceleration,
            presentExporter: {}
        )
        .previewLayout(.sizeThatFits)
        .frame(width: 300, height: 150)
        .background(Color(.systemBackground))
        .padding()
    }
}
