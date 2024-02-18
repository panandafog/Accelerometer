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
    
    func set(values: [AxeType: ValueType]) {
        
    }
}
