//
//  VectorAxes.swift
//  Accelerometer
//
//  Created by Andrey on 26.08.2023.
//

import SwiftUI
import enum Accelerate.vDSP

protocol VectorAxes: Axes, VectorArithmetic {
    var vector: Axe<ValueType> { get }
    var intensityColor: Color { get }
}
