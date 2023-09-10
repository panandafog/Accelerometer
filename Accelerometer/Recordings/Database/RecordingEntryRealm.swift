//
//  RecordingEntryRealm.swift
//  Accelerometer
//
//  Created by Andrey on 05.08.2022.
//

import Foundation
import RealmSwift

class RecordingEntryRealm: Object {
    
    @objc dynamic var id: String = .init()
    @objc dynamic var date: NSDate = .init()
    @objc dynamic var measurementType: String = .init()
    
    @objc dynamic var value: TriangleAxesRealm?
    
    convenience init(id: String, date: NSDate, measurementType: String, value: TriangleAxesRealm?) {
        self.init()
        self.id = id
        self.date = date
        self.measurementType = measurementType
        self.value = value
    }
    
    override class func primaryKey() -> String? {
        "id"
    }
}

extension RecordingEntryRealm {
    
    var entry: Recording.Entry {
        Recording.Entry(
            id: id,
            measurementType: MeasurementType(rawValue: measurementType)!,
            date: date as Date,
            value: value?.axes
        )
    }
    
    convenience init(entry: Recording.Entry) {
        var axesRealm: TriangleAxesRealm?
        if let value = entry.value {
            axesRealm = TriangleAxesRealm(axes: value)
        }
        
        self.init(
            id: entry.id,
            date: entry.date as NSDate,
            measurementType: entry.measurementType.rawValue,
            value: axesRealm
        )
    }
}
