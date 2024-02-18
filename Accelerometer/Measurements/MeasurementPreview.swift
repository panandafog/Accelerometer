//
//  MeasurementPreview.swift
//  Accelerometer
//
//  Created by Andrey on 07.07.2022.
//

import SwiftUI

struct MeasurementPreview: View {
    @ObservedObject var measurer = Measurer.shared
    let type: MeasurementType
    
    var observableAxes: ObservableAxes? {
        measurer.observableAxes[type]
    }
    
    var observableAxesBinding: Binding<ObservableAxes?> {
        Binding<ObservableAxes?>.init(
            get: {
                observableAxes
            },
            set: { _ in }
        )
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(type.name.capitalizingFirstLetter())
                    .font(.title2)
                    .padding([.vertical])
                AxesSummaryView(axesBinding: observableAxesBinding, type: type)
                    .padding([.horizontal, .bottom])
            }.layoutPriority(1)
            if observableAxes?.axes.measurementType?
                .supportsDiagramRepresentation ?? false {
                Spacer()
                ZStack(alignment: .trailing) {
                    Color.clear
                    DiagramView(axes: observableAxesBinding)
                        .frame(width: 70, height: 70)
                }
                .frame(minWidth: 70, minHeight: 70)
                .padding()
            }
        }
    }
}

struct MeasurementPreview_Previews: PreviewProvider {
    
    static let measurer: Measurer = {
        let measurer = Measurer()
        measurer.saveData(
            axesType: TriangleAxes.self,
            measurementType: .userAcceleration,
            values: [
                .x: 0.5,
                .y: 0.5,
                .z: 0.5
            ]
        )
        return measurer
    }()
    
    static var previews: some View {
        MeasurementPreview(measurer: measurer, type: .userAcceleration)
            .previewLayout(.sizeThatFits)
    }
}
