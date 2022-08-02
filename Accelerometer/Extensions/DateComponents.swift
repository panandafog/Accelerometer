//
//  DateComponents.swift
//  Accelerometer
//
//  Created by Andrey on 01.08.2022.
//

import Foundation

extension DateComponents {
    
    var durationString: String {
        var stringArray = [String(hour ?? 0), String(minute ?? 0), String(second ?? 0)]
        if hour ?? 0 == 0 {
            stringArray.remove(at: 0)
        }
        
        let requiredLength = 2
        
        for index in 0 ..< stringArray.count {
            if stringArray[index].count < requiredLength {
                let additionalCharacters = String(repeating: "0", count: requiredLength - stringArray[index].count)
                stringArray[index] = additionalCharacters + stringArray[index]
            }
        }
        
        return stringArray.joined(separator: ":")
    }
}
