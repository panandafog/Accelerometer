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
    @objc dynamic var displayableAbsMax: String = .init()
    
    let axesKeys = List<String>()
    let axesValues = List<String>()
    
    convenience init(
        id: String,
        date: NSDate,
        measurementType: String,
        displayableAbsMax: String,
        axesKeys: [String],
        axesValues: [String]
    ) {
        self.init()
        self.id = id
        self.date = date
        self.measurementType = measurementType
        self.displayableAbsMax = displayableAbsMax
        self.axesKeys.append(objectsIn: axesKeys)
        self.axesValues.append(objectsIn: axesValues)
    }
    
    override class func primaryKey() -> String? {
        "id"
    }
}

extension RecordingEntryRealm {
    
    var entry: Recording.Entry? {
        guard let measurementType = MeasurementType(rawValue: measurementType),
              let axes = RecordingUtils.getEntryAxesFrom(realm: self) else {
            return nil
        }
        
        return Recording.Entry(
            id: id,
            measurementType: measurementType,
            date: date as Date,
            axes: axes
        )
    }
    
    convenience init?(entry: Recording.Entry) {
        guard let axesProps = RecordingUtils.parseEntryAxes(axes: entry.axes) else {
            return nil
        }
        
        self.init(
            id: entry.id,
            date: entry.date as NSDate,
            measurementType: entry.measurementType.rawValue,
            displayableAbsMax: axesProps.displayableAbsMax,
            axesKeys: axesProps.axesKeys,
            axesValues: axesProps.axesValues
        )
    }
}
