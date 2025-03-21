//
//  AnimationsView.swift
//  Accelerometer
//
//  Created by Andrey Pantyuhin on 02.03.2025.
//

import SwiftUI

struct AnimationsView: View {
    
    @EnvironmentObject var settings: Settings
    
    func enableAnimations() -> Bool {
        settings.enableAnimations
    }
    
    func setEnableAnimations(_ newValue: Bool) {
        settings.enableAnimations = newValue
    }
    
    var body: some View {
        Toggle(
            "Animations",
            isOn: Binding(
                get: { enableAnimations() },
                set: { setEnableAnimations($0) }
            )
        )
    }
}

struct AnimationsViewPreviews: PreviewProvider {
    static var previews: some View {
        AnimationsView()
            .previewLayout(.sizeThatFits)
            .environmentObject(Settings())
    }
}
