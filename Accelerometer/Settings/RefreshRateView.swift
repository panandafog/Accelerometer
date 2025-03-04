//
//  RefreshRateView.swift
//  Accelerometer
//
//  Created by Andrey on 21.06.2022.
//

import SwiftUI

struct RefreshRateView: View {
    @ObservedObject var settings = Settings.shared
    @ObservedObject var recorder = Recorder.shared
    
    @State private var value: Double = Settings.shared.updateInterval
    @State private var isEditing = false
    
    var body: some View {
        VStack {
            Text(String(value, roundPlaces: Settings.updateIntervalRoundPlaces))
                    .foregroundColor(isEditing ? .blue : .accentColor)
            Slider(
                value: $value,
                in: .init(uncheckedBounds: (
                    lower: Settings.minUpdateInterval,
                    upper: Settings.maxUpdateInterval
                )),
                step: Settings.updateIntervalStep,
                onEditingChanged: { editing in
                    isEditing = editing
                    settings.updateInterval = value
                },
                minimumValueLabel: Text(String(Settings.minUpdateInterval)),
                maximumValueLabel: Text(String(Settings.maxUpdateInterval)),
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
        RefreshRateView(settings: .shared, recorder: recorder1)
            .previewLayout(.sizeThatFits)
        RefreshRateView(settings: .shared, recorder: recorder2)
            .previewLayout(.sizeThatFits)
    }
}
