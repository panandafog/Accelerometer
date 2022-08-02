//
//  Recording.swift
//  Accelerometer
//
//  Created by Andrey on 29.07.2022.
//

import Foundation

struct Recording: Identifiable {
    
    let id = UUID().uuidString
    let created = Date()
    
    var entries: [Entry]
    var state: State
    let measurementTypes: Set<MeasurementType>
    
    var start: Date? {
        entries.first?.date ?? created
    }
    
    var end: Date? {
        entries.last?.date
    }
    
    var duration: DateComponents? {
        guard let start = start, let end = end else {
            return nil
        }

        return Calendar.current.dateComponents([.hour, .minute, .second], from: start, to: end)
    }
    
    //    var measurementTypes: [MeasurementType] {
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
