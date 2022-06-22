//
//  SettingsView.swift
//  Accelerometer
//
//  Created by Andrey on 21.06.2022.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var measurer = Measurer.shared
    
    var body: some View {
        List {
            Section(header: Text("Measurements update interval"), footer: Text("Interval between measurements in seconds")) {
                RefreshRateView()
                    .padding()
            }
//            Section(header: Text("Accelerometer"), footer: Text("")) {
//                Toggle("Remove gravity", isOn: .init(get: { measurer.removeGravity }, set: { measurer.removeGravity = $0 }))
//            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
