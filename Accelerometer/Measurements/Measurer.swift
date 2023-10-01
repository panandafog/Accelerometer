//
//  Measurer.swift
//  Accelerometer
//
//  Created by Andrey on 21.06.2022.
//

import Combine
import CoreMotion
import SwiftUI

class Measurer: ObservableObject {
    static let shared = Measurer()
    
    static let measurementsDisplayRoundPlaces = 3
    
    static let maxUpdateInterval = 1.0
    static let minUpdateInterval = 0.1
    static let updateIntervalStep = 0.1
    static let updateIntervalRoundPlaces = 1
    
    private static let initialUpdateInterval = 0.5
    
    @Published var observableAxes: [MeasurementType: ObservableAxes] = [:]
    var subscriptions: [MeasurementType: AnyCancellable] = [:]
    
    private let displayableAbsMax: [MeasurementType: Double] = [
        .userAcceleration: 0.1,
        .acceleration: 1.0,
        .rotationRate: 2.0,
        .magneticField: 400.0,
        .attitude: 1.0,
        .gravity: 1.0
    ]
    
    var updateInterval: Double {
        get {
            let defaultValue = UserDefaults.standard.double(forKey: "MeasurementsUpdateInterval")
            if defaultValue == 0.0 || defaultValue < Self.minUpdateInterval || defaultValue > Self.maxUpdateInterval {
                return Self.initialUpdateInterval
            } else {
                return defaultValue
            }
        }
        set {
            let roundedValue = newValue.rounded(toPlaces: Self.updateIntervalRoundPlaces)
            objectWillChange.send()
            motion.setUpdateInterval(roundedValue)
            UserDefaults.standard.set(roundedValue, forKey: "MeasurementsUpdateInterval")
        }
    }
    
    private let motion = CMMotionManager()
    
    func startAll() {
        startDeviceMotion()
        startAccelerometer()
        startGyro()
        startMagnetometer()
    }
    
    func startDeviceMotion() {
        guard !motion.isDeviceMotionActive else {
            return
        }
        prepareMotion()
        
        motion.startDeviceMotionUpdates(to: .main) { [ self ] data, error in
            if let error = error {
                fatalError("\(error.localizedDescription)")
            }
            guard let data = data else {
                fatalError("no data")
            }
            
            saveData(
                axesType: TriangleAxes.self,
                measurementType: .userAcceleration,
                values: [.x: data.userAcceleration.x, .y: data.userAcceleration.y, .z: data.userAcceleration.z]
            )
            
            saveData(
                axesType: AttitudeAxes.self,
                measurementType: .attitude,
                values: [.roll: data.attitude.roll, .pitch: data.attitude.pitch, .yaw: data.attitude.yaw]
            )
            
            saveData(
                axesType: TriangleAxes.self,
                measurementType: .gravity,
                values: [.x: data.gravity.x, .y: data.gravity.y, .z: data.gravity.z]
            )
        }
    }
    
    func startAccelerometer() {
        guard !motion.isAccelerometerActive else {
            return
        }
        prepareMotion()
        
        motion.startAccelerometerUpdates(to: .main) { [ self ] data, error in
            if let error = error {
                fatalError("\(error.localizedDescription)")
            }
            guard let data = data else {
                fatalError("no data")
            }

            saveData(
                axesType: TriangleAxes.self,
                measurementType: .acceleration,
                values: [.x: data.acceleration.x, .y: data.acceleration.y, .z: data.acceleration.z]
            )
        }
    }
    
    func startGyro() {
        guard !motion.isGyroActive else {
            return
        }
        prepareMotion()
        
        motion.startGyroUpdates(to: .main) { [ self ] data, error in
            if let error = error {
                fatalError("\(error.localizedDescription)")
            }
            guard let data = data else {
                fatalError("no data")
            }
            
            saveData(
                axesType: TriangleAxes.self,
                measurementType: .rotationRate,
                values: [.x: data.rotationRate.x, .y: data.rotationRate.y, .z: data.rotationRate.z]
            )
        }
    }
    
    func startMagnetometer() {
        guard !motion.isMagnetometerActive else {
            return
        }
        prepareMotion()
        
        motion.startMagnetometerUpdates(to: .main) { [ self ] data, error in
            if let error = error {
                fatalError("\(error.localizedDescription)")
            }
            guard let data = data else {
                fatalError("no data")
            }
            
            saveData(
                axesType: TriangleAxes.self,
                measurementType: .magneticField,
                values: [.x: data.magneticField.x, .y: data.magneticField.y, .z: data.magneticField.z]
            )
        }
    }
    
    func stopAll() {
        stopDeviceMotion()
        stopAccelerometer()
        stopGyro()
        stopMagnetometer()
    }
    
    func stopDeviceMotion() {
        motion.stopDeviceMotionUpdates()
    }
    
    func stopAccelerometer() {
        motion.stopAccelerometerUpdates()
    }
    
    func stopGyro() {
        motion.stopGyroUpdates()
    }
    
    func stopMagnetometer() {
        motion.stopMagnetometerUpdates()
    }
    
    func resetAll() {
        MeasurementType.allCases.forEach {
            reset($0)
        }
    }
    
    func reset(_ type: MeasurementType) {
        observableAxes[type]?.reset()
    }
    
    private func prepareMotion() {
        motion.setUpdateInterval(updateInterval)
    }
    
    func saveData<AxesType: Axes>(axesType: AxesType.Type, measurementType: MeasurementType, values: [AxeType: AxesType.ValueType]) {
        if observableAxes[measurementType] == nil {
            var axes = axesType.zero
            if let displayableAbsMax = displayableAbsMax[measurementType] as? AxesType.ValueType {
                axes.displayableAbsMax = displayableAbsMax
            }
            axes.measurementType = measurementType
            observableAxes[measurementType] = ObservableAxes(axes: axes)
            subscriptions[measurementType] = observableAxes[measurementType]?.objectWillChange.sink { [weak self] _ in
                self?.objectWillChange.send()
            }
        }
        
        if var axes = observableAxes[measurementType]?.axes as? AxesType {
            axes.set(values: values)
            observableAxes[measurementType]?.axes = axes
        }
    }
}

extension CMMotionManager {
    
    func setUpdateInterval(_ newRefreshRate: Double) {
        accelerometerUpdateInterval = newRefreshRate
        gyroUpdateInterval = newRefreshRate
        deviceMotionUpdateInterval = newRefreshRate
        magnetometerUpdateInterval = newRefreshRate
    }
}
