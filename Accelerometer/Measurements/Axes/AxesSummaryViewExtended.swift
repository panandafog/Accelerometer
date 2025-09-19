//
//  AxesSummaryViewExtended.swift
//  Accelerometer
//
//  Created by Andrey on 24.07.2022.
//

import SwiftUI

struct AxesSummaryViewExtended: View {
    @EnvironmentObject var measurer: Measurer
    
    let type: MeasurementType
    
    private var observableAxes: ObservableAxes? {
        measurer.observableAxes[type]
    }
    
    private var magnitudeAxe: Axis<Double>? {
        (observableAxes?.axes as? TriangleAxes)?.magnitude
    }
    
    var axesBinding: Binding<ObservableAxes?> {
        Binding<ObservableAxes?>.init(
            get: {
                observableAxes
            },
            set: { _ in }
        )
    }
    
    private var maxString: String {
        if let magnitudeAxe = magnitudeAxe {
            return String(
                magnitudeAxe.max ?? 0,
                roundPlaces: Settings.measurementsDisplayRoundPlaces
            )
        } else {
            return "no data"
        }
    }
    
    private var minString: String {
        if let magnitudeAxe = magnitudeAxe {
            return String(
                magnitudeAxe.min ?? 0,
                roundPlaces: Settings.measurementsDisplayRoundPlaces
            )
        } else {
            return "no data"
        }
    }
    
    var body: some View {
        HStack {
            VStack {
                Text(maxString)
                
                AxesSummaryView(axesBinding: axesBinding, type: type)
                
                if type.hasMinimum {
                    Text(minString)
                }
            }
        }
    }
}

// MARK: - Previews

struct AxesSummaryViewExtended_Previews: PreviewProvider {
    
    // MARK: Test Measurers
    
    struct MeasurerScenario {
        let title: String
        let measurer: Measurer
    }
    
    private static let settings = Settings()
    
    private static func makeMeasurer(x: Double, y: Double, z: Double) -> Measurer {
        let m = Measurer(settings: settings)
        m.saveData(axesType: TriangleAxes.self, measurementType: .userAcceleration,
                   values: [.x: x, .y: y, .z: z])
        m.saveData(axesType: TriangleAxes.self, measurementType: .magneticField,
                   values: [.x: x * 200, .y: y * 200, .z: z * 200])
        return m
    }
    
    private static let scenarios: [MeasurerScenario] = [
        MeasurerScenario(title: "Zero",    measurer: makeMeasurer(x: 0,   y: 0,   z: 0)),
        MeasurerScenario(title: "Half-Max",measurer: makeMeasurer(x: 0.5, y: 0.5, z: 0.5)),
        MeasurerScenario(title: "Full-Max",measurer: makeMeasurer(x: 1,   y: 1,   z: 1))
    ]
    
    // MARK: Preview
    
    static var previews: some View {
        Group {
            ForEach([MeasurementType.userAcceleration, .magneticField], id: \.self) { type in
                PreviewSection(type: type, scenarios: scenarios)
            }
        }
        .environmentObject(settings)
    }
}

// MARK: Helper Views

private struct PreviewSection: View {
    let type: MeasurementType
    let scenarios: [AxesSummaryViewExtended_Previews.MeasurerScenario]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(type.name.capitalizingFirstLetter())
                .font(.title2)
                .padding(.bottom)
            
            VStack(spacing: 20) {
                ForEach(scenarios, id: \.title) { scenario in
                    VStack(spacing: 8) {
                        Text(scenario.title)
                            .font(.caption)
                        AxesSummaryViewExtended(type: type)
                            .environmentObject(scenario.measurer)
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(6)
                            .shadow(radius: 1)
                    }
                }
            }
        }
        .padding()
        .previewDisplayName(type.name.capitalizingFirstLetter())
        .previewLayout(.sizeThatFits)
    }
}
