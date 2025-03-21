//
//  ContentView.swift
//  Accelerometer
//
//  Created by Andrey on 21.06.2022.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
        TabView {
            NavigationView {
                MeasurementsView()
                    .navigationTitle(Text("Measurements"))
            }
            .phoneOnlyStackNavigationView()
            .tabItem {
                Label("Measurements", systemImage: "list.bullet")
            }
            
            NavigationView {
                RecordingsView()
                    .navigationTitle(Text("Recordings"))
            }
            .phoneOnlyStackNavigationView()
            .tabItem {
                Label("Recordings", systemImage: "play")
            }
            
            NavigationView {
                SettingsView()
                    .navigationTitle(Text("Settings"))
            }
            .navigationViewStyle(.stack)
            .tabItem {
                Label("Settings", systemImage: "gear")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    
    static let settings = Settings()
    static let measurer = Measurer(settings: settings)
    static let recorder = Recorder(measurer: measurer)
    
    static var previews: some View {
        ContentView()
            .environmentObject(settings)
            .environmentObject(measurer)
            .environmentObject(recorder)
    }
}
