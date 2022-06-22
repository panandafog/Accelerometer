//
//  Gyros.swift
//  Accelerometer
//
//  Created by Andrey on 21.06.2022.
//

import Foundation
import Combine
import CoreMotion
import SwiftUI

class Measurer: ObservableObject {
    static let shared = Measurer()
    private init() { }
    
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
        //        guard motion.isAccelerometerActive else {
        //            fatalError("accelerometer unavailable")
        //        }
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
        //        guard motion.isGyroAvailable else {
        //            fatalError("gyro unavailable")
        //        }
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
                acceleration = Axes()
                accelerationSubscription = acceleration?.objectWillChange.sink { [weak self] _ in
                    self?.objectWillChange.send()
                }
            }
            
            acceleration?.setValues(
                x: x,
                y: y,
                z: z// + (removeGravity ? 1.0 : 0.0)
            )
        case .rotation:
            if rotation == nil {
                rotation = Axes()
                rotationSubscription = rotation?.objectWillChange.sink { [weak self] _ in
                    self?.objectWillChange.send()
                }
            }
            
            rotation?.setValues(
                x: x,
                y: y,
                z: z
            )
        case .deviceMotion:
            if deviceMotion == nil {
                deviceMotion = Axes()
                deviceMotionSubscription = deviceMotion?.objectWillChange.sink { [weak self] _ in
                    self?.objectWillChange.send()
                }
            }
            
            deviceMotion?.setValues(
                x: x,
                y: y,
                z: z
            )
        case .magneticField:
            if magneticField == nil {
                magneticField = Axes()
                magneticFieldSubscription = magneticField?.objectWillChange.sink { [weak self] _ in
                    self?.objectWillChange.send()
                }
            }
            
            magneticField?.setValues(
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
    
    private func prepareMotion() {
        motion.setUpdateInterval(updateInterval)
    }
}

extension Measurer {
    
    class Axes: ObservableObject {
        @Published private (set) var x = 0.0 {
            didSet {
                minX = min(x, minX)
                maxX = max(x, maxX)
            }
        }
        @Published private (set) var y = 0.0 {
            didSet {
                minY = min(y, minY)
                maxY = max(y, maxY)
            }
        }
        @Published private (set) var z = 0.0 {
            didSet {
                minZ = min(z, minZ)
                maxZ = max(z, maxZ)
            }
        }
        
        @Published var minX = 0.0
        @Published var minY = 0.0
        @Published var minZ = 0.0
        
        @Published var maxX = 0.0
        @Published var maxY = 0.0
        @Published var maxZ = 0.0
        
        var vector: Double {
            sqrt(pow(x, 2.0) + pow(y, 2.0) + pow(z, 2.0))
        }
        
        @Published var maxV = 0.0
        @Published var minV = 0.0
        
        init() {  }
        
        init(x: Double, y: Double, z: Double) {
            self.x = x
            self.y = y
            self.z = z
        }
        
        func setValues(x: Double, y: Double, z: Double) {
            self.x = x
            self.y = y
            self.z = z
            
            maxV = max(vector, maxV)
            minV = min(vector, minV)
        }
        
        func reset() {
            minX = 0
            minY = 0
            minZ = 0
            minV = 0
            
            maxX = 0
            maxY = 0
            maxZ = 0
            maxV = 0
        }
    }
    
    enum MeasurementType: CaseIterable {
        case acceleration
        case rotation
        case deviceMotion
        case magneticField
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
