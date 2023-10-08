//
//  AxeType.swift
//  Accelerometer
//
//  Created by Andrey on 23.07.2022.
//

import Foundation

enum AxeType: String, CaseIterable {
    case x
    case y
    case z
    case roll
    case pitch
    case yaw
    case vector
    case unnamed
}

extension AxeType: Identifiable {
  var id: Self { self }
}
