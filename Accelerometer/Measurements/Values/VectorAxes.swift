//
//  VectorAxes.swift
//  Accelerometer
//
//  Created by Andrey on 26.08.2023.
//

import SwiftUI
import enum Accelerate.vDSP

protocol VectorAxes: Axes, ChartEntry, VectorArithmetic {
    var vector: Axis<ValueType> { get set }
    var intensityColor: Color { get }
}

extension VectorAxes {
    
    mutating func resetVector() {
        vector.min = vector.value
        vector.max = vector.value
    }
}

extension VectorAxes where ValueType == Double {
    
    func valueLabel(of type: AxeType) -> String? {
        guard type != .vector else {
            return label(for: vector.value)
        }
        
        guard let value = values[type]?.value else {
            return nil
        }
        return label(for: value)
    }
}
