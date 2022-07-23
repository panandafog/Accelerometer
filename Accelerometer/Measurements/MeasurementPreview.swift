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
            }.layoutPriority(1)
            Spacer()
            ZStack(alignment: .trailing) {
                Color.clear
                DiagramView(axes: axesBinding)
                    .frame(width: 70, height: 70)
            }
            .padding()
        }
    }
}

struct MeasurementPreview_Previews: PreviewProvider {
    static var previews: some View {
        let measurer = Measurer.shared
        measurer.saveData(x: 0.03, y: 0.03, z: 0.03, type: .deviceMotion)
        return MeasurementPreview(measurer: measurer, type: .deviceMotion)
    }
}
