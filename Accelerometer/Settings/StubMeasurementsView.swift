//
//  StubMeasurementsView.swift
//  Accelerometer
//
//  Created by Andrey Pantyuhin on 05.10.2025.
//

import SwiftUI

#if DEBUG
struct StubMeasurementsView: View {
    
    @EnvironmentObject var settings: Settings
    
    var body: some View {
        Toggle(
            "Use stub measurements",
            isOn: Binding(
                get: { settings.stubMeasurements },
                set: { settings.stubMeasurements = $0 }
            )
        )
        .tint(.accentColor)
    }
}

struct StubMeasurementsViewPreviews: PreviewProvider {
    static var previews: some View {
        StubMeasurementsView()
            .previewLayout(.sizeThatFits)
            .environmentObject(Settings())
    }
}
#endif
