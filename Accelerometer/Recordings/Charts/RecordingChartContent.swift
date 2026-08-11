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
    let displayMode: RecordingChartDisplayMode
    
    var body: AnyChartContent {
        let axes = entry.axes
        switch displayMode {
        case .axes:
            return AnyChartContent(erasing: createAxisLineMarks(axes: axes))
        case .vector:
            return AnyChartContent(erasing: createVectorLineMark(axes: axes))
        }
    }
    
    @ChartContentBuilder
    private func createAxisLineMarks(axes: some Axes) -> some ChartContent {
        
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

    @ChartContentBuilder
    private func createVectorLineMark(axes: some Axes) -> some ChartContent {
        if let triangleAxes = axes as? TriangleAxes {
            let elapsed = entry.date.timeIntervalSince(startDate)
            let yName = "vector"

            LineMark(
                x: .value("elapsed", elapsed),
                y: .value(yName, triangleAxes.magnitude.value)
            )
            .foregroundStyle(by: .value("name", yName))
        }
    }
}

enum RecordingChartDisplayMode: Hashable {
    case axes
    case vector

    mutating func toggle() {
        switch self {
        case .axes:
            self = .vector
        case .vector:
            self = .axes
        }
    }

    var toggleTitle: String {
        switch self {
        case .axes:
            "Vector"
        case .vector:
            "Axes"
        }
    }

    var accessibilityLabel: String {
        switch self {
        case .axes:
            "Show vector chart"
        case .vector:
            "Show axes chart"
        }
    }
}
