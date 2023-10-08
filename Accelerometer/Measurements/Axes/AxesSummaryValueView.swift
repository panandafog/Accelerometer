//
//  AxesSummaryValueView.swift
//  Accelerometer
//
//  Created by Andrey on 08.10.2023.
//

import SwiftUI

struct AxesSummaryValueView: View {
    var value: String
    var color: Color
    
    var body: some View {
        Text(value)
            .padding(.defaultPadding)
            .background(
                color.animation(.linear)
            )
            .cornerRadius(.defaultCornerRadius)
    }
}

struct AxesSummaryValueView_Previews: PreviewProvider {
    
    static var previews: some View {
        AxesSummaryValueView(
            value: "0.5",
            color: .intensity(0.5)
        )
    }
}
