//
//  AxesSummaryView.swift
//  Accelerometer
//
//  Created by Andrey on 23.07.2022.
//

import SwiftUI

struct AxesSummaryView: View {
    @Binding var axes: Axes?
    
    var body: some View {
        Text("")
    }
}

struct AxesSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        AxesSummaryView(axes: .init(get: {
            Axes(displayableAbsMax: 1.0)
        }, set: { _ in
            
        }))
    }
}
