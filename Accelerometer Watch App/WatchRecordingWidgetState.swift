//
//  WatchRecordingWidgetState.swift
//  Accelerometer Watch Watch App
//

import Foundation

struct WatchRecordingWidgetState: Sendable {
    static let appGroupID = "group.com.panandafog.Accelerometer.watch"
    static let widgetKind = "WatchRecordingStatusWidget"

    let start: Date
    let measurementCount: Int

    static func load() -> WatchRecordingWidgetState? {
        guard let defaults = UserDefaults(suiteName: appGroupID),
              let start = defaults.object(forKey: StorageKey.start) as? Date else {
            return nil
        }

        return WatchRecordingWidgetState(
            start: start,
            measurementCount: defaults.integer(forKey: StorageKey.measurementCount)
        )
    }

    static func save(start: Date, measurementCount: Int) {
        guard let defaults = UserDefaults(suiteName: appGroupID) else {
            return
        }

        defaults.set(start, forKey: StorageKey.start)
        defaults.set(measurementCount, forKey: StorageKey.measurementCount)
    }

    static func clear() {
        guard let defaults = UserDefaults(suiteName: appGroupID) else {
            return
        }

        defaults.removeObject(forKey: StorageKey.start)
        defaults.removeObject(forKey: StorageKey.measurementCount)
    }

    private enum StorageKey {
        static let start = "watchRecordingWidgetStart"
        static let measurementCount = "watchRecordingWidgetMeasurementCount"
    }
}

struct WatchMeasurementWidgetState: Codable, Sendable {
    static let widgetKind = "WatchMeasurementWidget"

    let measurementType: String
    let name: String
    let iconName: String
    let unit: String
    let primaryLabel: String?
    let primaryValue: String
    let axisValues: [String]
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
