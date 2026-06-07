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
            NavigationLink {
                WatchMeasurementDetailView(type: type)
            } label: {
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
}

private struct WatchMeasurementDetailView: View {
    @EnvironmentObject private var measurer: Measurer

    let type: MeasurementType

    var body: some View {
        Group {
            if let observableAxes = measurer.observableAxes[type] {
                WatchMeasurementAxesList(
                    type: type,
                    observableAxes: observableAxes
                )
            } else {
                WatchMeasurementAxesPlaceholderList(type: type)
            }
        }
        .navigationTitle(type.name.capitalizingFirstLetter())
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct WatchMeasurementAxesList: View {
    let type: MeasurementType
    @ObservedObject var observableAxes: ObservableAxes

    var body: some View {
        List(values) { value in
            WatchMeasurementAxisRow(value: value)
        }
    }

    private var values: [WatchMeasurementValue] {
        WatchMeasurementValue.axisValues(
            for: type,
            axes: observableAxes.axes
        )
    }
}

private struct WatchMeasurementAxesPlaceholderList: View {
    let type: MeasurementType

    var body: some View {
        List(WatchMeasurementValue.placeholderAxisValues(for: type)) { value in
            WatchMeasurementAxisRow(value: value)
        }
    }
}

private struct WatchMeasurementAxisRow: View {
    let value: WatchMeasurementValue

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value.name ?? "")
                .font(.caption)
                .foregroundStyle(.secondary)

            WatchMeasurementValueLabel(value: value)
                .font(.title3)
        }
        .padding(.vertical, 2)
    }
}

private struct WatchMeasurementValueLabel: View {
    let value: WatchMeasurementValue

    var body: some View {
        Text(value.value)
            .monospacedDigit()
            .padding(.horizontal, 6)
            .padding(.vertical, 4)
            .background(
                value.color.animation(
                    .linear(duration: 0.2),
                    value: value.color
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 6))
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

                    WatchMeasurementValueLabel(value: value)
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
                    value: magnitudeAxes.valueLabel(of: .magnitude) ?? WatchMeasurementValue.placeholder.value,
                    color: magnitudeAxes.intensityColor
                )
            ]
        }

        if let attitudeAxes = axes as? AttitudeAxes {
            return AttitudeAxes.sortedAxesTypes.map {
                WatchMeasurementValue.axisValue(
                    type: $0,
                    axes: attitudeAxes
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
    let color: Color
    var id: String { name ?? "value" }

    init(
        name: String? = nil,
        value: String,
        color: Color = .intensity(0)
    ) {
        self.name = name
        self.value = value
        self.color = color
    }

    static let placeholder = WatchMeasurementValue(value: "...")

    static func axisValues(
        for type: MeasurementType,
        axes: any Axes
    ) -> [WatchMeasurementValue] {
        switch type.axesType {
        case .triangle:
            guard let axes = axes as? TriangleAxes else {
                return placeholderAxisValues(for: type)
            }
            return TriangleAxes.sortedAxesTypes.map {
                axisValue(type: $0, axes: axes)
            }

        case .attitude:
            guard let axes = axes as? AttitudeAxes else {
                return placeholderAxisValues(for: type)
            }
            return AttitudeAxes.sortedAxesTypes.map {
                axisValue(type: $0, axes: axes)
            }

        case .bool:
            guard let axes = axes as? BooleanAxes else {
                return placeholderAxisValues(for: type)
            }
            return BooleanAxes.sortedAxesTypes.map {
                WatchMeasurementValue(
                    name: $0.name,
                    value: axes.valueLabel(of: $0) ?? placeholder.value,
                    color: .intensity(axes.values[$0]?.value == true ? 1 : 0)
                )
            }
        }
    }

    static func placeholderAxisValues(
        for type: MeasurementType
    ) -> [WatchMeasurementValue] {
        let axesTypes: [AxeType] = switch type.axesType {
        case .triangle:
            TriangleAxes.sortedAxesTypes
        case .attitude:
            AttitudeAxes.sortedAxesTypes
        case .bool:
            BooleanAxes.sortedAxesTypes
        }

        return axesTypes.map {
            WatchMeasurementValue(name: $0.name, value: placeholder.value)
        }
    }

    static func axisValue<AxesType: Axes>(
        type: AxeType,
        axes: AxesType
    ) -> WatchMeasurementValue where AxesType.ValueType == Double {
        WatchMeasurementValue(
            name: type.name,
            value: axes.valueLabel(of: type) ?? placeholder.value,
            color: intensityColor(
                value: axes.values[type]?.value ?? 0,
                displayableAbsMax: axes.displayableAbsMax
            )
        )
    }

    private static func intensityColor(
        value: Double,
        displayableAbsMax: Double
    ) -> Color {
        guard displayableAbsMax > 0 else {
            return .intensity(0)
        }

        return .intensity(abs(value) / displayableAbsMax)
    }
}

#Preview {
    let settings = Settings()
    let measurer = Measurer(settings: settings)

    WatchMeasurementsView()
        .environmentObject(settings)
        .environmentObject(measurer)
}
