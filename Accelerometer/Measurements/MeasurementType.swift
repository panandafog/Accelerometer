//
//  MeasurementType.swift
//  Accelerometer
//
//  Created by Andrey on 29.07.2022.
//

import Foundation

public enum MeasurementType: String, CaseIterable {
    case acceleration
    case rotation
    case deviceMotion
    case magneticField
    
    var name: String {
        switch self {
        case .acceleration:
            return "acceleration"
        case .rotation:
            return "rotation"
        case .deviceMotion:
            return "user acceleration"
        case .magneticField:
            return "magnetic field"
        }
    }
    
    var unit: String {
        switch self {
        case .acceleration:
            return "G"
        case .rotation:
            return "rad / s"
        case .deviceMotion:
            return "G"
        case .magneticField:
            return "μT"
        }
    }
    
    var description: String {
        switch self {
        case .acceleration:
            return """
The acceleration measured by the accelerometer in G's (gravitational force).
A G is a unit of gravitation force equal to that exerted by the earth’s gravitational field (9.81 m s−2).
"""
        case .rotation:
            return """
The rotation rate as measured by the device’s gyroscope in radinans per second (rad / s).
"""
        case .deviceMotion:
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
        }
    }
    
    var hasMinimum: Bool {
        switch self {
        case .acceleration:
            return false
        case .rotation:
            return false
        case .deviceMotion:
            return false
        case .magneticField:
            return true
        }
    }
}
