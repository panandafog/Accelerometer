//
//  Bool.swift
//  Accelerometer
//
//  Created by Andrey on 18.02.2024.
//

import Foundation

extension Bool: Comparable {
    public static func < (lhs: Bool, rhs: Bool) -> Bool {
        (lhs == false) && (rhs == true)
    }
}
