//
//  AxeType.swift
//  Accelerometer
//
//  Created by Andrey on 23.07.2022.
//

import Foundation

enum AxeType: String, CaseIterable, Sendable {
    case x
    case y
    case z
    case roll
    case pitch
    case yaw
    case magnitude
    case bool
    case unnamed
    
    var name: String {
        switch self {
        case .x, .y, .z:
            rawValue
        case .roll:
            String(localized: "axis.roll")
        case .pitch:
            String(localized: "axis.pitch")
        case .yaw:
            String(localized: "axis.yaw")
        case .magnitude:
            String(localized: "axis.magnitude")
        case .bool:
            String(localized: "axis.boolean")
        case .unnamed:
            String(localized: "axis.unnamed")
        }
    }
}

extension AxeType: Identifiable {
  var id: Self { self }
}
