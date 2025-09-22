//
//  RefreshRateView.swift
//  Accelerometer
//
//  Created by Andrey on 21.06.2022.
//

import SwiftUI

struct RefreshRateView: View {
    @EnvironmentObject var settings: Settings
    @EnvironmentObject var recorder: Recorder
    
    @State private var value = 0.0
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
        .onAppear {
            value = settings.updateInterval
        }
    }
}

struct RefreshRateView_Previews: PreviewProvider {
    
    static let settings = Settings()
    static let measurer = Measurer(settings: settings)
    
    static let recorder1: Recorder = {
        let recorder = Recorder(measurer: measurer, settings: settings)
        return recorder
    }()
    
    static let recorder2: Recorder = {
        let recorder = Recorder(measurer: measurer, settings: settings)
        recorder.record(measurements: [.acceleration])
        return recorder
    }()
    
    static var previews: some View {
        RefreshRateView()
            .previewLayout(.sizeThatFits)
            .environmentObject(settings)
            .environmentObject(measurer)
            .environmentObject(recorder1)
        RefreshRateView()
            .previewLayout(.sizeThatFits)
            .environmentObject(settings)
            .environmentObject(measurer)
            .environmentObject(recorder2)
    }
}
