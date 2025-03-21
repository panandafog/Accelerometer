//
//  MagnitudeAxes.swift
//  Accelerometer
//
//  Created by Andrey on 26.08.2023.
//

import SwiftUI
import enum Accelerate.vDSP

protocol MagnitudeAxes: Axes, ChartEntry, VectorArithmetic {
    var magnitude: Axis<ValueType> { get set }
    var intensityColor: Color { get }
}

extension MagnitudeAxes {
    
    mutating func resetMagnitude() {
        magnitude.min = magnitude.value
        magnitude.max = magnitude.value
    }
}

extension MagnitudeAxes where ValueType == Double {
    
    func valueLabel(of type: AxeType) -> String? {
        guard type != .magnitude else {
            return label(for: magnitude.value)
        }
        
        guard let value = values[type]?.value else {
            return nil
        }
        return label(for: value)
    }
}
