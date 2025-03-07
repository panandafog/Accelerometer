//
//  MeasurementsView.swift
//  Accelerometer
//
//  Created by Andrey on 21.06.2022.
//

import SwiftUI

struct MeasurementsView: View {
    
    func sectionHeader(isFirst: Bool) -> (some View)? {
        isFirst ? Spacer() : nil
    }
    
    var body: some View {
        List {
            ForEach(0 ..< MeasurementType.allShownCases.count) { id in
                let measurementType = MeasurementType.allShownCases[id]
                Section(header: sectionHeader(isFirst: id == 0)) {
                    NavigationLink {
                        MeasurementSummaryView(type: measurementType)
                    } label: {
                        MeasurementPreview(type: measurementType)
                    }
                }
            }
        }
    }
}

struct MeasurementsView_Previews: PreviewProvider {
    
    static let settings = Settings()
    static let measurer = Measurer(settings: settings)
    
    static var previews: some View {
        MeasurementsView()
            .environmentObject(settings)
            .environmentObject(measurer)
    }
}
