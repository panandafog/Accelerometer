//
//  RecordingRealm.swift
//  Accelerometer
//
//  Created by Andrey on 04.08.2022.
//

import Foundation
import RealmSwift

class RecordingRealm: Object {
    
    @objc dynamic var id: String = .init()
    @objc dynamic var start: NSDate = .init()
    @objc dynamic var end: NSDate? = nil
    @objc dynamic var state: String = .init()
    
    let measurementTypes = List<String>()
    let entries = List<RecordingEntryRealm>()
    
    convenience init(
        id: String,
        start: NSDate,
        end: NSDate?,
        state: String,
        measurementTypes: [String],
        entries: [RecordingEntryRealm]
    ) {
        self.init()
        self.id = id
        self.start = start
        self.end = end
        self.state = state
        self.measurementTypes.append(objectsIn: measurementTypes)
        self.entries.append(objectsIn: entries)
    }
    
    override class func primaryKey() -> String? {
        "id"
    }
}

extension RecordingRealm {
    
    var recording: Recording {
        Recording(
            id: id,
            start: start as Date,
            end: end as Date?,
            entries: Array(entries)
                .compactMap { $0.entry },
            state: .init(rawValue: state)!,
            measurementTypes: Set(Array(measurementTypes)
                .compactMap { MeasurementType(rawValue: $0) })
        )
    }
    
    var recordingMetadata: Recording {
        return Recording(
            id: id,
            start: start as Date,
            end: end as Date?,
            entries: nil,
            state: .init(rawValue: state)!,
            measurementTypes: Set(Array(measurementTypes)
                .compactMap { MeasurementType(rawValue: $0) })
        )
    }
    
    convenience init(recording: Recording) {
        self.init(
            id: recording.id,
            start: recording.start as NSDate,
            end: recording.end as NSDate?,
            state: recording.state.rawValue,
            measurementTypes: Array(recording.measurementTypes).map { $0.rawValue },
            entries: recording.entries?.compactMap { RecordingEntryRealm(entry: $0) } ?? []
        )
    }
}
