//
//  VectorAxesSummaryView.swift
//  Accelerometer
//
//  Created by Andrey on 07.10.2023.
//

import SwiftUI

struct VectorAxesSummaryView: View {
    var axes: any VectorAxes
    let type: MeasurementType
    
    var body: some View {
        AxesSummaryValueView(
            value: axes.valueLabel,
            color: axes.intensityColor
        )
    }
}
