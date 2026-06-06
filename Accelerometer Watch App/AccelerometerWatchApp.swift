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

    init() {
        self.measurer = Measurer(settings: settings)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(settings)
                .environmentObject(measurer)
                .onAppear {
                    measurer.startAll()
                }
                .onDisappear {
                    measurer.stopAll()
                }
        }
    }
}
