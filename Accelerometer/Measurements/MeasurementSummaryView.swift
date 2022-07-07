//
//  MeasurementSummaryView.swift
//  Accelerometer
//
//  Created by Andrey on 22.06.2022.
//

import SwiftUI

struct MeasurementSummaryView: View {
    @ObservedObject var measurer = Measurer.shared
    let type: Measurer.MeasurementType
    
    var axesBinding: Binding<Axes?> {
        Binding<Axes?>.init(
            get: {
                measurer.axes(of: type)
            },
            set: { _ in }
        )
    }
    
    var body: some View {
        VStack {
            Spacer()
            GeometryReader { geometry in
                let size = geometry.size.width * 0.33
                HStack {
                    Spacer()
                    DiagramView(axes: axesBinding)
                        .frame(width: size, height: size)
                }
                .padding([.horizontal])
            }
            Spacer()
            MeasurementsAxesView(axes: axesBinding)
                .padding([.bottom])
            Spacer()
        }
        .navigationTitle(type.name)
    }
}

struct MeasurementSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        MeasurementSummaryView(type: .deviceMotion)
    }
}
