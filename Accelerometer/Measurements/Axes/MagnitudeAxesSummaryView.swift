//
//  MagnitudeAxesSummaryView.swift
//  Accelerometer
//
//  Created by Andrey on 07.10.2023.
//

import SwiftUI

struct MagnitudeAxesSummaryView: View {
    var axes: any MagnitudeAxes
    let type: MeasurementType
    
    var body: some View {
        AxesSummaryValueView(
            value: axes.valueLabel(of: .magnitude),
            color: axes.intensityColor
        )
    }
}
