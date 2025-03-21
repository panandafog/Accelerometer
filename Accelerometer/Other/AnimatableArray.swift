//
//  AnimatableArray.swift
//  Accelerometer
//
//  Created by Andrey on 30.06.2022.
//

import SwiftUI
import enum Accelerate.vDSP

struct AnimatableArray: VectorArithmetic {
    static let zero = AnimatableArray(values: [0.0])

    static func + (lhs: AnimatableArray, rhs: AnimatableArray) -> AnimatableArray {
        let count = min(lhs.values.count, rhs.values.count)
        return AnimatableArray(values: vDSP.add(lhs.values[0..<count], rhs.values[0..<count]))
    }

    static func += (lhs: inout AnimatableArray, rhs: AnimatableArray) {
        let count = min(lhs.values.count, rhs.values.count)
        vDSP.add(lhs.values[0..<count], rhs.values[0..<count], result: &lhs.values[0..<count])
    }

    static func - (lhs: AnimatableArray, rhs: AnimatableArray) -> AnimatableArray {
        let count = min(lhs.values.count, rhs.values.count)
        return AnimatableArray(values: vDSP.subtract(lhs.values[0..<count], rhs.values[0..<count]))
    }

    static func -= (lhs: inout AnimatableArray, rhs: AnimatableArray) {
        let count = min(lhs.values.count, rhs.values.count)
        vDSP.subtract(lhs.values[0..<count], rhs.values[0..<count], result: &lhs.values[0..<count])
    }

    var values: [Double]

    mutating func scale(by rhs: Double) {
        values = vDSP.multiply(rhs, values)
    }

    var magnitudeSquared: Double {
        vDSP.sum(vDSP.multiply(values, values))
    }
}
