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
    
    let demoAxes: Binding<ObservableAxes?> = {
        .init(
            get: {
                let axes = ObservableAxes(displayableAbsMax: 1.0)
                axes.properties.setValues(x: 0.2, y: 0.5, z: 0.6)
                return axes
            },
            set: { _ in }
        )
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
//            DiagramView(axes: demoAxes, style: .init(axesNames: .hide))
        }
    }
}
