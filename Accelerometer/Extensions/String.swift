//
//  String.swift
//  Accelerometer
//
//  Created by Andrey on 21.06.2022.
//

import Foundation

extension String {
    
    init(_ value: Double, roundPlaces: Int) {
        self.init(format: "%.\(roundPlaces)f", value)
    }
}
