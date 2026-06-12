//
//  RecordingTransferPayload.swift
//  Accelerometer
//
//  Created by OpenAI on 07.06.2026.
//

import Foundation

enum TransferKey {
    static let recordingID = "recordingID"
    static let importedRecordingID = "importedRecordingID"
    static let importedTransferID = "importedTransferID"
    static let importedTransfers = "importedTransfers"
    static let transferStatusRequests = "transferStatusRequests"
    static let failedRecordingID = "failedRecordingID"
    static let failedTransferID = "failedTransferID"
    static let transferFailureReason = "transferFailureReason"
    static let chunkProtocolVersion = "chunkProtocolVersion"
    static let transferID = "transferID"
    static let chunkIndex = "chunkIndex"
    static let chunkCount = "chunkCount"
    static let chunkByteCount = "chunkByteCount"
    static let totalByteCount = "totalByteCount"
    static let chunkHash = "chunkHash"
    static let fileHash = "fileHash"
}

struct RecordingChunkMetadata: Sendable {
    static let currentProtocolVersion = 1

    let transferID: String
    let recordingID: String
    let chunkIndex: Int
    let chunkCount: Int
    let chunkByteCount: Int
    let totalByteCount: Int
    let chunkHash: String
    let fileHash: String

    init(
        transferID: String,
        recordingID: String,
        chunkIndex: Int,
        chunkCount: Int,
        chunkByteCount: Int,
        totalByteCount: Int,
        chunkHash: String,
        fileHash: String
    ) {
        self.transferID = transferID
        self.recordingID = recordingID
        self.chunkIndex = chunkIndex
        self.chunkCount = chunkCount
        self.chunkByteCount = chunkByteCount
        self.totalByteCount = totalByteCount
        self.chunkHash = chunkHash
        self.fileHash = fileHash
    }

    init?(dictionary: [String: Any]?) {
        guard let dictionary,
              Self.intValue(dictionary[TransferKey.chunkProtocolVersion])
                == Self.currentProtocolVersion,
              let transferID = dictionary[TransferKey.transferID] as? String,
              UUID(uuidString: transferID) != nil,
              let recordingID = dictionary[TransferKey.recordingID] as? String,
              !recordingID.isEmpty,
              let chunkIndex = Self.intValue(dictionary[TransferKey.chunkIndex]),
              let chunkCount = Self.intValue(dictionary[TransferKey.chunkCount]),
              let chunkByteCount = Self.intValue(dictionary[TransferKey.chunkByteCount]),
              let totalByteCount = Self.intValue(dictionary[TransferKey.totalByteCount]),
              let chunkHash = dictionary[TransferKey.chunkHash] as? String,
              let fileHash = dictionary[TransferKey.fileHash] as? String,
              chunkIndex >= 0,
              chunkIndex < chunkCount,
              chunkCount > 0,
              chunkByteCount >= 0,
              totalByteCount >= chunkByteCount,
              !chunkHash.isEmpty,
              !fileHash.isEmpty else {
            return nil
        }

        self.init(
            transferID: transferID,
            recordingID: recordingID,
            chunkIndex: chunkIndex,
            chunkCount: chunkCount,
            chunkByteCount: chunkByteCount,
            totalByteCount: totalByteCount,
            chunkHash: chunkHash,
            fileHash: fileHash
        )
    }

    var dictionary: [String: Any] {
        [
            TransferKey.chunkProtocolVersion: Self.currentProtocolVersion,
            TransferKey.transferID: transferID,
            TransferKey.recordingID: recordingID,
            TransferKey.chunkIndex: chunkIndex,
            TransferKey.chunkCount: chunkCount,
            TransferKey.chunkByteCount: chunkByteCount,
            TransferKey.totalByteCount: totalByteCount,
            TransferKey.chunkHash: chunkHash,
            TransferKey.fileHash: fileHash
        ]
    }

    private static func intValue(_ value: Any?) -> Int? {
        if let value = value as? Int {
            return value
        }
        return (value as? NSNumber)?.intValue
    }
}

struct RecordingTransferPayload: Codable, Identifiable, Sendable {
    static let currentVersion = 1

