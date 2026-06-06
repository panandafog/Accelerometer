//
//  WatchMeasurementsView.swift
//  Accelerometer Watch Watch App
//
//  Created by OpenAI on 29.05.2026.
//

import SwiftUI

struct WatchMeasurementsView: View {
    @EnvironmentObject private var measurer: Measurer

    var body: some View {
        List(MeasurementType.allShownCases, id: \.self) { type in
            if let observableAxes = measurer.observableAxes[type] {
                WatchMeasurementRow(
                    type: type,
                    observableAxes: observableAxes
                )
            } else {
                WatchMeasurementPlaceholderRow(type: type)
            }
        }
    }
}

private struct WatchMeasurementRow: View {
    let type: MeasurementType
    @ObservedObject var observableAxes: ObservableAxes

    var body: some View {
        WatchMeasurementRowContent(
            type: type,
            axes: observableAxes.axes
        )
    }
}

private struct WatchMeasurementPlaceholderRow: View {
    let type: MeasurementType

    var body: some View {
        WatchMeasurementRowContent(type: type, axes: nil)
    }
}

private struct WatchMeasurementRowContent: View {
    let type: MeasurementType
    let axes: (any Axes)?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(type.name.capitalizingFirstLetter())
                .font(.headline)
                .lineLimit(1)

            WatchMeasurementValues(axes: axes)
        }
        .padding(.vertical, 2)
    }
}

private struct WatchMeasurementValues: View {
    let axes: (any Axes)?

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            ForEach(values) { value in
                HStack(spacing: 4) {
                    if let name = value.name {
                        Text("\(name):")
                            .foregroundStyle(.secondary)
                    }

                    Text(value.value)
                        .monospacedDigit()
                }
            }
        }
        .font(.caption2)
    }

    private var values: [WatchMeasurementValue] {
        guard let axes else {
            return [.placeholder]
        }

        if let magnitudeAxes = axes as? (any MagnitudeAxes) {
            return [
                WatchMeasurementValue(
                    value: magnitudeAxes.valueLabel(of: .magnitude) ?? WatchMeasurementValue.placeholder.value
                )
            ]
        }

        if let attitudeAxes = axes as? AttitudeAxes {
            return AttitudeAxes.sortedAxesTypes.map {
                WatchMeasurementValue(
                    name: $0.name,
                    value: attitudeAxes.valueLabel(of: $0) ?? WatchMeasurementValue.placeholder.value
                )
            }
        }

        if let booleanAxes = axes as? BooleanAxes {
            return BooleanAxes.sortedAxesTypes.map {
                WatchMeasurementValue(
                    name: $0.name,
                    value: booleanAxes.valueLabel(of: $0) ?? WatchMeasurementValue.placeholder.value
                )
            }
        }

        return [.placeholder]
    }
}

private struct WatchMeasurementValue: Identifiable {
    let name: String?
    let value: String
    var id: String { name ?? "value" }

    init(name: String? = nil, value: String) {
        self.name = name
        self.value = value
    }

    static let placeholder = WatchMeasurementValue(value: "...")
}

#Preview {
    let settings = Settings()
    let measurer = Measurer(settings: settings)

    WatchMeasurementsView()
        .environmentObject(settings)
        .environmentObject(measurer)
}
