//
//  AnyAxesSummaryView.swift
//  Accelerometer
//
//  Created by Andrey on 08.10.2023.
//

import SwiftUI

struct AnyAxesSummaryView: View {
    let type: MeasurementType
    
    var body: some View {
        Text("No data: \(type.name)")
    }
}
