//
//  Measurer.swift
//  Accelerometer
//
//  Created by Andrey on 21.06.2022.
//

import Combine
import CoreMotion
import SwiftUI
#if os(watchOS)
import WidgetKit
#endif

@MainActor
class Measurer: ObservableObject {
    
    @Published var observableAxes: [MeasurementType: ObservableAxes] = [:]
    var subscriptions: [MeasurementType: AnyCancellable] = [:]
    
    @ObservedObject private var settings: Settings
    
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
    private var stubTimer: AnyCancellable?
#if os(watchOS)
    private var lastWidgetUpdate = Date.distantPast
#endif
    
    init(settings: Settings) {
        self.settings = settings
        
        settingsSubscription = settings.updateIntervalPublisher
            .sink { [weak self] newInterval in
                if ((self?.motion.isDeviceMotionActive) != nil) {
                    self?.prepareMotion()
                }
                if self?.settings.stubMeasurements == true {
                    self?.restartStubTimer()
                }
            }
        
        if settings.stubMeasurements {
            startStubMeasurements()
        }
    }
    
    func startAll() {
        if settings.stubMeasurements {
            startStubMeasurements()
        } else {
            startDeviceMotion()
            startAccelerometer()
            startGyro()
            startMagnetometer()
            startProximity()
        }
    }
    
    func stopAll() {
        if settings.stubMeasurements {
            stubTimer?.cancel()
            stubTimer = nil
        } else {
            stopDeviceMotion()
            stopAccelerometer()
            stopGyro()
            stopMagnetometer()
            stopProximity()
        }
    }
    
    // MARK: — Real sensors
    
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

#if os(watchOS)
            saveData(
                axesType: TriangleAxes.self,
                measurementType: .rotationRate,
                values: [.x: data.rotationRate.x, .y: data.rotationRate.y, .z: data.rotationRate.z]
            )