    let version: Int
    let id: String
    let start: Date
    let end: Date
    let measurementTypes: [String]
    let entries: [Entry]

    init(
        version: Int = Self.currentVersion,
        id: String = UUID().uuidString,
        start: Date,
        end: Date,
        measurementTypes: [String],
        entries: [Entry]
    ) {
        self.version = version
        self.id = id
        self.start = start
        self.end = end
        self.measurementTypes = measurementTypes
        self.entries = entries
    }

    struct Entry: Codable, Identifiable, Sendable {
        let id: String
        let measurementType: String
        let date: Date
        let displayableAbsMax: String
        let values: [String: String]

        init(
            id: String = UUID().uuidString,
            measurementType: String,
            date: Date,
            displayableAbsMax: String,
            values: [String: String]
        ) {
            self.id = id
            self.measurementType = measurementType
            self.date = date
            self.displayableAbsMax = displayableAbsMax
            self.values = values
        }

        init<AxesType: Axes>(
            measurementType: MeasurementType,
            date: Date = Date(),
            axes: AxesType
        ) {
            self.id = UUID().uuidString
            self.measurementType = measurementType.rawValue
            self.date = date
            self.displayableAbsMax = String(describing: axes.displayableAbsMax)
            self.values = axes.values.reduce(into: [:]) { result, element in
                result[element.key.rawValue] = String(describing: element.value.value)
            }
        }
    }
}

#if os(iOS)
extension RecordingTransferPayload {
    func recording() throws -> Recording {
        guard version == Self.currentVersion else {
            throw DecodingError.unsupportedVersion
        }

        let types = Set(measurementTypes.compactMap(MeasurementType.init(rawValue:)))
        let decodedEntries = try entries.map { try $0.recordingEntry() }

        return Recording(
            id: id,
            start: start,
            end: end,
            entries: decodedEntries,
            state: .completed,
            source: .appleWatch,
            measurementTypes: types
        )
    }

    enum DecodingError: Error {
        case unsupportedVersion
        case invalidEntry
    }
}

private extension RecordingTransferPayload.Entry {
    func recordingEntry() throws -> Recording.Entry {
        guard let type = MeasurementType(rawValue: measurementType) else {
            throw RecordingTransferPayload.DecodingError.invalidEntry
        }

        let axes: any Axes = switch type.axesType {
        case .triangle:
            try triangleAxes(measurementType: type)
        case .attitude:
            try attitudeAxes(measurementType: type)
        case .bool:
            try booleanAxes(measurementType: type)
        }

        return Recording.Entry(
            id: id,
            measurementType: type,
            date: date,
            axes: axes
        )
    }

    func triangleAxes(measurementType: MeasurementType) throws -> TriangleAxes {
        guard let maximum = Double(displayableAbsMax) else {
            throw RecordingTransferPayload.DecodingError.invalidEntry
        }

        var axes = TriangleAxes.zero
        axes.measurementType = measurementType
        axes.displayableAbsMax = maximum
        axes.set(values: doubleValues())
        return axes
    }

    func attitudeAxes(measurementType: MeasurementType) throws -> AttitudeAxes {
        guard let maximum = Double(displayableAbsMax) else {
            throw RecordingTransferPayload.DecodingError.invalidEntry
        }

        var axes = AttitudeAxes.zero
        axes.measurementType = measurementType
        axes.displayableAbsMax = maximum
        axes.set(values: doubleValues())
        return axes
    }

    func booleanAxes(measurementType: MeasurementType) throws -> BooleanAxes {
        var axes = BooleanAxes.zero
        axes.measurementType = measurementType
        axes.set(values: values.reduce(into: [:]) { result, element in
            guard let type = AxeType(rawValue: element.key),
                  let value = Bool(element.value) else {
                return
            }
            result[type] = value
        })
        return axes
    }

    func doubleValues() -> [AxeType: Double] {
        values.reduce(into: [:]) { result, element in
            guard let type = AxeType(rawValue: element.key),
                  let value = Double(element.value) else {
                return
            }
            result[type] = value
        }
    }
}
#endif
