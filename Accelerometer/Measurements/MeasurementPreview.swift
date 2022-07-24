//
//  MeasurementPreview.swift
//  Accelerometer
//
//  Created by Andrey on 07.07.2022.
//

import SwiftUI

struct MeasurementPreview: View {
    @ObservedObject var measurer = Measurer.shared
    let type: Measurer.MeasurementType
    
    var axes: Axes? {
        measurer.axes(of: type)
    }
    
    var axesBinding: Binding<Axes?> {
        Binding<Axes?>.init(
            get: {
                axes
            },
            set: { _ in }
        )
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(type.name)
                    .font(.title2)
                    .padding()
                AxesSummaryView(type: type)
                    .padding([.horizontal, .leading, .bottom])
                    .padding([.leading])
            }.layoutPriority(1)
            Spacer()
            ZStack(alignment: .trailing) {
                Color.clear
                DiagramView(axes: axesBinding)
                    .frame(width: 70, height: 70)
            }
            .frame(minWidth: 70, minHeight: 70)
            .padding()
        }
    }
}

struct MeasurementPreview_Previews: PreviewProvider {
    
    static let measurer: Measurer = {
        let measurer = Measurer()
        measurer.saveData(x: 0.03, y: 0.03, z: 0.03, type: .deviceMotion)
        return measurer
    }()
    
    static var previews: some View {
        MeasurementPreview(measurer: measurer, type: .deviceMotion)
            .previewLayout(.sizeThatFits)
    }
}
