//
//  ContentView.swift
//  Accelerometer
//
//  Created by Andrey on 21.06.2022.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var measurer = Measurer.shared
    
    var body: some View {
        TabView {
            NavigationView {
                MeasurementsView()
                    .navigationTitle(Text("Measurements"))
                    .toolbar {
                        Button("Reset limits") {
                            measurer.resetAll()
                        }
                    }
            }
            .tabItem {
                Label("Measurements", systemImage: "list.bullet")
            }
            
            NavigationView {
                SettingsView()
                    .navigationTitle(Text("Settings"))
            }
            .tabItem {
                Label("Settings", systemImage: "gear")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}