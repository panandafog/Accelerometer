//
//  MeasurementPreview.swift
//  Accelerometer
//
//  Created by Andrey on 07.07.2022.
//

import SwiftUI

struct MeasurementPreview: View {
    @ObservedObject var measurer = Measurer.shared
    let type: Measurer.MeasurementType
    
    var axes: Axes? {
        measurer.axes(of: type)
    }
    
    var axesBinding: Binding<Axes?> {
        Binding<Axes?>.init(
            get: {
                axes
            },
            set: { _ in }
        )
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(type.name)
                    .font(.title2)
                    .padding()
                Text(String(axes?.properties.vector ?? 0.0, roundPlaces: Measurer.measurementsDisplayRoundPlaces) + " \(type.unit)")
                    .padding()
            }
            Spacer()
            DiagramView(axes: axesBinding)
                .frame(width: 100, height: 100, alignment: .trailing)
                .padding()
                .padding([.top])
        }
    }
}

struct MeasurementPreview_Previews: PreviewProvider {
    static var previews: some View {
        MeasurementSummaryView(type: .deviceMotion)
    }
}
