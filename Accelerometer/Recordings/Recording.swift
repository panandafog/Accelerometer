//
//  Recording.swift
//  Accelerometer
//
//  Created by Andrey on 29.07.2022.
//

import Foundation
import CoreData

struct Recording: Identifiable {
    
    let id: String
    let created: Date
    
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
    
    var sortedMeasurementTypes: [MeasurementType] {
        Array(measurementTypes)
            .sorted { lhs, rhs in
                lhs.name < rhs.name
            }
    }
    
    init(id: String = UUID().uuidString, created: Date = Date(), entries: [Entry], state: State, measurementTypes: Set<MeasurementType>) {
        self.id = id
        self.created = created
        self.entries = entries
        self.state = state
        self.measurementTypes = measurementTypes
    }
    
    func csv(of type: MeasurementType) -> TextFile? {
        guard measurementTypes.contains(type) else {
            return nil
        }
        let filteredEntries = entries
            .filter({ $0.measurementType == type })
        
        var csvStrings = RecordingUtils.stringsHeader(of: type)
        csvStrings.append(contentsOf: filteredEntries.map({ $0.csvString }))
        
        return TextFile(initialText: csvStrings.joined(separator: "\n"))
    }
    
    func chartValues(of measurementType: MeasurementType) -> [[Double]] {
        var chartEntries: [any ChartEntry] = []
        
        for entry in entries where entry.measurementType == measurementType {
            if let axes = entry.axes as? (any ChartEntry) {
                chartEntries.append(axes)
            }
        }
        
        return chartEntries
            .map({ $0.chartValues })
            .transposed()
    }
}

extension Recording {
    
    enum State: String {
        case inProgress
        case completed
    }
    
    struct Entry: Identifiable {
        
        let id: String
        
        let measurementType: MeasurementType
        let date: Date
        let axes: any Axes
        
        var csvString: String {
            let dateString: String
            switch Settings.shared.exportDateFormat {
            case .dateFormat:
                dateString = DateFormatter.Recordings.csvString(from: date)
            case .unix:
                dateString = String(date.timeIntervalSince1970)
            case .excel:
                dateString = String(Double(date.timeIntervalSince1970) / 86400.0 + 25569.0)
            }
            
            var outputArray = [dateString]
            outputArray.append(contentsOf: RecordingUtils.stringRepresentation(of: axes))
            
            return outputArray.joined(separator: ",")
        }
        
        init(id: String = UUID().uuidString, measurementType: MeasurementType, date: Date, axes: any Axes) {
            self.id = id
            self.measurementType = measurementType
            self.date = date
            self.axes = axes
        }
    }
}

//extension Recording {
//
//    var entity: RecordingEntity {
////        let newEntity = RecordingEntity()
//        let newEntity = NSEntityDescription.insertNewObjectForEntityForName("RecordingEntity", inManagedObjectContext: self.managedObjectContext) as! RecordingEntity
//        newEntity.id = id
//        newEntity.created = created
//        newEntity.state = state.rawValue
//        return newEntity
//    }
//
//    init(from entity: RecordingEntity) {
//        self.init(id: entity.id!, created: entity.created!, entries: [], state: .init(rawValue: entity.state!)!, measurementTypes: [])
//    }
//}
