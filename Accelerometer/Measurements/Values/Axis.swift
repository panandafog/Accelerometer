//
//  Axis.swift
//  Accelerometer
//
//  Created by Andrey on 26.08.2023.
//

import SwiftUI

struct Axis<T>: Sendable where T: Comparable, T: LosslessStringConvertible, T: Sendable {
    let type_: AxeType
    var value: T
    var min: T?
    var max: T?
    
    mutating func set(value newValue: T) {
        value = newValue
        
        if let max = max {
            self.max = Swift.max(value, max)
        } else {
            self.max = value
        }
        
        if let min = min {
            self.min = Swift.min(value, min)
        } else {
            self.min = value
        }
    }
}

extension Axis: Equatable where T: Equatable {
    static func == (lhs: Axis<T>, rhs: Axis<T>) -> Bool {
        lhs.type_ == rhs.type_ &&
        lhs.value == rhs.value &&
        lhs.min == rhs.min &&
        lhs.max == rhs.max
    }
}

extension Axis: AdditiveArithmetic where T: AdditiveArithmetic {
    static func - (lhs: Axis<T>, rhs: Axis<T>) -> Axis<T> {
        Axis<T>(
            type_: lhs.type_,
            value: lhs.value - rhs.value,
            min: (lhs.min ?? T.zero) - (rhs.min ?? T.zero),
            max: (lhs.max ?? T.zero) - (rhs.max ?? T.zero)
        )
    }
    
    static func + (lhs: Axis<T>, rhs: Axis<T>) -> Axis<T> {
        Axis<T>(
            type_: lhs.type_,
            value: lhs.value + rhs.value,
            min: (lhs.min ?? T.zero) + (rhs.min ?? T.zero),
            max: (lhs.max ?? T.zero) + (rhs.max ?? T.zero)
        )
    }
    
    static var zero: Axis<T> {
        Axis<T>(
            type_: .unnamed,
            value: T.zero
        )
    }
}

// For VectorArithmetic
extension Axis where T == Double {
    mutating func scale(by rhs: Double) {
        value *= rhs
        min = (min ?? T.zero) * rhs
        max = (max ?? T.zero) * rhs
    }
}
