//
//  RefreshRateView.swift
//  Accelerometer
//
//  Created by Andrey on 21.06.2022.
//

import SwiftUI

struct RefreshRateView: View {
    @ObservedObject var measurer = Measurer.shared
    
    @State private var value: Double = Measurer.shared.updateInterval
    @State private var isEditing = false
    
    var body: some View {
        VStack {
            HStack {
                Text("Measurements update interval")
                Spacer()
//                Text(String(measurer.updateInterval))
            }
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
                label: {
                    Text("Refresh rate")
                }
            )
            
            Text(String(format: "%.\(Measurer.updateIntervalRoundPlaces)f", value))
                    .foregroundColor(isEditing ? .red : .blue)
        }
    }
}

struct RefreshRateView_Previews: PreviewProvider {
    static var previews: some View {
        RefreshRateView()
    }
}
