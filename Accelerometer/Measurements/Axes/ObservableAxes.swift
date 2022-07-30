//
//  ObservableAxes.swift
//  Accelerometer
//
//  Created by Andrey on 04.07.2022.
//

import SwiftUI

final class ObservableAxes: ObservableObject {
    
    @Published var properties: Axes
    
    init(displayableAbsMax: Double) {
        properties = .zero
        properties.displayableAbsMax = displayableAbsMax
    }
    
    func reset() {
        properties = Axes(
            x: 0,
            y: 0,
            z: 0,
            minX: nil,
            minY: nil,
            minZ: nil,
            maxX: nil,
            maxY: nil,
            maxZ: nil,
            displayableAbsMax: properties.displayableAbsMax
        )
    }
}

extension ObservableAxes {
    
    var intensityColor: Color {
        let intensity = abs(properties.vector) / properties.displayableAbsMax
        return Color.intensity(intensity)
    }
}
