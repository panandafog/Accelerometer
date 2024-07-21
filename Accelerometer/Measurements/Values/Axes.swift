//
//  Axes.swift
//  Accelerometer
//
//  Created by Andrey on 26.08.2023.
//

import Foundation

protocol Axes: Equatable {
    associatedtype ValueType: LosslessStringConvertible, Comparable
    
    static var axesTypes: Set<AxeType> { get }
    
    static var zero: Self { get }
    
    var values: [AxeType: Axis<ValueType>] { get set }
    var measurementType: MeasurementType? { get set }
    /// Maximum displayed value
    var displayableAbsMax: ValueType { get set }
    
    mutating func set(values: [AxeType: ValueType])
    
    func valueLabel(of type: AxeType) -> String?
}

extension Axes {
    static func == (lhs: Self, rhs: Self) -> Bool {
        NSDictionary(dictionary: lhs.values).isEqual(to: rhs.values)
    }
    
    static var sortedAxesTypes: [AxeType] {
        Array(axesTypes).sorted { $0.rawValue > $1.rawValue }
    }
}

extension Axes where ValueType == Double {
    func valueLabel(of type: AxeType) -> String? {
        guard let value = values[type]?.value else {
            return "???"
        }
        return label(for: value)
    }
    
    func label(for value: ValueType) -> String {
        String(
            value,
            roundPlaces: Measurer.measurementsDisplayRoundPlaces
        ) + " \(measurementType?.unit ?? "")"
    }
}
