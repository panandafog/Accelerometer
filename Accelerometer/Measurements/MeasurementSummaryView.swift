//
//  MeasurementSummaryView.swift
//  Accelerometer
//
//  Created by Andrey on 22.06.2022.
//

import SwiftUI

struct MeasurementSummaryView: View {
    @ObservedObject var measurer = Measurer.shared
    let type: MeasurementType
    
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
                Text(type.description)
                    .padding()
                    .padding([.horizontal])
                
                HStack (spacing: geometryVStack.size.width * 0.1) {
//                    Spacer()
                    let diagramSize = geometryVStack.size.width * 0.3
                    AxesSummaryViewExtended(measurer: measurer, type: type)
                        .frame(width: diagramSize, height: diagramSize)
//                    Spacer()
                    DiagramView(axes: axesBinding)
                        .frame(width: diagramSize, height: diagramSize)
                        .padding()
//                    .frame(maxWidth: .infinity)
//                    Spacer()
                }
                
                MeasurementsAxesView(axes: axesBinding, showSummary: false)
                    .padding()
//                Spacer()
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
    
    static let measurer: Measurer = {
        let measurer = Measurer()
        measurer.saveData(x: 0.5, y: 1, z: 0.2, type: .acceleration)
        return measurer
    }()
    
    static var previews: some View {
        MeasurementSummaryView(measurer: measurer, type: .acceleration)
    }
}
