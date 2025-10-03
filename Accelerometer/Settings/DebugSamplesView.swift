//
//  DebugSamplesView.swift
//  Accelerometer
//
//  Created by Andrey Pantyuhin on 03.10.2025.
//

import SwiftUI

#if DEBUG
struct DebugSamplesView: View {
    
    @EnvironmentObject var settings: Settings
    @EnvironmentObject var recorder: Recorder
    
    var body: some View {
        Button(
            role: .confirm,
            action: {
                recorder.createDebugSamples()
            },
            label: {
                Text("Create recordings samples")
            }
        )
        .buttonStyle(.glassProminent)
    }
}

struct DebugSamplesViewPreviews: PreviewProvider {
    static var previews: some View {
        DebugSamplesView()
            .previewLayout(.sizeThatFits)
            .environmentObject(Settings())
    }
}
#endif
