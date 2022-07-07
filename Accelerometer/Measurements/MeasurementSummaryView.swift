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
        GeometryReader { geometryVStack in
        VStack {
            Spacer()
//            HStack(alignment: .center) {
//                GeometryReader { geometryHStack in
//                    let size = geometryHStack.size.width * 0.5
//                    DiagramView(axes: axesBinding)
//                        .frame(width: size, height: size)
//                }
//            }
            DiagramView(axes: axesBinding)
            .frame(height: geometryVStack.size.width * 0.5)
            .padding([.horizontal])
            .padding()
            Spacer()
                .frame(height: geometryVStack.size.height * 0.05)
            MeasurementsAxesView(axes: axesBinding)
                .padding()
            Spacer()
        }
        .navigationTitle(type.name)
        }
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
