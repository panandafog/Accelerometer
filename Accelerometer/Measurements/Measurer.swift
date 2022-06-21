//
//  Gyros.swift
//  Accelerometer
//
//  Created by Andrey on 21.06.2022.
//

import Foundation
import CoreMotion
import SwiftUI

class Measurer: ObservableObject {
    static let shared = Measurer()
    private init() { }
    
    static let maxUpdateInterval = 1.0
    static let minUpdateInterval = 0.1
    static let updateIntervalStep = 0.1
    static let updateIntervalRoundPlaces = 1
    
    private static let initialUpdateInterval = 0.5
    
    @Published var rotation: Axes?
    @Published var acceleration: Axes?
    
    var updateInterval: Double {
        get {
            return motion.accelerometerUpdateInterval
        }
        set {
            let roundedValue = newValue.rounded(toPlaces: Self.updateIntervalRoundPlaces)
            print("updateInterval set to \(roundedValue)")
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
        
        motion.startGyroUpdates(to: .main) { data, error in
            if let error = error {
                fatalError("\(error.localizedDescription)")
            }
            guard let data = data else {
                fatalError("no data")
            }
            
            let rotationRate = data.rotationRate
            self.rotation = Axes(x: rotationRate.x, y: rotationRate.y, z: rotationRate.z)
        }
    }
    
    func startAccelerometer() {
//        guard motion.isAccelerometerActive else {
//            fatalError("accelerometer unavailable")
//        }
        guard !motion.isAccelerometerActive else {
            return
        }
        
        motion.startAccelerometerUpdates(to: .main) { data, error in
            if let error = error {
                fatalError("\(error.localizedDescription)")
            }
            guard let data = data else {
                fatalError("no data")
            }
            
            let accelerometerData = data.acceleration
            self.acceleration = Axes(x: accelerometerData.x, y: accelerometerData.y, z: accelerometerData.z)
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
        var x = 0.0
        var y = 0.0
        var z = 0.0
        
        init(x: Double, y: Double, z: Double) {
            self.x = x
            self.y = y
            self.z = z
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
