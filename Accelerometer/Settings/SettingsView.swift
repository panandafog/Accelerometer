//
//  SettingsView.swift
//  Accelerometer
//
//  Created by Andrey on 21.06.2022.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var measurer: Measurer
    
    var body: some View {
        List {
            Section(
                header: Text("Measurements update interval"),
                footer: Text("Interval between measurements in seconds")
            ) {
                RefreshRateView()
                    .padding()
            }
            Section(
                header: Spacer(),
                footer: Text("Format of dates in recording file")
            ) {
                ExportDateFormatView()
            }
            
            #if (DEBUG)
            Section(
                header: Spacer(),
                footer: Text("Debug options")
            ) {
                AnimationsView()
                AlwaysNotEnoughMemoryView()
                DebugSamplesView()
            }
            #endif
            
//            Section(header: Text("Accelerometer"), footer: Text("")) {
//                Toggle("Remove gravity", isOn: .init(get: { measurer.removeGravity }, set: { measurer.removeGravity = $0 }))
//            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    
    static let settings = Settings()
    static let measurer = Measurer(settings: settings)
    static let recorder = Recorder(measurer: measurer, settings: settings)
    
    static var previews: some View {
        SettingsView()
            .environmentObject(settings)
            .environmentObject(measurer)
            .environmentObject(recorder)
    }
}
