//
//  Bool.swift
//  Accelerometer
//
//  Created by Andrey on 18.02.2024.
//

import Foundation
import Charts

extension Bool: @retroactive Comparable {
    public static func < (lhs: Bool, rhs: Bool) -> Bool {
        (lhs == false) && (rhs == true)
    }
}

extension Bool: @retroactive Plottable {
    public typealias PrimitivePlottable = Double

    public var primitivePlottable: Double {
        self ? 1.0 : 0.0
    }

    public init?(primitivePlottable: Double) {
        switch primitivePlottable {
        case 0.0:
            self = false
        case 1.0:
            self = true
        default:
            return nil
        }
    }
}
