//
//  Gyros.swift
//  Accelerometer
//
//  Created by Andrey on 21.06.2022.
//

import Combine
import CoreMotion
import SwiftUI

class Measurer: ObservableObject {
    static let shared = Measurer()
//    private init() { }
    
    static let measurementsDisplayRoundPlaces = 3
    
    static let maxUpdateInterval = 1.0
    static let minUpdateInterval = 0.1
    static let updateIntervalStep = 0.1
    static let updateIntervalRoundPlaces = 1
    
    private static let initialUpdateInterval = 0.5
    
    @Published var deviceMotion: Axes?
    @Published var acceleration: Axes?
    @Published var rotation: Axes?
    @Published var magneticField: Axes?
    
    var deviceMotionSubscription: AnyCancellable?
    var accelerationSubscription: AnyCancellable?
    var rotationSubscription: AnyCancellable?
    var magneticFieldSubscription: AnyCancellable?
    
    private let deviceMotionDisplayableAbsMax = 0.1
    private let accelerationDisplayableAbsMax = 1.0
    private let rotationDisplayableAbsMax = 2.0
    private let magneticFieldDisplayableAbsMax = 400.0
    
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
    
    var removeGravity: Bool {
        get {
            UserDefaults.standard.bool(forKey: "RemoveGravity")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "RemoveGravity")
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
                x: data.userAcceleration.x,
                y: data.userAcceleration.y,
                z: data.userAcceleration.z,
                type: .deviceMotion
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
                x: data.acceleration.x,
                y: data.acceleration.y,
                z: data.acceleration.z,
                type: .acceleration
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
                x: data.rotationRate.x,
                y: data.rotationRate.y,
                z: data.rotationRate.z,
                type: .rotation
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
                x: data.magneticField.x,
                y: data.magneticField.y,
                z: data.magneticField.z,
                type: .magneticField
            )
        }
    }
    
    func saveData(x: Double, y: Double, z: Double, type: MeasurementType) {
        switch type {
        case .acceleration:
            if acceleration == nil {
                acceleration = Axes(displayableAbsMax: accelerationDisplayableAbsMax)
                accelerationSubscription = acceleration?.objectWillChange.sink { [weak self] _ in
                    self?.objectWillChange.send()
                }
            }
            
            acceleration?.properties.setValues(
                x: x,
                y: y,
                z: z// + (removeGravity ? 1.0 : 0.0)
            )
        case .rotation:
            if rotation == nil {
                rotation = Axes(displayableAbsMax: rotationDisplayableAbsMax)
                rotationSubscription = rotation?.objectWillChange.sink { [weak self] _ in
                    self?.objectWillChange.send()
                }
            }
            
            rotation?.properties.setValues(
                x: x,
                y: y,
                z: z
            )
        case .deviceMotion:
            if deviceMotion == nil {
                deviceMotion = Axes(displayableAbsMax: deviceMotionDisplayableAbsMax)
                deviceMotionSubscription = deviceMotion?.objectWillChange.sink { [weak self] _ in
                    self?.objectWillChange.send()
                }
            }
            
            deviceMotion?.properties.setValues(
                x: x,
                y: y,
                z: z
            )
        case .magneticField:
            if magneticField == nil {
                magneticField = Axes(displayableAbsMax: magneticFieldDisplayableAbsMax)
                magneticFieldSubscription = magneticField?.objectWillChange.sink { [weak self] _ in
                    self?.objectWillChange.send()
                }
            }
            
            magneticField?.properties.setValues(
                x: x,
                y: y,
                z: z
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
        switch type {
        case .acceleration:
            acceleration?.reset()
        case .rotation:
            rotation?.reset()
        case .deviceMotion:
            deviceMotion?.reset()
        case .magneticField:
            magneticField?.reset()
        }
    }
    
    func axes(of type: MeasurementType) -> Axes? {
        switch type {
        case .acceleration:
            return acceleration
        case .rotation:
            return rotation
        case .deviceMotion:
            return deviceMotion
        case .magneticField:
            return magneticField
        }
    }
    
    func valueLabel(of type: MeasurementType) -> String? {
        String(
            axes(of: type)?.properties.vector ?? 0.0,
            roundPlaces: Measurer.measurementsDisplayRoundPlaces
        ) + " \(type.unit)"
    }
    
    private func prepareMotion() {
        motion.setUpdateInterval(updateInterval)
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
