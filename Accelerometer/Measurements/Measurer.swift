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
    
    @Published var rotation: Axes?
    @Published var acceleration: Axes?
    
    var rotationSubscription: AnyCancellable?
    var accelerationSubscription: AnyCancellable?
    
    var updateInterval: Double {
        get {
            return motion.accelerometerUpdateInterval
        }
        set {
            let roundedValue = newValue.rounded(toPlaces: Self.updateIntervalRoundPlaces)
            objectWillChange.send()
            return motion.setUpdateInterval(roundedValue)
        }
    }
    
    private let motion: CMMotionManager = {
        let motion = CMMotionManager()
        motion.setUpdateInterval(initialUpdateInterval)
        return motion
    }()
    
    func startGyro() {
        //        guard motion.isGyroAvailable else {
        //            fatalError("gyro unavailable")
        //        }
        guard !motion.isGyroActive else {
            return
        }
        
        motion.startGyroUpdates(to: .main) { [ self ] data, error in
            if let error = error {
                fatalError("\(error.localizedDescription)")
            }
            guard let data = data else {
                fatalError("no data")
            }
            
            let rotationRate = data.rotationRate
            
            if rotation == nil {
                rotation = Axes()
                rotationSubscription = rotation?.objectWillChange.sink { [weak self] _ in
                    self?.objectWillChange.send()
                }
            }
            
            rotation?.setValues(x: rotationRate.x, y: rotationRate.y, z: rotationRate.z)
        }
    }
    
    func startAccelerometer() {
        //        guard motion.isAccelerometerActive else {
        //            fatalError("accelerometer unavailable")
        //        }
        guard !motion.isAccelerometerActive else {
            return
        }
        
        motion.startAccelerometerUpdates(to: .main) { [ self ] data, error in
            if let error = error {
                fatalError("\(error.localizedDescription)")
            }
            guard let data = data else {
                fatalError("no data")
            }
            
            let accelerometerData = data.acceleration
            
            if acceleration == nil {
                acceleration = Axes()
                accelerationSubscription = acceleration?.objectWillChange.sink { [weak self] _ in
                    self?.objectWillChange.send()
                }
            }
            
            acceleration?.setValues(x: accelerometerData.x, y: accelerometerData.y, z: accelerometerData.z)
        }
    }
    
    func stopAccelerometer() {
        motion.stopAccelerometerUpdates()
    }
    
    func stopGyro() {
        motion.stopGyroUpdates()
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
