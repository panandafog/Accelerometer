//
//  MeasurementsView.swift
//  Accelerometer
//
//  Created by Andrey on 21.06.2022.
//

import SwiftUI

struct MeasurementsView: View {
    @ObservedObject var measurer = Measurer.shared
    
    
    func sectionHeader(isFirst: Bool) -> (some View)? {
        isFirst ? Spacer() : nil
    }
    
    var body: some View {
        List {
            ForEach(0 ..< MeasurementType.allCases.count) { id in
                let measurementType = MeasurementType.allCases[id]
                Section(header: sectionHeader(isFirst: id == 0)) {
                    NavigationLink {
                        MeasurementSummaryView(measurer: measurer, type: measurementType)
                    } label: {
                        MeasurementPreview(measurer: measurer, type: measurementType)
                    }
                }
            }
        }
    }
}

struct MeasurementsView_Previews: PreviewProvider {
    
    static let measurer: Measurer = {
        let measurer = Measurer()
        measurer.saveData(
            axesType: TriangleAxes.self,
            measurementType: .acceleration,
            values: [
                .x: 0.5,
                .y: 0.5,
                .z: 0.5
            ]
        )
        return measurer
    }()
    
    static var previews: some View {
        MeasurementsView(measurer: measurer)
    }
}
