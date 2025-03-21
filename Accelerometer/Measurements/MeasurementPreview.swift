//
//  MeasurementPreview.swift
//  Accelerometer
//
//  Created by Andrey on 07.07.2022.
//

import SwiftUI

struct MeasurementPreview: View {
    @EnvironmentObject var measurer: Measurer
    
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
    
    static let settings = Settings()
    
    static let measurer: Measurer = {
        let measurer = Measurer(settings: settings)
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
        MeasurementPreview(type: .userAcceleration)
            .previewLayout(.sizeThatFits)
            .environmentObject(settings)
            .environmentObject(measurer)
    }
}
