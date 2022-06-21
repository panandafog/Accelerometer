//
//  AppDelegate.swift
//  Accelerometer
//
//  Created by Andrey on 21.06.2022.
//

import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        Measurer.shared.startAccelerometer()
        Measurer.shared.startGyro()
        return true
    }
}
