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
    
    var axesBinding: Binding<Axes?> {
        Binding<Axes?>.init(
            get: {
                measurer.axes(of: type)
            },
            set: { _ in }
        )
    }
    
    var body: some View {
        VStack {
            Spacer()
            GeometryReader { geometry in
                let size = geometry.size.width * 0.5
                HStack {
                    DiagramView(axes: axesBinding)
                        .frame(width: size, height: size)
                    Spacer()
                }
                .padding([.horizontal])
                .padding()
            }
            MeasurementsAxesView(axes: axesBinding)
                .padding([.bottom])
            Spacer()
        }
        .navigationTitle(type.name)
    }
}

struct MeasurementSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        let measurer = Measurer.shared
        let view = MeasurementSummaryView(measurer: measurer, type: .deviceMotion)
        view.measurer.deviceMotion = .init(displayableAbsMax: 1.0)
        view.measurer.deviceMotion?.properties.setValues(x: 0.5, y: 1, z: 0.2)
        return view
    }
}
