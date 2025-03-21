//
//  TriangleAxes.swift
//  Accelerometer
//
//  Created by Andrey on 26.08.2023.
//

import SwiftUI
import enum Accelerate.vDSP

struct TriangleAxes: MagnitudeAxes {

    typealias ValueType = Double
    
    static var axesTypes: Set<AxeType> { [.x, .y, .z] }
    
    static let zero: TriangleAxes = .init()
    
    var values: [AxeType: Axis<ValueType>]
    var measurementType: MeasurementType?
    var displayableAbsMax: ValueType
    var magnitude: Axis<ValueType>
    
    var intensityColor: Color {
        let intensity = abs(magnitude.value) / displayableAbsMax
        return Color.intensity(intensity)
    }
    
    var chartValues: [Double] {
        [magnitude.value as Double]
    }
    
    init(
        axes: [AxeType : Axis<ValueType>]? = nil,
        measurementType: MeasurementType? = nil,
        displayableAbsMax: ValueType = .zero,
        magnitude: Axis<ValueType> = .zero
    ) {
        self.values = axes ?? [
            .x: Axis(type_: .x, value: .zero),
            .y: Axis(type_: .y, value: .zero),
            .z: Axis(type_: .z, value: .zero)
        ]
        self.measurementType = measurementType
        self.displayableAbsMax = displayableAbsMax
        self.magnitude = magnitude
    }
    
    mutating func set(values newValues: [AxeType: ValueType]) {
        Self.axesTypes.forEach {
            var axis = values[$0]
            if let newValue = newValues[$0] {
                axis?.set(value: newValue)
            }
            values[$0] = axis
        }
        updateMagnitude()
    }
    
    private mutating func updateMagnitude() {
        let x = values[.x]?.value ?? 0.0
        let y = values[.y]?.value ?? 0.0
        let z = values[.z]?.value ?? 0.0
        
        magnitude.set(value: hypot(hypot(x, y), z))
    }
}

extension TriangleAxes: AdditiveArithmetic {
    static func - (lhs: TriangleAxes, rhs: TriangleAxes) -> TriangleAxes {
        var axes: [AxeType: Axis<ValueType>] = [:]
        axesTypes.forEach { axesType in
            axes[axesType] = (lhs.values[axesType] ?? Axis<ValueType>.zero) - (rhs.values[axesType] ?? Axis<ValueType>.zero)
        }
        return TriangleAxes(
            axes: axes,
            displayableAbsMax: lhs.displayableAbsMax - rhs.displayableAbsMax,
            magnitude: lhs.magnitude - rhs.magnitude
        )
    }
    
    static func + (lhs: TriangleAxes, rhs: TriangleAxes) -> TriangleAxes {
        var axes: [AxeType: Axis<ValueType>] = [:]
        axesTypes.forEach { axesType in
            axes[axesType] = (lhs.values[axesType] ?? Axis<ValueType>.zero) + (rhs.values[axesType] ?? Axis<ValueType>.zero)
        }
        return TriangleAxes(
            axes: axes,
            displayableAbsMax: lhs.displayableAbsMax + rhs.displayableAbsMax,
            magnitude: lhs.magnitude + rhs.magnitude
        )
    }
}

extension TriangleAxes: VectorArithmetic {
    mutating func scale(by rhs: Double) {
        values.keys.forEach {
            var axe = values[$0]
            axe?.scale(by: rhs)
            values[$0] = axe
        }
    }
    
    var magnitudeSquared: Double {
        let values = Array(values.values).map { $0.value }
        return vDSP.sum(vDSP.multiply(values, values))
    }
}
