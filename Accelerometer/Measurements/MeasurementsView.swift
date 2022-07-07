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
                    MeasurementSummaryView(type: .deviceMotion)
                } label: {
                    MeasurementPreview(type: .deviceMotion)
                }
            }
            Section {
                NavigationLink {
                    MeasurementSummaryView(type: .acceleration)
                } label: {
                    MeasurementPreview(type: .acceleration)
                }
            }
            Section {
                NavigationLink {
                    MeasurementSummaryView(type: .rotation)
                } label: {
                    MeasurementPreview(type: .rotation)
                }
            }
            Section {
                NavigationLink {
                    MeasurementSummaryView(type: .magneticField)
                } label: {
                    MeasurementPreview(type: .magneticField)
                }
            }
        }
    }
}

struct MeasurementsView_Previews: PreviewProvider {
    static var previews: some View {
        MeasurementsView()
    }
}
