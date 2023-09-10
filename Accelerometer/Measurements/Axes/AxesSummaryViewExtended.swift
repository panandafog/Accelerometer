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
    
    var axes: ObservableAxes<TriangleAxes>? {
        measurer.axes(of: type)
    }
    
    var body: some View {
        HStack {
            VStack {
                Text(
                    String(
                        axes?.properties.vector.max ?? 0.0,
                        roundPlaces: Measurer.measurementsDisplayRoundPlaces
                    )
                )
                
                AxesSummaryView(measurer: measurer, type: type)
                
                if type.hasMinimum {
                    Text(
                        String(
                            axes?.properties.vector.max ?? 0.0,
                            roundPlaces: Measurer.measurementsDisplayRoundPlaces
                        )
                    )
                }
            }
        }
    }
}

struct AxesSummaryViewExtended_Previews: PreviewProvider {
    
    static let measurer1: Measurer = {
        let measurer = Measurer()
        var axes = TriangleAxes.zero
        axes.displayableAbsMax = 1.0
        measurer.deviceMotion = ObservableAxes(axes: axes)
        measurer.saveData(x: 0, y: 0, z: 0, type: .deviceMotion)
        measurer.saveData(x: 0, y: 0, z: 0, type: .magneticField)
        return measurer
    }()
    
    static let measurer2: Measurer = {
        let measurer = Measurer()
        var axes = TriangleAxes.zero
        axes.displayableAbsMax = 1.0
        measurer.deviceMotion = ObservableAxes(axes: axes)
        measurer.saveData(x: 0.5, y: 0.5, z: 0.5, type: .deviceMotion)
        measurer.saveData(x: 100, y: 100, z: 100, type: .magneticField)
        return measurer
    }()
    
    static let measurer3: Measurer = {
        let measurer = Measurer()
        var axes = TriangleAxes.zero
        axes.displayableAbsMax = 1.0
        measurer.deviceMotion = ObservableAxes(axes: axes)
        measurer.saveData(x: 1, y: 1, z: 1, type: .deviceMotion)
        measurer.saveData(x: 200, y: 200, z: 200, type: .magneticField)
        return measurer
    }()
    
    static var previews: some View {
        Group {
            AxesSummaryViewExtended(measurer: measurer1, type: .deviceMotion)
                .padding()
                .previewLayout(.sizeThatFits)
            AxesSummaryViewExtended(measurer: measurer2, type: .deviceMotion)
                .padding()
                .previewLayout(.sizeThatFits)
            AxesSummaryViewExtended(measurer: measurer3, type: .deviceMotion)
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
