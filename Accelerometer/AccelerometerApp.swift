//
//  AccelerometerApp.swift
//  Accelerometer
//
//  Created by Andrey on 21.06.2022.
//

import SwiftUI

@main
struct AccelerometerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    let settings = Settings()
    let measurer: Measurer
    let recorder: Recorder

    init() {
        self.measurer = Measurer(settings: settings)
        self.recorder = Recorder(measurer: measurer)
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
        }
    }
}
