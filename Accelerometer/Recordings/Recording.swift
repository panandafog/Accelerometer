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
        
        var csvStrings = filteredEntries
            .map({ $0.csvString })
        csvStrings.insert(Entry.firstCsvString, at: 0)
        
        return TextFile(initialText: csvStrings.joined(separator: "\n"))
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
        let value: TriangleAxes?
        
        static var firstCsvString: String = {
            // FIXME: any axes support
            [
                "Datetime",
                "x",
                "y",
                "z",
                "sum"
            ].joined(separator: ",")
        }()
        
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
            guard let axes = value else {
                return dateString
            }
            
            type(of: axes).axesTypes.forEach { axeType in
                outputArray.append(String(axes.axes[axeType]!.value))
            }
            
            return outputArray.joined(separator: ",")
        }
        
        init(id: String = UUID().uuidString, measurementType: MeasurementType, date: Date, value: TriangleAxes?) {
            self.id = id
            self.measurementType = measurementType
            self.date = date
            self.value = value
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
