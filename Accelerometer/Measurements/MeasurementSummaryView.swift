//
//  MeasurementSummaryView.swift
//  Accelerometer
//
//  Created by Andrey on 22.06.2022.
//

import SwiftUI

struct MeasurementSummaryView: View {
    @ObservedObject var measurer = Measurer.shared
    let type: Measurer.MeasurementType
    
    var body: some View {
        VStack {
            MeasurementsAxesView(axes: $measurer.deviceMotion)
                .padding([.bottom])
            Spacer()
        }
        .navigationTitle(type.name)
    }
}

struct MeasurementSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        MeasurementSummaryView(type: .deviceMotion)
    }
}
