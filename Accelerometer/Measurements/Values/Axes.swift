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
    
    var axes: [AxeType: Axe<ValueType>] { get set }
    /// Maximum displayed value
    var displayableAbsMax: ValueType { get }
    
    mutating func set(values: [AxeType: ValueType])
}

extension Axes {
    static func == (lhs: Self, rhs: Self) -> Bool {
        NSDictionary(dictionary: lhs.axes).isEqual(to: rhs.axes)
    }
}
