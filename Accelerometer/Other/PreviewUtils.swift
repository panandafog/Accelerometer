//
//  PreviewUtils.swift
//  Accelerometer
//
//  Created by Andrey Pantyuhin on 03.10.2025.
//

import Foundation

#if DEBUG
struct PreviewUtils {
    
    // MARK: - Sample Recordings
    
    static let shortRecording = Recording(
        id: "short-sample",
        start: Date().addingTimeInterval(-30),
        end: Date(),
        entries: generateEntries(
            duration: 30,
            pointCount: 300,
            measurementTypes: [.acceleration, .userAcceleration]
        ),
        state: .completed,
        measurementTypes: [.acceleration, .userAcceleration]
    )
    
    static let mediumRecording = Recording(
        id: "medium-sample",
        start: Date().addingTimeInterval(-600), // 10 minutes
        end: Date(),
        entries: generateEntries(
            duration: 600,
            pointCount: 1200,
            measurementTypes: [.acceleration, .rotationRate, .gravity]
        ),
        state: .completed,
        measurementTypes: [.acceleration, .rotationRate, .gravity]
    )
    
    static let longRecording = Recording(
        id: "long-sample",
        start: Date().addingTimeInterval(-3600), // 1 hour
        end: Date(),
        entries: generateEntries(
            duration: 3600,
            pointCount: 3600,
            measurementTypes: [.acceleration, .rotationRate, .userAcceleration, .magneticField]
        ),
        state: .completed,
        measurementTypes: [.acceleration, .rotationRate, .userAcceleration, .magneticField]
    )
    
    static let activeRecording = Recording(
        id: "active-sample",
        start: Date().addingTimeInterval(-120), // 2 minutes ago
        end: nil,
        entries: generateEntries(
            duration: 120,
            pointCount: 240,
            measurementTypes: [.acceleration]
        ),
        state: .inProgress,
        measurementTypes: [.acceleration]
    )
    
    static let emptyRecording = Recording(
        id: "empty-sample",
        start: Date().addingTimeInterval(-60),
        end: Date(),
        entries: [],
        state: .completed,
        measurementTypes: [.acceleration]
    )
    
    // MARK: - Sample Axes
    
    static var randomTriangleAxes: TriangleAxes {
        var axes = TriangleAxes.zero
        axes.displayableAbsMax = 1.0
        axes.values = [
            .x: Axis(type_: .x, value: Double.random(in: -1.0...1.0)),
            .y: Axis(type_: .y, value: Double.random(in: -1.0...1.0)),
            .z: Axis(type_: .z, value: Double.random(in: -1.0...1.0))
        ]
        return axes
    }
    
    static func sinusoidalAxes(index: Int, amplitude: Double = 1.0) -> TriangleAxes {
        var axes = TriangleAxes.zero
        axes.displayableAbsMax = amplitude
        axes.values = [
            .x: Axis(type_: .x, value: sin(Double(index) * 0.1) * amplitude * Double.random(in: 0.8...1.0)),
            .y: Axis(type_: .y, value: cos(Double(index) * 0.15) * amplitude * Double.random(in: 0.8...1.0)),
            .z: Axis(type_: .z, value: sin(Double(index) * 0.05) * amplitude * Double.random(in: 0.6...1.0))
        ]
        return axes
    }
    
    static func magneticFieldAxes(index: Int) -> TriangleAxes {
        var axes = TriangleAxes.zero
        axes.displayableAbsMax = 100.0
        axes.values = [
            .x: Axis(type_: .x, value: sin(Double(index) * 0.02) * 50 + Double.random(in: -10...10)),
            .y: Axis(type_: .y, value: cos(Double(index) * 0.03) * 30 + Double.random(in: -5...5)),
            .z: Axis(type_: .z, value: 40 + Double.random(in: -15...15))
        ]
        return axes
    }
    
    // MARK: - Entry Generation
    
    static func generateEntries(
        duration: TimeInterval,
        pointCount: Int,
        measurementTypes: [MeasurementType]
    ) -> [Recording.Entry] {
        let startDate = Date().addingTimeInterval(-duration)
        let timeStep = duration / Double(pointCount)
        var entries: [Recording.Entry] = []
        
        for i in 0..<pointCount {
            let date = startDate.addingTimeInterval(Double(i) * timeStep)
            
            for measurementType in measurementTypes {
                let axes = generateAxes(for: measurementType, index: i)
                let entry = Recording.Entry(
                    measurementType: measurementType,
                    date: date,
                    axes: axes
                )
                entries.append(entry)
            }
        }
        
        return entries
    }
    
    private static func generateAxes(for type: MeasurementType, index: Int) -> any Axes {
        switch type {
        case .acceleration, .userAcceleration, .gravity:
            return sinusoidalAxes(index: index, amplitude: 2.0)
        case .rotationRate:
            return sinusoidalAxes(index: index, amplitude: 0.5)
        case .magneticField:
            return magneticFieldAxes(index: index)
        case .attitude:
            // Simplified attitude axes
            return sinusoidalAxes(index: index, amplitude: Double.pi)
        case .proximity:
            // Boolean proximity data
            var axes = BooleanAxes()
            axes.values = [
                .bool: Axis(
                    type_: .bool,
                    value: index % 10 < 3 // ~30% true
                )
            ]
            return axes
        }
    }
    
    // MARK: - Convenience Methods
    
    static func recordingWithType(_ type: MeasurementType, duration: TimeInterval = 300) -> Recording {
        Recording(
            id: "sample-\(type.rawValue)",
            start: Date().addingTimeInterval(-duration),
            end: Date(),
            entries: generateEntries(
                duration: duration,
                pointCount: Int(duration / 2), // 2 second intervals
                measurementTypes: [type]
            ),
            state: .completed,
            measurementTypes: [type]
        )
    }
    
    static func recordingWithMultipleTypes(
        _ types: [MeasurementType],
        duration: TimeInterval = 600
    ) -> Recording {
        Recording(
            id: "multi-sample-\(UUID().uuidString.prefix(8))",
            start: Date().addingTimeInterval(-duration),
            end: Date(),
            entries: generateEntries(
                duration: duration,
                pointCount: Int(duration),
                measurementTypes: types
            ),
            state: .completed,
            measurementTypes: Set(types)
        )
    }
    
    // MARK: - Preset Scenarios
    
    static let allSampleRecordings: [Recording] = [
        shortRecording,
        mediumRecording,
        longRecording,
        activeRecording,
        emptyRecording
    ]
    
    static let allSampleCompletedRecordings: [Recording] =
    allSampleRecordings.filter { $0.end != nil }
    
    static let magneticFieldTestRecording = recordingWithType(.magneticField, duration: 120)
    
    static let gravityTestRecording = recordingWithType(.gravity, duration: 60)
}
#endif
