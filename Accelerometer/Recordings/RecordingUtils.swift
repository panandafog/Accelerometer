//
//  RecordingUtils.swift
//  Accelerometer
//
//  Created by Andrey on 01.10.2023.
//

import Foundation

enum RecordingUtils {
    
    typealias EntryAxesProps = (
        displayableAbsMax: String,
        axesKeys: [String],
        axesValues: [String]
    )
    
    static let columnSeparator = ","
    static let rowSeparator = "\n"
    
    static func stringsHeader(of measurementType: MeasurementType) -> String {
        return stringsHeader(of: measurementType.axesType.type.self)
    }
    
    static func stringsHeader<AxesType: Axes>(of axes: AxesType.Type) -> String {
        var titles: [String] = ["datetime"]
        
        axes.sortedAxesTypes.forEach { axeType in
            titles.append(axeType.rawValue)
        }
        
        if let _ = axes as? (any MagnitudeAxes.Type) {
            titles.append("magnitude")
        }
        
        return titles.joined(separator: RecordingUtils.columnSeparator)
    }
    
    static func stringRepresentation(of axes: some Axes, defaultValue: String = "") -> [String] {
        var outputArray: [String] = []
        
        for axeType in type(of: axes).sortedAxesTypes {
            var stringRepresentation: String = defaultValue
            
            if let value = axes.values[axeType]?.value {
                stringRepresentation = String(value)
            }

            outputArray.append(stringRepresentation)
        }
        
        if let magnitudeAxes = axes as? (any MagnitudeAxes) {
            outputArray.append(getMagnitudeValue(magnitudeAxes))
        }
        return outputArray
    }
    
    static func parseEntryAxes(axes: some Axes) -> EntryAxesProps? {
        let displayableAbsMax = String(axes.displayableAbsMax)
        var values: [String: String] = [:]
        
        axes.values.forEach {
            values[$0.key.rawValue] = String($0.value.value)
        }
        
        if let magnitudeAxes = axes as? (any MagnitudeAxes) {
            values[AxeType.magnitude.rawValue] = getMagnitudeValue(magnitudeAxes)
        }
        
        return (
            displayableAbsMax: displayableAbsMax,
            axesKeys: Array(values.keys),
            axesValues: Array(values.values)
        )
    }
    
    static func getEntryAxesFrom(realm: RecordingEntryRealm) -> (any Axes)? {
        guard let measurementType = MeasurementType(rawValue: realm.measurementType),
              realm.axesKeys.count <= realm.axesValues.count else {
            return nil
        }
        
        var axesStrings: [AxeType: String] = [:]
        
        for index in 0 ..< realm.axesKeys.count {
            if let axeType = AxeType(rawValue: realm.axesKeys[index]) {
                axesStrings[axeType] = realm.axesValues[index]
            }
        }
        
        switch measurementType.axesType {
        case .triangle:
            guard let displayableAbsMax = TriangleAxes.ValueType(realm.displayableAbsMax),
                  let magnitudeString = axesStrings[.magnitude],
                  let magnitude = TriangleAxes.ValueType(magnitudeString)
            else {
                return nil
            }
            
            var axes: [AxeType: Axis<TriangleAxes.ValueType>] = [:]
            for key in axesStrings.keys {
                if let stringKey = axesStrings[key],
                   let valueTypeKey = TriangleAxes.ValueType(stringKey)
                {
                    axes[key] = Axis<TriangleAxes.ValueType>.init(
                        type_: key,
                        value: valueTypeKey
                    )
                }
            }
            
            return TriangleAxes(
                axes: axes,
                measurementType: measurementType,
                displayableAbsMax: displayableAbsMax,
                magnitude: .init(type_: .magnitude, value: magnitude)
            )
        case .attitude:
            guard let displayableAbsMax = AttitudeAxes.ValueType(realm.displayableAbsMax) else {
                return nil
            }
            
            var axes: [AxeType: Axis<AttitudeAxes.ValueType>] = [:]
            for key in axesStrings.keys {
                if let stringKey = axesStrings[key],
                   let valueTypeKey = TriangleAxes.ValueType(stringKey)
                {
                    axes[key] = Axis<AttitudeAxes.ValueType>.init(
                        type_: key,
                        value: valueTypeKey
                    )
                }
            }
            
            return AttitudeAxes(
                axes: axes,
                measurementType: measurementType,
                displayableAbsMax: displayableAbsMax
            )
        case .bool:
            // TODO
            return nil
        }
    }
    
    private static func getMagnitudeValue<MagnitudeAxesType: MagnitudeAxes>(_ axes: MagnitudeAxesType) -> String {
        String(axes.magnitude.value)
    }
}
