//
//  AttitudeAxes.swift
//  Accelerometer
//
//  Created by Andrey on 10.09.2023.
//

import SwiftUI

struct AttitudeAxes: Axes {
    
    typealias ValueType = Double
    
    static var axesTypes: Set<AxeType> { [.roll, .pitch, .yaw] }
    
    var values: [AxeType : Axis<ValueType>]
    var measurementType: MeasurementType?
    var displayableAbsMax: ValueType
    
    mutating func set(values newValues: [AxeType : ValueType]) {
        // TODO: remove copy-paste
        Self.axesTypes.forEach {
            var axis = values[$0]
            if let newValue = newValues[$0] {
                axis?.set(value: newValue)
            }
            values[$0] = axis
        }
    }
    
    static let zero: AttitudeAxes = .init()
    
    init(axes: [AxeType : Axis<ValueType>]? = nil, measurementType: MeasurementType? = nil, displayableAbsMax: ValueType = .zero) {
        self.values = axes ?? [
            .roll: Axis(type_: .roll, value: .zero),
            .pitch: Axis(type_: .pitch, value: .zero),
            .yaw: Axis(type_: .yaw, value: .zero)
        ]
        self.measurementType = measurementType
        self.displayableAbsMax = displayableAbsMax
    }
    
    func valueLabel(of type: AxeType) -> String? {
        guard let value = values[type]?.value else {
            return nil
        }
        return String(
            value,
            roundPlaces: Measurer.measurementsDisplayRoundPlaces
        ) + " \(measurementType?.unit ?? "")"
    }
}
