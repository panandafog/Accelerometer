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
    
    var axesBinding: Binding<Measurer.Axes?> {
        switch type {
        case .deviceMotion:
            return Binding<Measurer.Axes?>.init(
                get: {
                    measurer.deviceMotion
                },
                set: { _ in }
            )
        case .acceleration:
            return Binding<Measurer.Axes?>.init(
                get: {
                    measurer.acceleration
                },
                set: { _ in }
            )
        case .rotation:
            return Binding<Measurer.Axes?>.init(
                get: {
                    measurer.rotation
                },
                set: { _ in }
            )
        case .magneticField:
            return Binding<Measurer.Axes?>.init(
                get: {
                    measurer.magneticField
                },
                set: { _ in }
            )
        }
    }
    
    var body: some View {
        VStack {
            Spacer()
            DiagramView(axes: axesBinding)
            Spacer()
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
