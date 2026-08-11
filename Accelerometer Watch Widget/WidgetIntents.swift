//
//  WidgetIntents.swift
//  Accelerometer Watch Widget
//

import AppIntents

enum WidgetMeasurement: String, AppEnum, CaseIterable {
    case acceleration
    case rotationRate = "rotation"
    case userAcceleration = "deviceMotion"
    case magneticField
    case attitude
    case gravity

    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Sensor"
    static let caseDisplayRepresentations: [WidgetMeasurement: DisplayRepresentation] = [
        .acceleration: DisplayRepresentation(
            title: "Acceleration",
            image: .init(systemName: "speedometer")
        ),
        .rotationRate: DisplayRepresentation(
            title: "Rotation rate",
            image: .init(systemName: "gyroscope")
        ),
        .userAcceleration: DisplayRepresentation(
            title: "User acceleration",
            image: .init(systemName: "figure.walk.motion")
        ),
        .magneticField: DisplayRepresentation(
            title: "Magnetic field",
            image: .init(systemName: "wave.3.left")
        ),
        .attitude: DisplayRepresentation(
            title: "Attitude",
            image: .init(systemName: "perspective")
        ),
        .gravity: DisplayRepresentation(
            title: "Gravity",
            image: .init(systemName: "globe")
        )
    ]

    var name: String {
        switch self {
        case .acceleration:
            "Acceleration"
        case .rotationRate:
            "Rotation rate"
        case .userAcceleration:
            "User acceleration"
        case .magneticField:
            "Magnetic field"
        case .attitude:
            "Attitude"
        case .gravity:
            "Gravity"
        }
    }

    var shortName: String {
        switch self {
        case .acceleration:
            "Accel"
        case .rotationRate:
            "Rotation"
        case .userAcceleration:
            "User accel"
        case .magneticField:
            "Magnetic"
        case .attitude:
            "Attitude"
        case .gravity:
            "Gravity"
        }
    }

    var iconName: String {
        switch self {
        case .acceleration:
            "speedometer"
        case .rotationRate:
            "gyroscope"
        case .userAcceleration:
            "figure.walk.motion"
        case .magneticField:
            "wave.3.left"
        case .attitude:
            "perspective"
        case .gravity:
            "globe"
        }
    }

    var unit: String {
        switch self {
        case .acceleration, .userAcceleration, .gravity:
            "G"
        case .rotationRate:
            "rad/s"
        case .magneticField:
            "μT"
        case .attitude:
            "rad"
        }
    }

}

struct MeasurementConfigurationIntent: WidgetConfigurationIntent {
    static let title: LocalizedStringResource = "Sensor maximum"
    static let description = IntentDescription(
        "Choose the sensor whose maximum is shown on the watch face."
    )

    @Parameter(title: "Sensor", default: .acceleration)
    var measurement: WidgetMeasurement
}

struct OpenMeasurementIntent: AppIntent {
    static let title: LocalizedStringResource = "Open sensor"
    static let openAppWhenRun: Bool = true

    @Parameter(title: "Sensor")
    var measurement: WidgetMeasurement

    init() { }

    init(measurement: WidgetMeasurement) {
        self.measurement = measurement
    }

    func perform() async throws -> some IntentResult {
        WatchWidgetActionRequest.request(
            route: .measurement,
            measurementType: measurement.rawValue
        )
        return .result()
    }
}

struct StartRecordingIntent: AppIntent {
    static let title: LocalizedStringResource = "Start recording"
    static let openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult {
        WatchWidgetActionRequest.request(
            route: .recordings,
            shouldStartRecording: true
        )
        return .result()
    }
}

struct OpenRecordingIntent: AppIntent {
    static let title: LocalizedStringResource = "Open recording"
    static let openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult {
        WatchWidgetActionRequest.request(route: .recordings)
        return .result()
    }
}
