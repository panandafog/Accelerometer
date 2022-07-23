//
//  Double.swift
//  Accelerometer
//
//  Created by Andrey on 21.06.2022.
//

import Foundation

extension Double {
    
    static func degrees(radians: Double) -> Double {
        return radians * 180.0 / .pi
    }
    
    static func radians(degrees: Double) -> Double {
        return degrees * .pi / 180.0
    }
    
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
