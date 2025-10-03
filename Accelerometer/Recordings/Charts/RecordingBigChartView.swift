//
//  RecordingBigChartView.swift
//  Accelerometer
//
//  Created by Andrey Pantyuhin on 29.09.2025.
//

import SwiftUI

struct RecordingBigChartView: View {
    let recording: Recording
    let measurementType: MeasurementType
    
    var body: some View {
        RecordingChartContainerView(
            recording: recording,
            measurementType: measurementType,
            style: .big
        )
        .padding(.vertical)
        .navigationTitle(measurementType.name.capitalized)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#if DEBUG
struct RecordingBigChartView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                RecordingBigChartView(
                    recording: PreviewUtils.shortRecording,
                    measurementType: .acceleration
                )
            }
            .previewDisplayName("Medium")
            
            NavigationView {
                RecordingBigChartView(
                    recording: PreviewUtils.longRecording,
                    measurementType: .magneticField
                )
            }
            .previewDisplayName("Long")
        }
    }
}
#endif
