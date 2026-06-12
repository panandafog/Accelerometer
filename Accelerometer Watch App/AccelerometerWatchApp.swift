//
//  Accelerometer_WatchApp.swift
//  Accelerometer Watch Watch App
//
//  Created by Andrey Pantyuhin on 06.11.2025.
//

import SwiftUI

@main
struct AccelerometerWatchApp: App {
    let settings = Settings()
    let measurer: Measurer
    let recorder: WatchRecorder

    init() {
        self.measurer = Measurer(settings: settings)
        self.recorder = WatchRecorder(measurer: measurer)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(settings)
                .environmentObject(measurer)
                .environmentObject(recorder)
                .onAppear {
                    measurer.startAll()
                }
                .onDisappear {
                    if !recorder.isRecording {
                        measurer.stopAll()
                    }
                }
        }
    }
}
