//
//  VectorAxes.swift
//  Accelerometer
//
//  Created by Andrey on 26.08.2023.
//

import SwiftUI
import enum Accelerate.vDSP

protocol VectorAxes: Axes, VectorArithmetic {
    var vector: Axis<ValueType> { get }
    var valueLabel: String { get }
    var intensityColor: Color { get }
}
