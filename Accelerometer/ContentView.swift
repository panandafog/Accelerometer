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
            MeasurementsView()
                .tabItem {
                    Label("Measurements", systemImage: "perspective")
                }
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "list.bullet")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
