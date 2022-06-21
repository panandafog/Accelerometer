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
            Section(header: Text("General")) {
                RefreshRateView()
                    .padding()
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
