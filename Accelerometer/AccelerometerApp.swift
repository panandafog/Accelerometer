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
    
    var body: some Scene {
        WindowGroup {
            ContentView()
//            DiagramView(axes: demoAxes, style: .init(axesNames: .hide))
        }
    }
}
