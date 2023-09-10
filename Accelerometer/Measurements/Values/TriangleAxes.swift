//
//  TriangleAxes.swift
//  Accelerometer
//
//  Created by Andrey on 26.08.2023.
//

import SwiftUI
import enum Accelerate.vDSP

struct TriangleAxes: VectorAxes {

    typealias ValueType = Double
    
    static var axesTypes: Set<AxeType> { [.x, .y, .z] }
    
    static var zero: TriangleAxes {
        .init(
            axes: [
                .x: Axe(type_: .x, value: .zero),
                .y: Axe(type_: .y, value: .zero),
                .z: Axe(type_: .z, value: .zero)
            ],
            displayableAbsMax: ValueType.zero,
            vector: .zero
        )
    }
    
    var axes: [AxeType: Axe<ValueType>]
    var displayableAbsMax: ValueType
    var vector: Axe<ValueType>
    
    var intensityColor: Color {
        let intensity = abs(vector.value) / displayableAbsMax
        return Color.intensity(intensity)
    }
    
    mutating func set(values: [AxeType: ValueType]) {
        Self.axesTypes.forEach {
            var axe = axes[$0]
            if let value = values[$0] {
                axe?.set(value: value)
            }
            axes[$0] = axe
        }
        updateVector()
    }
    
    private mutating func updateVector() {
        vector.set(value: sqrt(
            pow(axes[.x]?.value ?? 0.0, 2.0) +
            pow(axes[.y]?.value ?? 0.0, 2.0) +
            pow(axes[.z]?.value ?? 0.0, 2.0)
        ))
    }
}

extension TriangleAxes: AdditiveArithmetic {
    static func - (lhs: TriangleAxes, rhs: TriangleAxes) -> TriangleAxes {
        var axes: [AxeType: Axe<ValueType>] = [:]
        axesTypes.forEach { axesType in
            axes[axesType] = (lhs.axes[axesType] ?? Axe<ValueType>.zero) - (rhs.axes[axesType] ?? Axe<ValueType>.zero)
        }
        return TriangleAxes(
            axes: axes,
            displayableAbsMax: lhs.displayableAbsMax - rhs.displayableAbsMax,
            vector: lhs.vector - rhs.vector
        )
    }
    
    static func + (lhs: TriangleAxes, rhs: TriangleAxes) -> TriangleAxes {
        var axes: [AxeType: Axe<ValueType>] = [:]
        axesTypes.forEach { axesType in
            axes[axesType] = (lhs.axes[axesType] ?? Axe<ValueType>.zero) + (rhs.axes[axesType] ?? Axe<ValueType>.zero)
        }
        return TriangleAxes(
            axes: axes,
            displayableAbsMax: lhs.displayableAbsMax + rhs.displayableAbsMax,
            vector: lhs.vector + rhs.vector
        )
    }
}

extension TriangleAxes: VectorArithmetic {
    mutating func scale(by rhs: Double) {
        axes.keys.forEach {
            var axe = axes[$0]
            axe?.scale(by: rhs)
            axes[$0] = axe
        }
    }
    
    var magnitudeSquared: Double {
        let values = Array(axes.values).map { $0.value }
        return vDSP.sum(vDSP.multiply(values, values))
    }
}
