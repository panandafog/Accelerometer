//
//  Recording.swift
//  Accelerometer
//
//  Created by Andrey on 29.07.2022.
//

import Foundation

struct Recording: Identifiable {
    
    let id = UUID().uuidString
    
    var entries: [Entry]
    var state: State
    let measuremntTypes: [MeasurementType]
    
    var start: Date? {
        entries.first?.date
    }
    
    var end: Date? {
        entries.last?.date
    }
    
    //    var measuremntTypes: [MeasurementType] {
    //        guard let keys = entries.first?.measurements.keys else {
    //            return []
    //        }
    //        return Array(keys)
    //    }
}

extension Recording {
    
    enum State {
        case inProgress
        case completed
    }
    
    struct Entry: Identifiable {
        
        let id = UUID().uuidString
        
        let measurementType: MeasurementType
        let date: Date
        let value: Axes?
    }
    
//    struct Entry {
//        let measurements: [MeasurementType: Axes]
//        let date: Date
//    }
}
