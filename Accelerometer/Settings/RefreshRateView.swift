//
//  RefreshRateView.swift
//  Accelerometer
//
//  Created by Andrey on 21.06.2022.
//

import SwiftUI

struct RefreshRateView: View {
    @ObservedObject var measurer = Measurer.shared
    @ObservedObject var recorder = Recorder.shared
    
    @State private var value: Double = Measurer.shared.updateInterval
    @State private var isEditing = false
    
    var body: some View {
        VStack {
//            Text("Measurements update interval")
            Text(String(value, roundPlaces: Measurer.updateIntervalRoundPlaces))
                    .foregroundColor(isEditing ? .blue : .accentColor)
            Slider(
                value: $value,
                in: .init(uncheckedBounds: (
                    lower: Measurer.minUpdateInterval,
                    upper: Measurer.maxUpdateInterval
                )),
                step: Measurer.updateIntervalStep,
                onEditingChanged: { editing in
                    isEditing = editing
                    measurer.updateInterval = value
                },
                minimumValueLabel: Text(String(Measurer.minUpdateInterval)),
                maximumValueLabel: Text(String(Measurer.maxUpdateInterval)),
                label: { }
            )
            .disabled(recorder.recordingInProgress)
            
            if recorder.recordingInProgress {
                Text("This setting is not available while recording is enabled")
                    .padding(.vertical)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct RefreshRateView_Previews: PreviewProvider {
    
    static let recorder1: Recorder = {
        let recorder = Recorder()
        return recorder
    }()
    
    static let recorder2: Recorder = {
        let recorder = Recorder()
        recorder.record(measurements: [.acceleration])
        return recorder
    }()
    
    static var previews: some View {
        RefreshRateView(measurer: .shared, recorder: recorder1)
            .previewLayout(.sizeThatFits)
        RefreshRateView(measurer: .shared, recorder: recorder2)
            .previewLayout(.sizeThatFits)
    }
}
