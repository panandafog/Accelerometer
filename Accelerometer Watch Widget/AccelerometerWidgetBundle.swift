//
//  AccelerometerWidgetBundle.swift
//  Accelerometer Watch Widget
//

import SwiftUI
import WidgetKit

@main
struct AccelerometerWidgetBundle: WidgetBundle {
    var body: some Widget {
        RecordingStatusWidget()
        MeasurementComplicationWidget()
    }
}
