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
    
    func capitalizingFirstLetter() -> String {
        prefix(1).capitalized + dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
