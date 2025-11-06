//
//  Recorder.swift
//  Accelerometer
//
//  Created by Andrey on 29.07.2022.
//

import CoreLocation
import DequeModule
import Combine
import SwiftUI
import AVFoundation

@MainActor
class Recorder: ObservableObject {
    
    private static let memoryCheckCooldownNs: UInt64 = 5_000_000_000
    
    @Published var isInEditMode = false
    @Published var hasEnoughMemory = true
    
    @Published private(set) var recordingsMetadata: [Recording] = []
    @Published private(set) var activeRecording: Recording? = nil
    private var activeRecordingEntries: Deque<Recording.Entry> = []
    
    @ObservedObject private var measurer: Measurer
    @ObservedObject private var settings: Settings
    
    private let repository = RecordingsRepository()
    private let memoryMonitor = MemoryMonitor()
    
    private let disableIdleTimer = true
    private var subscriptions: [AnyCancellable] = []
    
    private var locationManager: CLLocationManager?
    private var backgroundTaskID: UIBackgroundTaskIdentifier = .invalid
    
    init(measurer: Measurer, settings: Settings) {
        self.measurer = measurer
        self.settings = settings
        
        Task {
            await refreshRecordings()
        }
        Task {
            await watchFreeSpace()
        }
        
        setupLocationManager()
    }
    
    var recordingInProgress: Bool {
        activeRecording != nil
    }
    
    // MARK: - Recordings management
    
    func record(measurements types: Set<MeasurementType>) {
        Task {
            if !hasEnoughMemory { return }
            
            await MainActor.run {
                if disableIdleTimer {
                    UIApplication.shared.isIdleTimerDisabled = true
                }
                
                guard !recordingInProgress, !types.isEmpty else { return }
                activeRecording = Recording(
                    entries: [],
                    state: .inProgress,
                    measurementTypes: types
                )
                activeRecordingEntries = []
                
                types.forEach(subscribeForChanges)
                
                objectWillChange.send()
            }
        }
        
        startLocationUpdates()
        beginBackgroundTask()
    }
    
    func stopRecording() {
        Task {
            await MainActor.run {
                if disableIdleTimer {
                    UIApplication.shared.isIdleTimerDisabled = false
                }
            }
            
            guard var activeRecording = activeRecording else { return }
            activeRecording.state = .completed
            activeRecording.end = Date.now
            activeRecording.entries = Array(activeRecordingEntries)
            
#if (DEBUG)
            print("--- Recording stopped ---")
            for measurementType in activeRecording.sortedMeasurementTypes {
                let count = activeRecordingEntries.filter { $0.measurementType == measurementType }.count
                print("\(measurementType.name): \(count) entries")
            }
            let totalCount = activeRecordingEntries.count
            print("Total entries: \(totalCount)")
            print("-------------------------")
#endif
            
            activeRecordingEntries = []
            
            await repository.save([activeRecording])
            await repository.updateMetadata()
            await refreshRecordings()
            
            await MainActor.run {
                self.activeRecording = nil
                subscriptions.removeAll()
                objectWillChange.send()
            }
        }
        
        stopLocationUpdates()
        endBackgroundTask()
    }
    
    func delete(recordingID: String) {
        Task {
            await repository.delete(recordingID: recordingID)
            await repository.updateMetadata()
            await refreshRecordings()
        }
    }
    
    func delete(recordingIDs: [String]) {
        Task {
            await repository.delete(recordingIDs: recordingIDs)
            await repository.updateMetadata()
            await refreshRecordings()
        }
    }
    
    func loadFullRecording(id: String) async -> Recording? {
        return await repository.loadFullRecording(id: id)
    }
    
    private func subscribeForChanges(of type: MeasurementType) {
        guard let obs = measurer.observableAxes[type] else { return }
        
        let sub = obs.objectWillChange.sink { [weak self] in
            self?.appendEntry(for: type)
        }
        subscriptions.append(sub)
    }
    
    private func appendEntry(for type: MeasurementType) {
        guard
            let axes = measurer.observableAxes[type]?.axes,
            activeRecording != nil,
            hasEnoughMemory
        else { return }
        
        activeRecordingEntries.append(
            Recording.Entry(
                measurementType: type,
                date: Date(),
                axes: axes
            )
        )
    }
    
    private func refreshRecordings() async {
        await repository.updateMetadata()
        let stored = await repository.recordingsMetadata
        await MainActor.run {
            recordingsMetadata = Array(stored.values)
                .sorted { $0.start > $1.start }
        }
    }
    
    // MARK: - Memory control
    
    private func watchFreeSpace() async {
        while true {
            await checkMemory()
            
            try? await Task.sleep(
                nanoseconds: Self.memoryCheckCooldownNs
            )
        }
    }
    
    private func checkMemory() async {
#if (DEBUG)
        let hasEnoughMemory = if settings.alwaysNotEnoughMemory {
            false
        } else {
            await hasEnoughMemory()
        }
#else
        let hasEnoughMemory = await hasEnoughMemory()
#endif
        
        if !hasEnoughMemory {
            await MainActor.run { stopRecording() }
        }
        
        await MainActor.run { self.hasEnoughMemory = hasEnoughMemory }
    }
    
    
    private func hasEnoughMemory() async -> Bool {
        let freeMB = await memoryMonitor.freeSpaceMB()
        let hasEnoughMemory = freeMB >= Double(Settings.minFreeSpaceMB)
        return hasEnoughMemory
    }
    
    // MARK: - Background mode, location
    
    private func setupLocationManager() {
        locationManager = CLLocationManager()
        locationManager?.delegate = nil
        locationManager?.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManager?.distanceFilter = 1000
        locationManager?.pausesLocationUpdatesAutomatically = false
        locationManager?.allowsBackgroundLocationUpdates = true
    }
    
    private func startLocationUpdates() {
        guard let locationManager = locationManager else { return }
        
        let status = locationManager.authorizationStatus
        
        if status == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
            print("✅ Location updates started")
        } else {
            print("⚠️ Location permission denied")
        }
    }


    private func stopLocationUpdates() {
        locationManager?.stopUpdatingLocation()
        print("✅ Location updates stopped")
    }

    private func beginBackgroundTask() {
        backgroundTaskID = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }
        print("✅ Background task started: \(backgroundTaskID)")
    }

    private func endBackgroundTask() {
        if backgroundTaskID != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTaskID)
            backgroundTaskID = .invalid
            print("✅ Background task ended")
        }
    }

    
    // MARK: - Debug
    
#if (DEBUG)
    func createDebugSamples() {
        Task {
            await repository.save(
                PreviewUtils.allSampleCompletedRecordings
            )
            await refreshRecordings()
            await MainActor.run {
                objectWillChange.send()
            }
        }
    }
#endif
}
