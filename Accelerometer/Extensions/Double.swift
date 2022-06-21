//
//  Double.swift
//  Accelerometer
//
//  Created by Andrey on 21.06.2022.
//

import Foundation

extension Double {
    
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
