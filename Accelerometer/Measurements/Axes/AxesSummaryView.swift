//
//  AxesSummaryView.swift
//  Accelerometer
//
//  Created by Andrey on 23.07.2022.
//

import SwiftUI

struct AxesSummaryView: View {
    @ObservedObject var measurer = Measurer.shared
    let type: Measurer.MeasurementType
    
    var axes: Axes? {
        measurer.axes(of: type)
    }
    
    var body: some View {
        Text((measurer.valueLabel(of: type) ?? "0.0"))
            .padding(8)
            .background(
                (axes?.color ?? .clear)
                    .animation(.linear)
            )
            .cornerRadius(10)
    }
}

struct AxesSummaryView_Previews: PreviewProvider {
    
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
            AxesSummaryView(measurer: measurer1, type: .deviceMotion)
                .padding()
                .previewLayout(.sizeThatFits)
            AxesSummaryView(measurer: measurer2, type: .deviceMotion)
                .padding()
                .previewLayout(.sizeThatFits)
            AxesSummaryView(measurer: measurer3, type: .deviceMotion)
                .padding()
                .previewLayout(.sizeThatFits)
        }
    }
}

extension Axes {
    
    var color: Color {
        let intensity = abs(properties.vector) / properties.displayableAbsMax
        return Color.intensity(intensity, opacity: 1.0)
    }
}
