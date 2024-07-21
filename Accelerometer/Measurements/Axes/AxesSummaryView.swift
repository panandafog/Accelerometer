//
//  AxesSummaryView.swift
//  Accelerometer
//
//  Created by Andrey on 23.07.2022.
//

import SwiftUI

struct AxesSummaryView: View {
    var axesBinding: Binding<ObservableAxes?>
    let type: MeasurementType
    
    var observableAxes: ObservableAxes? {
        axesBinding.wrappedValue
    }
    
    var vectorAxes: (any VectorAxes)? {
        observableAxes?.axes as? (any VectorAxes)
    }
    
    var attitudeAxes: AttitudeAxes? {
        observableAxes?.axes as? AttitudeAxes
    }
    
    var booleanAxes: BooleanAxes? {
        observableAxes?.axes as? BooleanAxes
    }
    
    var body: some View {
        // TODO: use MeasurementType.axesType
        if let vectorAxes = vectorAxes {
            VectorAxesSummaryView(
                axes: vectorAxes,
                type: type
            )
        } else if let attitudeAxes = attitudeAxes {
            AttitudeAxesSummaryView(
                axes: attitudeAxes,
                type: type
            )
        } else if let booleanAxes = booleanAxes {
            BooleanAxesSummaryView(
                axes: booleanAxes,
                type: type
            )
        } else {
            AnyAxesSummaryView(
                type: type
            )
        }
    }
}

struct AxesSummaryView_Previews: PreviewProvider {
    
    static let axes1: Binding<ObservableAxes?> = .init(
        get: {
            return ObservableAxes(
                axes: TriangleAxes(
                    axes: [
                        .x: .init(type_: .x, value: 0),
                        .y: .init(type_: .y, value: 0),
                        .z: .init(type_: .z, value: 0),
                    ],
                    measurementType: .userAcceleration
                )
            )
        },
        set: { _ in }
    )
    
    static let axes2: Binding<ObservableAxes?> = .init(
        get: {
            return ObservableAxes(
                axes: TriangleAxes(
                    axes: [
                        .x: .init(type_: .x, value: 0.5),
                        .y: .init(type_: .y, value: 0.5),
                        .z: .init(type_: .z, value: 0.5),
                    ],
                    measurementType: .userAcceleration
                )
            )
        },
        set: { _ in }
    )
    
    static let axes3: Binding<ObservableAxes?> = .init(
        get: {
            return ObservableAxes(
                axes: TriangleAxes(
                    axes: [
                        .x: .init(type_: .x, value: 1),
                        .y: .init(type_: .y, value: 1),
                        .z: .init(type_: .z, value: 1),
                    ],
                    measurementType: .userAcceleration
                )
            )
        },
        set: { _ in }
    )
    
    static var previews: some View {
        Group {
            AxesSummaryView(axesBinding: axes1, type: .userAcceleration)
                .padding()
                .previewLayout(.sizeThatFits)
            AxesSummaryView(axesBinding: axes2, type: .userAcceleration)
                .padding()
                .previewLayout(.sizeThatFits)
            AxesSummaryView(axesBinding: axes3, type: .userAcceleration)
                .padding()
                .previewLayout(.sizeThatFits)
            
            AxesSummaryView(axesBinding: axes1, type: .userAcceleration)
                .padding()
                .previewLayout(.sizeThatFits)
                .preferredColorScheme(.dark)
            AxesSummaryView(axesBinding: axes2, type: .userAcceleration)
                .padding()
                .previewLayout(.sizeThatFits)
                .preferredColorScheme(.dark)
            AxesSummaryView(axesBinding: axes3, type: .userAcceleration)
                .padding()
                .previewLayout(.sizeThatFits)
                .preferredColorScheme(.dark)
        }
    }
}
