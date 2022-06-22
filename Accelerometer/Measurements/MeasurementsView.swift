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
                    VStack(alignment: .leading) {
                        Text("Device motion")
                            .font(.title2)
                            .padding()
                        MeasurementsAxesView(axes: $measurer.deviceMotion)
                            .padding([.bottom])
                    }
                }
            }
            Section {
                NavigationLink {
                    MeasurementSummaryView(type: .acceleration)
                } label: {
                    VStack(alignment: .leading) {
                        Text("Acceleration")
                            .font(.title2)
                            .padding()
                        MeasurementsAxesView(axes: $measurer.acceleration)
                            .padding([.bottom])
                    }
                }
            }
            Section {
                NavigationLink {
                    MeasurementSummaryView(type: .rotation)
                } label: {
                    VStack(alignment: .leading) {
                        Text("Rotation")
                            .font(.title2)
                            .padding()
                        MeasurementsAxesView(axes: $measurer.rotation)
                            .padding([.bottom])
                    }
                }
            }
            Section {
                NavigationLink {
                    MeasurementSummaryView(type: .magneticField)
                } label: {
                    VStack(alignment: .leading) {
                        Text("Magnetic field")
                            .font(.title2)
                            .padding()
                        MeasurementsAxesView(axes: $measurer.magneticField)
                            .padding([.bottom])
                    }
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
