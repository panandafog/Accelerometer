//
//  AlwaysNotEnoughMemoryView.swift
//  Accelerometer
//
//  Created by Andrey Pantyuhin on 22.09.2025.
//

import SwiftUI

struct AlwaysNotEnoughMemoryView: View {
    
    @EnvironmentObject var settings: Settings
    
    var body: some View {
        Toggle(
            "Not enough memory on device",
            isOn: Binding(
                get: {
                    settings.alwaysNotEnoughMemory
                },
                set: {
                    settings.alwaysNotEnoughMemory = $0
                }
            )
        )
        .tint(.accentColor)
    }
}

struct AlwaysNotEnoughMemoryViewPreviews: PreviewProvider {
    static var previews: some View {
        AlwaysNotEnoughMemoryView()
            .previewLayout(.sizeThatFits)
            .environmentObject(Settings())
    }
}
