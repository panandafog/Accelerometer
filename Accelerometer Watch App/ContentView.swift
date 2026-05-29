//
//  ContentView.swift
//  Accelerometer Watch Watch App
//
//  Created by Andrey Pantyuhin on 06.11.2025.
//

import SwiftUI

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var recorder: Recorder
    
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: MeasurementsView()) {
                    Label("Measurements", systemImage: "list.bullet")
                }
                NavigationLink(destination: RecordingsView()) {
                    Label("Recordings", systemImage: "play")
                }
                NavigationLink(destination: SettingsView()) {
                    Label("Settings", systemImage: "gear")
                }
            }
            .navigationTitle("Menu")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static let settings = Settings()
    static let measurer = Measurer(settings: settings)
    static let recorder = Recorder(measurer: measurer, settings: settings)
    
    static var previews: some View {
        ContentView()
            .environmentObject(settings)
            .environmentObject(measurer)
            .environmentObject(recorder)
            .previewDevice("Apple Watch Series 8 - 45mm")
    }
}
