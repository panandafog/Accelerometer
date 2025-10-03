//
//  RecordingMeasurementChartView.swift
//  Accelerometer
//
//  Created by Andrey Pantyuhin on 22.03.2025.
//

import Charts
import SwiftUI

struct RecordingSmallChartView: View {
    let recording: Recording
    let measurementType: MeasurementType

    var body: some View {
        NavigationLink(destination: RecordingBigChartView(
            recording: recording,
            measurementType: measurementType
        )) {
            RecordingChartContainerView(
                recording: recording,
                measurementType: measurementType,
                style: .small
            )
        }
    }
}

// MARK: - Previews

#if DEBUG
struct RecordingSmallChartView_Previews: PreviewProvider {

    static var sampleRecordings: [Recording] = [
        PreviewUtils.shortRecording,
        PreviewUtils.mediumRecording,
        PreviewUtils.longRecording
    ]

    static var previews: some View {
        Group {
            ForEach(sampleRecordings, id: \.id) { rec in
                VStack(alignment: .leading) {
                    Text("Recording: \(rec.id)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    RecordingSmallChartView(
                        recording: rec,
                        measurementType: rec.sortedMeasurementTypes.first!
                    )
                }
                .padding()
                .previewDisplayName(rec.id)
                .previewLayout(.sizeThatFits)
            }
        }
    }
}
#endif
