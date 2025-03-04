//
//  Measurer.swift
//  Accelerometer
//
//  Created by Andrey on 21.06.2022.
//

import Combine
import CoreMotion
import SwiftUI

@MainActor
class Measurer: ObservableObject {
    @MainActor static let shared = Measurer()
    
    @Published var observableAxes: [MeasurementType: ObservableAxes] = [:]
    var subscriptions: [MeasurementType: AnyCancellable] = [:]
    
    @ObservedObject private var settings = Settings.shared
    
    private let displayableAbsMax: [MeasurementType: Double] = [
        .userAcceleration: 0.1,
        .acceleration: 1.0,
        .rotationRate: 2.0,
        .magneticField: 400.0,
        .attitude: 1.0,
        .gravity: 1.0
    ]
    
    private let motion = CMMotionManager()
    
    private var settingsSubscription: AnyCancellable?
    
    init() {
        settingsSubscription = settings.updateIntervalPublisher
            .sink { [weak self] newInterval in
                if ((self?.motion.isDeviceMotionActive) != nil) {
                    self?.prepareMotion()
                }
            }
    }
    
    @MainActor func startAll() {
        startDeviceMotion()
        startAccelerometer()
        startGyro()
        startMagnetometer()
        startProximity()
    }
    
    @MainActor func startDeviceMotion() {
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
    
    @MainActor func startAccelerometer() {
        guard !MeasurementType.acceleration.isHidden
                && !motion.isAccelerometerActive else {
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
    
    @MainActor func startGyro() {
        guard !MeasurementType.rotationRate.isHidden
                && !motion.isGyroActive else {
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
    
    @MainActor func startMagnetometer() {
        guard !MeasurementType.magneticField.isHidden
                && !motion.isMagnetometerActive else {
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
    
    @MainActor func startProximity() {
        guard !MeasurementType.proximity.isHidden else { return }
        UIDevice.current.isProximityMonitoringEnabled = true
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(proximityDidChange),
            name: 
                UIDevice
                .proximityStateDidChangeNotification,
            object: UIDevice.current
        )
    }
    
    func stopAll() {
        stopDeviceMotion()
        stopAccelerometer()
        stopGyro()
        stopMagnetometer()
        stopProximity()
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
    
    func stopProximity() {
        NotificationCenter.default.removeObserver(self)
    }
    
    func resetAll() {
        MeasurementType.allCases.forEach {
            reset($0)
        }
    }
    
    func reset(_ type: MeasurementType) {
        observableAxes[type]?.reset()
    }
    
    @MainActor private func prepareMotion() {
        motion.setUpdateInterval(Settings.shared.updateInterval)
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
    
    @MainActor @objc func proximityDidChange(notification: NSNotification) {
        guard let device = notification.object as? UIDevice else { return }
        let currentProximityState = device.proximityState
        
        saveData(
            axesType: BooleanAxes.self,
            measurementType: .proximity,
            values: [.bool: currentProximityState]
        )
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
