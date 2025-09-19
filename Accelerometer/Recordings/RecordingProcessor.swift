//
//  RecordingProcessor.swift
//  Accelerometer
//
//  Created by Andrey Pantyuhin on 19.09.2025.
//

import Foundation

actor RecordingProcessor {
    
    func generateCSV(
        from recording: Recording,
        for type: MeasurementType,
        dateFormat: Settings.ExportDateFormat
    ) async throws -> URL {
        guard recording.measurementTypes.contains(type) else {
            throw ProcessingError.invalidType
        }
        
        let header = RecordingUtils.stringsHeader(of: type)
        let rows = recording.entries
            .filter { $0.measurementType == type }
            .map { $0.getCsvString(dateFormat: dateFormat) }
        let csvText = ([header] + rows).joined(separator: RecordingUtils.rowSeparator)
        
        let tmpURL = FileManager.default
            .temporaryDirectory
            .appendingPathComponent("\(type.rawValue).csv")
        
        try csvText.write(to: tmpURL, atomically: true, encoding: .utf8)
        return tmpURL
    }
    
    func sampledEntries(
        from recording: Recording,
        for type: MeasurementType,
        maxCount: Int = 50
    ) async -> [Recording.Entry] {
        let filtered = recording.entries
            .filter { $0.measurementType == type }
    
        guard filtered.count > maxCount else { return filtered }
        
        let stride = filtered.count / maxCount
        return filtered.enumerated().compactMap { idx, entry in
            idx % stride == 0 ? entry : nil
        }
    }
    
    enum ProcessingError: Error {
        case invalidType
    }
}
