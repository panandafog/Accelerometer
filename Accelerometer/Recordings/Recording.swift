//
//  Recording.swift
//  Accelerometer
//
//  Created by Andrey on 29.07.2022.
//

import Foundation

struct Recording: Identifiable {
    
    let id: String
    let start: Date
    var end: Date?
    
    var entries: [Entry]?
    var state: State
    var source: Source
    
    let measurementTypes: Set<MeasurementType>
    
    var duration: DateComponents? {
        guard let end = (state == .inProgress) ? Date.now : end else {
            return nil
        }

        return Calendar.current.dateComponents([.hour, .minute, .second], from: start, to: end)
    }
    
    var sortedMeasurementTypes: [MeasurementType] {
        Array(measurementTypes)
            .sorted { lhs, rhs in
                lhs.name < rhs.name
            }
    }
    
    init(
        id: String = UUID().uuidString,
        start: Date = Date(),
        end: Date? = nil,
        entries: [Entry]? = nil,
        state: State,
        source: Source = .iPhone,
        measurementTypes: Set<MeasurementType>
    ) {
        self.id = id
        self.start = start
        self.end = end
        self.entries = entries
        self.state = state
        self.source = source
        self.measurementTypes = measurementTypes
    }
}

extension Recording {
    
    enum State: String {
        case inProgress
        case completed
    }

    enum Source {
        case iPhone
        case appleWatch
    }
    
    struct Entry: Identifiable {
        
        let id: String
        
        let measurementType: MeasurementType
        let date: Date
        let axes: any Axes
        
        func getCsvString(dateFormat: Settings.ExportDateFormat) -> String {
            let dateString: String
            switch dateFormat {
            case .dateFormat:
                dateString = DateFormatter.Recordings.csvString(from: date)
            case .unix:
                dateString = String(date.timeIntervalSince1970)
            case .excel:
                dateString = String(Double(date.timeIntervalSince1970) / 86400.0 + 25569.0)
            }
            
            var outputArray = [dateString]
            outputArray.append(contentsOf: RecordingUtils.stringRepresentation(of: axes))
            
            return outputArray.joined(separator: RecordingUtils.columnSeparator)
        }
        
        init(id: String = UUID().uuidString, measurementType: MeasurementType, date: Date, axes: any Axes) {
            self.id = id
            self.measurementType = measurementType
            self.date = date
            self.axes = axes
        }
    }
}
