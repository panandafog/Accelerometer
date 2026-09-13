//
//  MeasurementType.swift
//  Accelerometer
//
//  Created by Andrey on 29.07.2022.
//

import Foundation

enum MeasurementType: String, CaseIterable, Sendable {
    case acceleration
    case rotationRate = "rotation"
    case userAcceleration = "deviceMotion"
    case magneticField
    case attitude
    case gravity
    case proximity
    
    static var allShownCases: [MeasurementType] {
        Self.allCases.filter { !$0.isHidden }
    }
    
    // MARK: - Axes Configuration
    
    var axesType: AxesType {
        switch self {
        case .attitude:
            return .attitude
        case .proximity:
            return .bool
        default:
            return .triangle
        }
    }
    
    // MARK: - Display Properties
    
    var name: String {
        switch self {
        case .acceleration:
            return String(localized: "measurement.acceleration.name")
        case .rotationRate:
            return String(localized: "measurement.rotation_rate.name")
        case .userAcceleration:
            return String(localized: "measurement.user_acceleration.name")
        case .magneticField:
            return String(localized: "measurement.magnetic_field.name")
        case .attitude:
            return String(localized: "measurement.attitude.name")
        case .gravity:
            return String(localized: "measurement.gravity.name")
        case .proximity:
            return String(localized: "measurement.proximity.name")
        }
    }
    
    var unit: String {
        switch self {
        case .acceleration:
            return "G"
        case .rotationRate:
            return "rad / s"
        case .userAcceleration:
            return "G"
        case .magneticField:
            return "μT"
        case .attitude:
            return "rad"
        case .gravity:
            return "G"
        case .proximity:
            return ""
        }
    }
    
    var description: String {
        switch self {
        case .acceleration:
            return String(localized: "measurement.acceleration.description")
        case .rotationRate:
            return String(localized: "measurement.rotation_rate.description")
        case .userAcceleration:
            return String(localized: "measurement.user_acceleration.description")
        case .magneticField:
            return String(localized: "measurement.magnetic_field.description")
        case .attitude:
            return String(localized: "measurement.attitude.description")
        case .gravity:
            return String(localized: "measurement.gravity.description")
        case .proximity:
            return String(localized: "measurement.proximity.description")
        }
    }
    
    /// SF Symbol name for this measurement type
    var iconName: String {
        switch self {
        case .acceleration:
            return "speedometer"
        case .rotationRate:
            return "gyroscope"
        case .userAcceleration:
            return "figure.walk.motion"
        case .magneticField:
            return "wave.3.left"
        case .attitude:
            return "perspective"
        case .gravity:
            return "globe"
        case .proximity:
            return "antenna.radiowaves.left.and.right"
        }
    }

    
    // MARK: - Capabilities
    
    var hasMinimum: Bool {
        switch self {
        case .acceleration:
            return false
        case .rotationRate:
            return false
        case .userAcceleration:
            return false
        case .magneticField:
            return true
        case .attitude:
            return true
        case .gravity:
            return true
        case .proximity:
            return false
        }
    }
    
    var supportsChartRepresentation: Bool { true }

    var supportsVectorChartRepresentation: Bool {
        switch axesType {
        case .triangle:
            return true
        case .attitude, .bool:
            return false
        }
    }
    
    var supportsDiagramRepresentation: Bool {
        switch self {
        case .attitude:
            return false
        case .proximity:
            return false
        default:
            return true
        }
    }
    
    var isHidden: Bool {
        switch self {
        case .proximity:
            return true
        default:
            return false
        }
    }
}

extension MeasurementType {
    
    enum AxesType {
        case triangle
        case attitude
        case bool
        
        var type: any Axes.Type {
            switch self {
            case .triangle:
                return TriangleAxes.self
            case .attitude:
                return AttitudeAxes.self
            case .bool:
                return BooleanAxes.self
            }
        }
    }
}
