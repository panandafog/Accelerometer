//
//  WidgetMotionSampler.swift
//  Accelerometer Watch Widget
//

import CoreMotion
import Foundation

@MainActor
enum WidgetMotionSampler {
    static func sample(measurement: WidgetMeasurement) async -> WatchMeasurementWidgetState? {
        let manager = CMMotionManager()
        guard manager.isDeviceMotionAvailable else {
            return nil
        }

        manager.deviceMotionUpdateInterval = 0.05
        manager.startDeviceMotionUpdates()
        defer {
            manager.stopDeviceMotionUpdates()
        }

        for _ in 0..<10 {
            if let motion = manager.deviceMotion {
                return state(measurement: measurement, motion: motion)
            }
            try? await Task.sleep(for: .milliseconds(50))
        }

        return nil
    }

    private static func state(
        measurement: WidgetMeasurement,
        motion: CMDeviceMotion
    ) -> WatchMeasurementWidgetState {
        switch measurement {
        case .attitude:
            return attitudeState(measurement: measurement, motion: motion)

        default:
            return vectorState(measurement: measurement, motion: motion)
        }
    }

    private static func vectorState(
        measurement: WidgetMeasurement,
        motion: CMDeviceMotion
    ) -> WatchMeasurementWidgetState {
        let vector: (x: Double, y: Double, z: Double)

        switch measurement {
        case .acceleration:
            vector = (
                motion.userAcceleration.x + motion.gravity.x,
                motion.userAcceleration.y + motion.gravity.y,
                motion.userAcceleration.z + motion.gravity.z
            )
        case .rotationRate:
            vector = (
                motion.rotationRate.x,
                motion.rotationRate.y,
                motion.rotationRate.z
            )
        case .userAcceleration:
            vector = (
                motion.userAcceleration.x,
                motion.userAcceleration.y,
                motion.userAcceleration.z
            )
        case .magneticField:
            vector = (
                motion.magneticField.field.x,
                motion.magneticField.field.y,
                motion.magneticField.field.z
            )
        case .gravity:
            vector = (
                motion.gravity.x,
                motion.gravity.y,
                motion.gravity.z
            )
        case .attitude:
            vector = (0, 0, 0)
        }

        let magnitude = hypot(hypot(vector.x, vector.y), vector.z)

        return WatchMeasurementWidgetState(
            measurementType: measurement.rawValue,
            name: measurement.name,
            iconName: measurement.iconName,
            unit: measurement.unit,
            primaryLabel: nil,
            primaryValue: valueLabel(magnitude),
            axisValues: [
                "x \(valueLabel(vector.x))",
                "y \(valueLabel(vector.y))",
                "z \(valueLabel(vector.z))"
            ],
            intensity: min(1, abs(magnitude) / measurement.displayableAbsMax),
            updatedAt: .now
        )
    }

    private static func attitudeState(
        measurement: WidgetMeasurement,
        motion: CMDeviceMotion
    ) -> WatchMeasurementWidgetState {
        let roll = motion.attitude.roll
        let pitch = motion.attitude.pitch
        let yaw = motion.attitude.yaw

        return WatchMeasurementWidgetState(
            measurementType: measurement.rawValue,
            name: measurement.name,
            iconName: measurement.iconName,
            unit: measurement.unit,
            primaryLabel: "roll",
            primaryValue: valueLabel(roll),
            axisValues: [
                "roll \(valueLabel(roll))",
                "pitch \(valueLabel(pitch))",
                "yaw \(valueLabel(yaw))"
            ],
            intensity: min(1, abs(roll) / measurement.displayableAbsMax),
            updatedAt: .now
        )
    }

    private static func valueLabel(_ value: Double) -> String {
        String(format: "%.3f", value)
    }
}
