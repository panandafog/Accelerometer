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
            return "acceleration"
        case .rotationRate:
            return "rotation rate"
        case .userAcceleration:
            return "user acceleration"
        case .magneticField:
            return "magnetic field"
        case .attitude:
            return "attitude"
        case .gravity:
            return "gravity"
        case .proximity:
            return "proximity"
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
            return "<proximity unit>"
        }
    }
    
    var description: String {
        switch self {
        case .acceleration:
            return """
The acceleration measured by the accelerometer in G's (gravitational force).
A G is a unit of gravitation force equal to that exerted by the earth’s gravitational field (9.81 m s−2).
"""
        case .rotationRate:
            return """
The rotation rate as measured by the device’s gyroscope in radinans per second (rad / s).
"""
        case .userAcceleration:
            return """
The acceleration that the user is giving to the device.
The acceleration measured by the accelerometer in G's (gravitational force).
A G is a unit of gravitation force equal to that exerted by the earth’s gravitational field (9.81 m s−2).
"""
        case .magneticField:
            return """
The total magnetic field which is equal to the Earth’s geomagnetic field plus bias introduced from the device itself and its surroundings.
The magnetic field is measured in microteslas (μT), equal to 10^−6 teslas.
"""
        case .attitude:
            return """
The device’s orientation relative to a known frame of reference at a point in time.
"""
        case .gravity:
            return """
The gravity acceleration vector expressed in the device's reference frame.
A G is a unit of gravitation force equal to that exerted by the earth’s gravitational field (9.81 m s−2).
"""
        case .proximity:
            return "<proximity description>"
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
