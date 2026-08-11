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
        case interrupted
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

struct RecordingGap: Identifiable, Hashable {
    let measurementType: MeasurementType
    let start: Date
    let end: Date
    let expectedInterval: TimeInterval

    var id: String {
        [
            measurementType.rawValue,
            String(start.timeIntervalSinceReferenceDate),
            String(end.timeIntervalSinceReferenceDate)
        ].joined(separator: "-")
    }

    var duration: TimeInterval {
        max(0, end.timeIntervalSince(start))
    }

    var missingDuration: TimeInterval {
        max(0, duration - expectedInterval)
    }
}

extension Recording {

    var detectedGaps: [RecordingGap] {
        sortedMeasurementTypes
            .flatMap { detectedGaps(for: $0) }
            .sorted { lhs, rhs in
                if lhs.start == rhs.start {
                    return lhs.measurementType.name < rhs.measurementType.name
                }
                return lhs.start < rhs.start
            }
    }

    func detectedGaps(for measurementType: MeasurementType) -> [RecordingGap] {
        RecordingGapDetector.detect(in: entries ?? [], measurementType: measurementType)
    }
}

private enum RecordingGapDetector {
    private static let minimumIntervalCount = 3
    private static let minimumMissingDuration: TimeInterval = 2
    private static let gapMultiplier: TimeInterval = 4

    static func detect(
        in entries: [Recording.Entry],
        measurementType: MeasurementType
    ) -> [RecordingGap] {
        let dates = entries
            .filter { $0.measurementType == measurementType }
            .map(\.date)
            .sorted()

        guard dates.count > minimumIntervalCount else { return [] }

        let intervals = zip(dates.dropFirst(), dates)
            .map { later, earlier in later.timeIntervalSince(earlier) }
            .filter { $0 > 0 }

        guard
            intervals.count >= minimumIntervalCount,
            let expectedInterval = median(intervals)
        else {
            return []
        }

        let threshold = max(
            expectedInterval * gapMultiplier,
            expectedInterval + minimumMissingDuration
        )

        return zip(dates.dropFirst(), dates)
            .compactMap { later, earlier in
                let interval = later.timeIntervalSince(earlier)
                guard interval >= threshold else { return nil }
                return RecordingGap(
                    measurementType: measurementType,
                    start: earlier,
                    end: later,
                    expectedInterval: expectedInterval
                )
            }
    }

    private static func median(_ intervals: [TimeInterval]) -> TimeInterval? {
        guard !intervals.isEmpty else { return nil }

        let sortedIntervals = intervals.sorted()
        let middleIndex = sortedIntervals.count / 2

        if sortedIntervals.count.isMultiple(of: 2) {
            return (
                sortedIntervals[middleIndex - 1] +
                sortedIntervals[middleIndex]
            ) / 2
        }

        return sortedIntervals[middleIndex]
    }
}
