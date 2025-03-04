//
//  AxesSummaryViewExtended.swift
//  Accelerometer
//
//  Created by Andrey on 24.07.2022.
//

import SwiftUI

struct AxesSummaryViewExtended: View {
    @ObservedObject var measurer = Measurer.shared
    let type: MeasurementType
    
    private var observableAxes: ObservableAxes? {
        measurer.observableAxes[type]
    }
    
    private var vectorAxe: Axis<Double>? {
        (observableAxes?.axes as? TriangleAxes)?.vector
    }
    
    var axesBinding: Binding<ObservableAxes?> {
        Binding<ObservableAxes?>.init(
            get: {
                observableAxes
            },
            set: { _ in }
        )
    }
    
    private var maxString: String {
        if let vectorAxe = vectorAxe {
            return String(
                vectorAxe.max ?? 0,
                roundPlaces: Settings.measurementsDisplayRoundPlaces
            )
        } else {
            return "no data"
        }
    }
    
    private var minString: String {
        if let vectorAxe = vectorAxe {
            return String(
                vectorAxe.min ?? 0,
                roundPlaces: Settings.measurementsDisplayRoundPlaces
            )
        } else {
            return "no data"
        }
    }
    
    var body: some View {
        HStack {
            VStack {
                Text(maxString)
                
                AxesSummaryView(axesBinding: axesBinding, type: type)
                
                if type.hasMinimum {
                    Text(minString)
                }
            }
        }
    }
}

struct AxesSummaryViewExtended_Previews: PreviewProvider {
    
    // FIXME
    static let measurer1: Measurer = {
        let measurer = Measurer()
        var axes = TriangleAxes.zero
        axes.displayableAbsMax = 1.0
        measurer.saveData(
            axesType: TriangleAxes.self,
            measurementType: .userAcceleration,
            values: [
                .x: 0,
                .y: 0,
                .z: 0
            ]
        )
        measurer.saveData(
            axesType: TriangleAxes.self,
            measurementType: .magneticField,
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
        var axes = TriangleAxes.zero
        axes.displayableAbsMax = 1.0
        measurer.saveData(
            axesType: TriangleAxes.self,
            measurementType: .userAcceleration,
            values: [
                .x: 0.5,
                .y: 0.5,
                .z: 0.5
            ]
        )
        measurer.saveData(
            axesType: TriangleAxes.self,
            measurementType: .magneticField,
            values: [
                .x: 100,
                .y: 100,
                .z: 100
            ]
        )
        return measurer
    }()
    
    static let measurer3: Measurer = {
        let measurer = Measurer()
        var axes = TriangleAxes.zero
        axes.displayableAbsMax = 1.0
        measurer.saveData(
            axesType: TriangleAxes.self,
            measurementType: .userAcceleration,
            values: [
                .x: 1,
                .y: 1,
                .z: 1
            ]
        )
        measurer.saveData(
            axesType: TriangleAxes.self,
            measurementType: .magneticField,
            values: [
                .x: 200,
                .y: 200,
                .z: 200
            ]
        )
        return measurer
    }()
    
    static var previews: some View {
        Group {
            AxesSummaryViewExtended(measurer: measurer1, type: .userAcceleration)
                .padding()
                .previewLayout(.sizeThatFits)
            AxesSummaryViewExtended(measurer: measurer2, type: .userAcceleration)
                .padding()
                .previewLayout(.sizeThatFits)
            AxesSummaryViewExtended(measurer: measurer3, type: .userAcceleration)
                .padding()
                .previewLayout(.sizeThatFits)
            AxesSummaryViewExtended(measurer: measurer1, type: .magneticField)
                .padding()
                .previewLayout(.sizeThatFits)
            AxesSummaryViewExtended(measurer: measurer2, type: .magneticField)
                .padding()
                .previewLayout(.sizeThatFits)
            AxesSummaryViewExtended(measurer: measurer3, type: .magneticField)
                .padding()
                .previewLayout(.sizeThatFits)
        }
    }
}
