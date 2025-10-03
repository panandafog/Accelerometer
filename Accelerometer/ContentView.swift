//
//  ContentView.swift
//  Accelerometer
//
//  Created by Andrey on 21.06.2022.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var recorder: Recorder
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationView {
                MeasurementsView()
                    .navigationTitle("Measurements")
            }
            .phoneOnlyStackNavigationView()
            .tabItem {
                Label("Measurements", systemImage: "list.bullet")
            }
            .tag(0)

            NavigationView {
                RecordingsView()
                    .navigationTitle("Recordings")
            }
            .phoneOnlyStackNavigationView()
            .tabItem {
                Label("Recordings", systemImage: "play")
            }
            .tag(1)

            NavigationView {
                SettingsView()
                    .navigationTitle("Settings")
            }
            .navigationViewStyle(.stack)
            .tabItem {
                Label("Settings", systemImage: "gear")
            }
            .tag(2)
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
    }
}
