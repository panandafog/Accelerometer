//
//  AxesSummaryView.swift
//  Accelerometer
//
//  Created by Andrey on 23.07.2022.
//

import SwiftUI

struct AxesSummaryView: View {
    @ObservedObject var measurer = Measurer.shared
    let type: MeasurementType
    
    var observableAxes: ObservableAxes? {
        measurer.observableAxes[type]
    }
    
    var triangleAxes: TriangleAxes? {
        observableAxes?.axes as? TriangleAxes
    }
    
    var body: some View {
        Text(triangleAxes?.valueLabel ?? "unsupported data type")
            .padding(.defaultPadding)
            .background(
                (triangleAxes?.intensityColor ?? .clear)
                    .animation(.linear)
            )
            .cornerRadius(.defaultCornerRadius)
    }
}

struct AxesSummaryView_Previews: PreviewProvider {
    
    static let measurer1: Measurer = {
        let measurer = Measurer()
        measurer.saveData(
            axesType: TriangleAxes.self,
            measurementType: .userAcceleration,
            values: [
                .x: 0,
                .y: 0,
                .z: 0
            ]
        )
        return measurer
    }()
    
    static let measurer2: Measurer = {
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
    
    static let measurer3: Measurer = {
        let measurer = Measurer()
        measurer.saveData(
            axesType: TriangleAxes.self,
            measurementType: .userAcceleration,
            values: [
                .x: 1,
                .y: 1,
                .z: 1
            ]
        )
        return measurer
    }()
    
    static var previews: some View {
        Group {
            AxesSummaryView(measurer: measurer1, type: .userAcceleration)
                .padding()
                .previewLayout(.sizeThatFits)
            AxesSummaryView(measurer: measurer2, type: .userAcceleration)
                .padding()
                .previewLayout(.sizeThatFits)
            AxesSummaryView(measurer: measurer3, type: .userAcceleration)
                .padding()
                .previewLayout(.sizeThatFits)
            AxesSummaryView(measurer: measurer1, type: .userAcceleration)
                .padding()
                .previewLayout(.sizeThatFits)
                .preferredColorScheme(.dark)
            AxesSummaryView(measurer: measurer2, type: .userAcceleration)
                .padding()
                .previewLayout(.sizeThatFits)
                .preferredColorScheme(.dark)
            AxesSummaryView(measurer: measurer3, type: .userAcceleration)
                .padding()
                .previewLayout(.sizeThatFits)
                .preferredColorScheme(.dark)
        }
    }
}
