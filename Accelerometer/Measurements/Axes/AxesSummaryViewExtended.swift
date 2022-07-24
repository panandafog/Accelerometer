//
//  AxesSummaryViewExtended.swift
//  Accelerometer
//
//  Created by Andrey on 24.07.2022.
//

import SwiftUI

struct AxesSummaryViewExtended: View {
    @ObservedObject var measurer = Measurer.shared
    let type: Measurer.MeasurementType
    
    var axes: Axes? {
        measurer.axes(of: type)
    }
    
    var body: some View {
        HStack {
            VStack {
                Text(
                    String(
                        axes?.properties.maxV ?? 0.0,
                        roundPlaces: Measurer.measurementsDisplayRoundPlaces
                    )
                )
                AxesSummaryView(measurer: measurer, type: type)
                Text(
                    String(
                        axes?.properties.minV ?? 0.0,
                        roundPlaces: Measurer.measurementsDisplayRoundPlaces
                    )
                )
            }
        }
    }
}

struct AxesSummaryViewExtended_Previews: PreviewProvider {
    
    static let measurer1: Measurer = {
        let measurer = Measurer()
        measurer.deviceMotion = .init(displayableAbsMax: 1.0)
        measurer.saveData(x: 0, y: 0, z: 0, type: .deviceMotion)
        return measurer
    }()
    
    static let measurer2: Measurer = {
        let measurer = Measurer()
        measurer.deviceMotion = .init(displayableAbsMax: 1.0)
        measurer.saveData(x: 0.5, y: 0.5, z: 0.5, type: .deviceMotion)
        return measurer
    }()
    
    static let measurer3: Measurer = {
        let measurer = Measurer()
        measurer.deviceMotion = .init(displayableAbsMax: 1.0)
        measurer.saveData(x: 1, y: 1, z: 1, type: .deviceMotion)
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
        }
    }
}
