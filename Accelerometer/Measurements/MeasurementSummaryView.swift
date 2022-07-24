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
                HStack {
                    Text(type.description)
                        .padding()
                        .padding([.horizontal])
                    
                    ZStack(alignment: .topTrailing) {
                        let diagramSize = geometryVStack.size.width * 0.3
                        DiagramView(axes: axesBinding)
                            .frame(width: diagramSize, height: diagramSize)
                            .padding()
                    }
                }
                Spacer()
                MeasurementsAxesView(axes: axesBinding)
                    .padding()
                Spacer()
            }
            .navigationTitle(type.name)
        }
        .toolbar {
            Button("Reset min / max") {
                measurer.reset(type)
            }
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
