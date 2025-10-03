//
//  RecordingChartContent.swift
//  Accelerometer
//
//  Created by Andrey Pantyuhin on 29.09.2025.
//

import Charts
import SwiftUI

struct RecordingChartContent: ChartContent {
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
