//
//  MeasurementsView.swift
//  Accelerometer
//
//  Created by Andrey on 21.06.2022.
//

import SwiftUI

struct MeasurementsView: View {
    @ObservedObject var measurer = Measurer.shared
    
    var body: some View {
        List {
            Section(header: Spacer()) {
                NavigationLink {
                    MeasurementSummaryView(measurer: measurer, type: .deviceMotion)
                } label: {
                    MeasurementPreview(measurer: measurer, type: .deviceMotion)
                }
            }
            Section {
                NavigationLink {
                    MeasurementSummaryView(measurer: measurer, type: .acceleration)
                } label: {
                    MeasurementPreview(measurer: measurer, type: .acceleration)
                }
            }
            Section {
                NavigationLink {
                    MeasurementSummaryView(measurer: measurer, type: .rotation)
                } label: {
                    MeasurementPreview(measurer: measurer, type: .rotation)
                }
            }
            Section {
                NavigationLink {
                    MeasurementSummaryView(measurer: measurer, type: .magneticField)
                } label: {
                    MeasurementPreview(measurer: measurer, type: .magneticField)
                }
            }
        }
    }
}

struct MeasurementsView_Previews: PreviewProvider {
    
    static let measurer: Measurer = {
        let measurer = Measurer()
        MeasurementType.allCases.forEach { type in
            measurer.saveData(x: 0.5, y: 0.5, z: 0.5, type: type)
        }
        return measurer
    }()
    
    static var previews: some View {
        MeasurementsView(measurer: measurer)
    }
}
