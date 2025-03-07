//
//  AxesSummaryValueView.swift
//  Accelerometer
//
//  Created by Andrey on 08.10.2023.
//

import SwiftUI

struct AxesSummaryValueView: View {
    private static let noValueLabel = "..."
    
    @EnvironmentObject var settings: Settings
    
    var value: String?
    var color: Color
    
    var body: some View {
        Text(value ?? Self.noValueLabel)
            .padding(.defaultPadding)
            .background(
                color.animation(
                    .linear(duration: settings.updateInterval),
                    value: color
                )
            )
            .cornerRadius(.defaultCornerRadius)
    }
}

struct AxesSummaryValueView_Previews: PreviewProvider {
    
    static let settings = Settings()
    
    static var previews: some View {
        AxesSummaryValueView(
            value: "0.5",
            color: .intensity(0.5)
        )
        .environmentObject(settings)
    }
}
