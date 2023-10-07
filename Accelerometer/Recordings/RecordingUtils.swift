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
    
    static func stringsHeader(of measurementType: MeasurementType) -> [String] {
        return stringsHeader(of: measurementType.axesType.type.self)
    }
    
    static func stringsHeader<AxesType: Axes>(of axes: AxesType.Type) -> [String] {
        var outputArray: [String] = ["Datetime"]
        
        axes.axesTypes.forEach { axeType in
            outputArray.append(axeType.rawValue)
        }
        
        if let _ = axes as? (any VectorAxes) {
            outputArray.append("vector")
        }
        
        return outputArray
    }
    
    static func stringRepresentation(of axes: some Axes, defaultValue: String = "") -> [String] {
        var outputArray: [String] = []
        
        for axeType in type(of: axes).axesTypes {
            var stringRepresentation: String = defaultValue
            
            if let value = axes.values[axeType]?.value {
                stringRepresentation = String(value)
            }

            outputArray.append(stringRepresentation)
        }
        
        if let vectorAxes = axes as? (any VectorAxes) {
            outputArray.append(getVectorValue(vectorAxes))
        }
        return outputArray
    }
    
    static func parseEntryAxes(axes: some Axes) -> EntryAxesProps? {
        let displayableAbsMax = String(axes.displayableAbsMax)
        var values: [String: String] = [:]
        
        axes.values.forEach {
            values[$0.key.rawValue] = String($0.value.value)
        }
        
        if let vectorAxes = axes as? (any VectorAxes) {
            values[AxeType.vector.rawValue] = getVectorValue(vectorAxes)
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
                  let vectorString = axesStrings[.vector],
                  let vector = TriangleAxes.ValueType(vectorString)
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
                vector: .init(type_: .vector, value: vector)
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
        }
    }
    
    private static func getVectorValue<VectorAxesType: VectorAxes>(_ axes: VectorAxesType) -> String {
        String(axes.vector.value)
    }
}
