//
//  BooleanAxesSummaryView.swift
//  Accelerometer
//
//  Created by Andrey on 18.02.2024.
//

import SwiftUI

struct BooleanAxesSummaryView: View {
    var axes: BooleanAxes
    let type: MeasurementType
    
    var body: some View {
        Text("Not implemented yet: \(type.name)")
    }
}

#Preview {
    BooleanAxesSummaryView(axes: .zero, type: .proximity)
}