            saveData(
                axesType: TriangleAxes.self,
                measurementType: .magneticField,
                values: [
                    .x: data.magneticField.field.x,
                    .y: data.magneticField.field.y,
                    .z: data.magneticField.field.z
                ]
            )
#endif
        }
    }
    
    func startAccelerometer() {
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
    
    func startGyro() {
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
    
    func startMagnetometer() {
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
    
    func startProximity() {
#if os(iOS)
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
#endif
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
#if os(iOS)
        NotificationCenter.default.removeObserver(self)
#endif
    }
    
    // MARK: — Stub measurements for emulator
    
    private func startStubMeasurements() {
        stubTimer = Timer
            .publish(
                every: settings.updateInterval,
                on: .main,
                in: .common
            )
            .autoconnect()
            .sink { [weak self] _ in
                self?.emitStubValues()
            }
    }
    
    private func restartStubTimer() {
        stubTimer?.cancel()
        startStubMeasurements()
    }
    
    private func emitStubValues() {
        for type in MeasurementType.allShownCases {
            let maxVal = displayableAbsMax[type] ?? 1.0
            
            switch type {
                
            case .acceleration, .userAcceleration, .gravity:
                let vx = Double.random(in: -maxVal...maxVal)
                let vy = Double.random(in: -maxVal...maxVal)
                let vz = Double.random(in: -maxVal...maxVal)
                
                saveData(
                    axesType: TriangleAxes.self,
                    measurementType: type,
                    values: [.x: vx, .y: vy, .z: vz]
                )
                
            case .rotationRate:
                let vx = Double.random(in: -maxVal...maxVal)
                let vy = Double.random(in: -maxVal...maxVal)
                let vz = Double.random(in: -maxVal...maxVal)
                
                saveData(
                    axesType: TriangleAxes.self,
                    measurementType: type,
                    values: [.x: vx, .y: vy, .z: vz]
                )
                
            case .magneticField:
                let vx = Double.random(in: -maxVal...maxVal)
                let vy = Double.random(in: -maxVal...maxVal)
                let vz = Double.random(in: -maxVal...maxVal)
                
                saveData(
                    axesType: TriangleAxes.self,
                    measurementType: type,
                    values: [.x: vx, .y: vy, .z: vz]
                )
                
            case .attitude:
                let roll  = Double.random(in: -maxVal...maxVal)
                let pitch = Double.random(in: -maxVal...maxVal)
                let yaw   = Double.random(in: -maxVal...maxVal)
                
                saveData(
                    axesType: AttitudeAxes.self,
                    measurementType: .attitude,
                    values: [.roll: roll, .pitch: pitch, .yaw: yaw]
                )
                
            default:
                break
            }
        }
    }
    
    // MARK: — Shared helpers
    
    func resetAll() {
        MeasurementType.allCases.forEach {
            reset($0)
        }
    }
    
    func reset(_ type: MeasurementType) {
        observableAxes[type]?.reset()
    }
    
    private func prepareMotion() {
        motion.setUpdateInterval(settings.updateInterval)
    }
    
    func saveData<AxesType: Axes>(
        axesType: AxesType.Type,
        measurementType: MeasurementType,
        values: [AxeType: AxesType.ValueType]
    ) {
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
#if os(watchOS)
            updateWatchWidgetStateIfNeeded()
#endif
        }
    }

#if os(watchOS)
    private func updateWatchWidgetStateIfNeeded(now: Date = .now) {
        guard now.timeIntervalSince(lastWidgetUpdate) >= 1 else {
            return
        }

        lastWidgetUpdate = now
        WatchMeasurementWidgetState.save(
            observableAxes.compactMap { type, observableAxes in
                widgetState(type: type, axes: observableAxes.axes, updatedAt: now)
            }
        )
        WidgetCenter.shared.reloadTimelines(ofKind: WatchMeasurementWidgetState.widgetKind)
    }

    private func widgetState(
        type: MeasurementType,
        axes: any Axes,
        updatedAt: Date
    ) -> WatchMeasurementWidgetState? {
        if let axes = axes as? TriangleAxes {
            return WatchMeasurementWidgetState(
                measurementType: type.rawValue,
                name: type.name.capitalizingFirstLetter(),
                iconName: type.iconName,
                unit: type.unit,
                primaryLabel: nil,
                primaryValue: widgetValue(axes.magnitude.value),
                axisValues: TriangleAxes.sortedAxesTypes.compactMap {
                    guard let value = axes.values[$0]?.value else {
                        return nil
                    }
                    return "\($0.name) \(widgetValue(value))"
                },
                intensity: min(1, abs(axes.magnitude.value) / max(axes.displayableAbsMax, 0.0001)),
                updatedAt: updatedAt
            )
        }

        if let axes = axes as? AttitudeAxes {
            let primaryAxis = AxeType.roll
            let primaryValue = axes.values[primaryAxis]?.value ?? 0
            return WatchMeasurementWidgetState(
                measurementType: type.rawValue,
                name: type.name.capitalizingFirstLetter(),
                iconName: type.iconName,
                unit: type.unit,
                primaryLabel: primaryAxis.name,
                primaryValue: widgetValue(primaryValue),
                axisValues: AttitudeAxes.sortedAxesTypes.compactMap {
                    guard let value = axes.values[$0]?.value else {
                        return nil
                    }
                    return "\($0.name) \(widgetValue(value))"
                },
                intensity: min(1, abs(primaryValue) / max(axes.displayableAbsMax, 0.0001)),
                updatedAt: updatedAt
            )
        }

        return nil
    }

    private func widgetValue(_ value: Double) -> String {
        String(value, roundPlaces: Settings.measurementsDisplayRoundPlaces)
    }
#endif
    
#if os(iOS)
    @objc func proximityDidChange(notification: NSNotification) {
        if let device = notification.object as? UIDevice {
            saveData(
                axesType: BooleanAxes.self,
                measurementType: .proximity,
                values: [.bool: device.proximityState]
            )
        }
    }
#endif
}

extension CMMotionManager {
    
    func setUpdateInterval(_ newRefreshRate: Double) {
        accelerometerUpdateInterval = newRefreshRate
        gyroUpdateInterval = newRefreshRate
        deviceMotionUpdateInterval = newRefreshRate
        magnetometerUpdateInterval = newRefreshRate
    }
}
