//
//  WatchRecordingWidgetState.swift
//  Accelerometer Watch Watch App
//

import Foundation

struct WatchRecordingWidgetState: Sendable {
    enum Status: String, Sendable {
        case recording
        case interrupted
    }

    static let appGroupID = "group.com.panandafog.Accelerometer.watch"
    static let widgetKind = "WatchRecordingStatusWidget"

    let status: Status
    let start: Date
    let end: Date?
    let measurementCount: Int
    let message: String?

    static func load() -> WatchRecordingWidgetState? {
        guard let defaults = UserDefaults(suiteName: appGroupID),
              let start = defaults.object(forKey: StorageKey.start) as? Date else {
            return nil
        }

        return WatchRecordingWidgetState(
            status: defaults.string(forKey: StorageKey.status)
                .flatMap(Status.init(rawValue:)) ?? .recording,
            start: start,
            end: defaults.object(forKey: StorageKey.end) as? Date,
            measurementCount: defaults.integer(forKey: StorageKey.measurementCount),
            message: defaults.string(forKey: StorageKey.message)
        )
    }

    static func save(start: Date, measurementCount: Int) {
        guard let defaults = UserDefaults(suiteName: appGroupID) else {
            return
        }

        defaults.set(Status.recording.rawValue, forKey: StorageKey.status)
        defaults.set(start, forKey: StorageKey.start)
        defaults.set(measurementCount, forKey: StorageKey.measurementCount)
        defaults.removeObject(forKey: StorageKey.end)
        defaults.removeObject(forKey: StorageKey.message)
    }

    static func saveInterrupted(
        start: Date,
        end: Date,
        measurementCount: Int,
        message: String
    ) {
        guard let defaults = UserDefaults(suiteName: appGroupID) else {
            return
        }

        defaults.set(Status.interrupted.rawValue, forKey: StorageKey.status)
        defaults.set(start, forKey: StorageKey.start)
        defaults.set(end, forKey: StorageKey.end)
        defaults.set(measurementCount, forKey: StorageKey.measurementCount)
        defaults.set(message, forKey: StorageKey.message)
    }

    static func clear() {
        guard let defaults = UserDefaults(suiteName: appGroupID) else {
            return
        }

        defaults.removeObject(forKey: StorageKey.status)
        defaults.removeObject(forKey: StorageKey.start)
        defaults.removeObject(forKey: StorageKey.end)
        defaults.removeObject(forKey: StorageKey.measurementCount)
        defaults.removeObject(forKey: StorageKey.message)
    }

    private enum StorageKey {
        static let status = "watchRecordingWidgetStatus"
        static let start = "watchRecordingWidgetStart"
        static let end = "watchRecordingWidgetEnd"
        static let measurementCount = "watchRecordingWidgetMeasurementCount"
        static let message = "watchRecordingWidgetMessage"
    }
}

struct WatchMeasurementWidgetState: Codable, Sendable {
    static let widgetKind = "WatchMeasurementWidget"

    let measurementType: String
    let name: String
    let iconName: String
    let unit: String
    let maximumLabel: String?
    let maximumValue: String
    let axisMaximumValues: [String]
    let intensity: Double
    let updatedAt: Date

    static func load(measurementType: String) -> WatchMeasurementWidgetState? {
        loadAll()[measurementType]
    }

    static func save(_ states: [WatchMeasurementWidgetState]) {
        guard let defaults = UserDefaults(suiteName: WatchRecordingWidgetState.appGroupID),
              let data = try? JSONEncoder().encode(
                Dictionary(uniqueKeysWithValues: states.map { ($0.measurementType, $0) })
              ) else {
            return
        }

        defaults.set(data, forKey: StorageKey.states)
    }

    private static func loadAll() -> [String: WatchMeasurementWidgetState] {
        guard let defaults = UserDefaults(suiteName: WatchRecordingWidgetState.appGroupID),
              let data = defaults.data(forKey: StorageKey.states),
              let states = try? JSONDecoder().decode(
                [String: WatchMeasurementWidgetState].self,
                from: data
              ) else {
            return [:]
        }

        return states
    }

    private enum StorageKey {
        static let states = "watchMeasurementWidgetStates"
    }
}

enum WatchWidgetDeepLink {
    static let scheme = "accelerometer-watch"

    static func measurementURL(measurementType: String) -> URL? {
        URL(string: "\(scheme)://measurement/\(measurementType)")
    }

    static func measurementType(from url: URL) -> String? {
        guard url.scheme == scheme, url.host == "measurement" else {
            return nil
        }

        let measurementType = url.pathComponents
            .filter { $0 != "/" }
            .first

        return measurementType?.removingPercentEncoding
    }
}

struct WatchWidgetActionRequest: Codable, Sendable {
    enum Route: String, Codable, Sendable {
        case measurement
        case recordings
    }

    let route: Route
    let measurementType: String?
    let shouldStartRecording: Bool

    static func request(
        route: Route,
        measurementType: String? = nil,
        shouldStartRecording: Bool = false
    ) {
        guard let defaults = UserDefaults(suiteName: WatchRecordingWidgetState.appGroupID),
              let data = try? JSONEncoder().encode(
                WatchWidgetActionRequest(
                    route: route,
                    measurementType: measurementType,
                    shouldStartRecording: shouldStartRecording
                )
              ) else {
            return
        }

        defaults.set(data, forKey: StorageKey.request)
    }

    static func consume() -> WatchWidgetActionRequest? {
        guard let defaults = UserDefaults(suiteName: WatchRecordingWidgetState.appGroupID),
              let data = defaults.data(forKey: StorageKey.request),
              let request = try? JSONDecoder().decode(WatchWidgetActionRequest.self, from: data) else {
            return nil
        }

        defaults.removeObject(forKey: StorageKey.request)
        return request
    }

    private enum StorageKey {
        static let request = "watchWidgetActionRequest"
    }
}
