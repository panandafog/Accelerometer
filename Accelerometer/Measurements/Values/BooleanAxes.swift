//
//  BooleanAxes.swift
//  Accelerometer
//
//  Created by Andrey on 18.02.2024.
//

import Foundation

final class BooleanAxes: Axes {
    typealias ValueType = Bool
    
    static var axesTypes: Set<AxeType> { [.bool] }
    
    static let zero: BooleanAxes = BooleanAxes()
    
    var measurementType: MeasurementType?
    
    var values: [AxeType: Axis<ValueType>]
    
    var displayableAbsMax: ValueType
    
    init(
        axes: [AxeType : Axis<ValueType>]? = nil,
        measurementType: MeasurementType? = nil, 
        displayableAbsMax: ValueType = true
    ) {
        self.values = axes ?? [
            AxeType.bool: Axis(type_: .bool, value: false)
        ]
        self.measurementType = measurementType
        self.displayableAbsMax = displayableAbsMax
    }
    
    func set(values newValues: [AxeType: ValueType]) {
        Self.axesTypes.forEach {
            var axis = values[$0]
            if let newValue = newValues[$0] {
                axis?.set(value: newValue)
            }
            values[$0] = axis
        }
    }
    
    func valueLabel(of type: AxeType) -> String? {
        guard let value = values[type]?.value else {
            return nil
        }
        return value ? "close" : "far"
    }
}
