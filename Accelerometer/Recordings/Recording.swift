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
    
    func csv(of type: MeasurementType) -> TextFile? {
        guard measurementTypes.contains(type) else {
            return nil
        }
        let filteredEntries = entries
            .filter({ $0.measurementType == type })
        
        var csvStrings = filteredEntries
            .map({ $0.csvString })
        csvStrings.insert(Entry.firstCsvString, at: 0)
        
        return TextFile(initialText: csvStrings.joined(separator: "\n"))
    }
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
        
        static var firstCsvString: String = {
            [
                "Datetime",
                "x",
                "y",
                "z",
                "sum"
            ].joined(separator: ",")
        }()
        
        var csvString: String {
            let dateString = DateFormatter.Recordings.csvString(from: date)
            guard let axes = value else {
                return dateString
            }
            return [
                dateString,
                String(axes.x),
                String(axes.y),
                String(axes.z),
                String(axes.vector)
            ].joined(separator: ",")
        }
    }
}
