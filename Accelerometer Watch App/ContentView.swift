//
//  ContentView.swift
//  Accelerometer Watch Watch App
//
//  Created by Andrey Pantyuhin on 06.11.2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            WatchMeasurementsView()
                .navigationTitle("Measurements")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static let settings = Settings()
    static let measurer = Measurer(settings: settings)
    
    static var previews: some View {
        ContentView()
            .environmentObject(settings)
            .environmentObject(measurer)
            .previewDevice("Apple Watch Series 8 - 45mm")
    }
}
