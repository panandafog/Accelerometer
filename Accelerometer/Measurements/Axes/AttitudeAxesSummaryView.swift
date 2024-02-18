//
//  AttitudeAxesSummaryView.swift
//  Accelerometer
//
//  Created by Andrey on 08.10.2023.
//

import SwiftUI

struct AttitudeAxesSummaryView: View {
    private static let noValueLabel = "..."
    
    var axes: AttitudeAxes
    let type: MeasurementType
    
    var body: some View {
        ForEach(
            Array(AttitudeAxes.sortedAxesTypes)
        ) { axeType in
            HStack {
                Text("\(axeType.name): ")
                    .padding(.trailing)
                
                AxesSummaryValueView(
                    value: axes.valueLabel(of: axeType) ??
                        Self.noValueLabel,
                    color: .intensity(0.5)
                )
            }
        }
    }
}