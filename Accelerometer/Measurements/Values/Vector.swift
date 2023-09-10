//
//  Vector.swift
//  Accelerometer
//
//  Created by Andrey on 26.08.2023.
//

import Foundation

struct Vector {
    var current: Double
    var max: Double?
    var min: Double?
    
    mutating func update(newAxes: [Axe<Double>]) {
        updateCurrent(newAxes: newAxes)
        updateMinMax()
    }
    
    mutating func scale(by factor: Double) {
        max = factor * (max ?? 0.0)
        min = factor * (min ?? 0.0)
        current *= factor
    }
    
    private mutating func updateCurrent(newAxes: [Axe<Double>]) {
        let sumSquare = newAxes.reduce(0.0) { result, axe in 
            result + pow(axe.value, 2.0)
        }
        current = sqrt(sumSquare)
    }
    
    private mutating func updateMinMax() {
        max = Swift.max(current, max ?? current - 1)
        min = Swift.min(current, min ?? current + 1)
    }
}

extension Vector: AdditiveArithmetic {
    static func - (lhs: Vector, rhs: Vector) -> Vector {
        Vector(current: lhs.current - rhs.current)
    }
    
    static func + (lhs: Vector, rhs: Vector) -> Vector {
        Vector(current: lhs.current + rhs.current)
    }
    
    static var zero: Vector {
        Vector(current: 0.0)
    }
}
