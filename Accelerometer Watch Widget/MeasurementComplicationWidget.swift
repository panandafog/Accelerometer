//
//  MeasurementComplicationWidget.swift
//  Accelerometer Watch Widget
//

import AppIntents
import SwiftUI
import WidgetKit

struct MeasurementComplicationWidget: Widget {
    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: WatchMeasurementWidgetState.widgetKind,
            intent: MeasurementConfigurationIntent.self,
            provider: MeasurementProvider()
        ) { entry in
            MeasurementComplicationView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Sensor maximum")
        .description("Shows the maximum reading measured by the watch app.")
        .supportedFamilies([
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline,
            .accessoryCorner
        ])
    }
}

private struct MeasurementProvider: AppIntentTimelineProvider {
    func recommendations() -> [AppIntentRecommendation<MeasurementConfigurationIntent>] {
        WidgetMeasurement.allCases.map { measurement in
            let intent = MeasurementConfigurationIntent()
            intent.measurement = measurement
            return AppIntentRecommendation(intent: intent, description: Text(measurement.name))
        }
    }

    func placeholder(in context: Context) -> MeasurementEntry {
        MeasurementEntry(
            date: .now,
            configuration: .acceleration,
            state: sampleState
        )
    }

    func snapshot(
        for configuration: MeasurementConfigurationIntent,
        in context: Context
    ) async -> MeasurementEntry {
        entry(for: configuration)
    }

    func timeline(
        for configuration: MeasurementConfigurationIntent,
        in context: Context
    ) async -> Timeline<MeasurementEntry> {
        Timeline(
            entries: [entry(for: configuration)],
            policy: .never
        )
    }

    private func entry(for configuration: MeasurementConfigurationIntent) -> MeasurementEntry {
        MeasurementEntry(
            date: .now,
            configuration: configuration,
            state: WatchMeasurementWidgetState.load(
                measurementType: configuration.measurement.rawValue
            )
        )
    }

    private var sampleState: WatchMeasurementWidgetState {
        WatchMeasurementWidgetState(
            measurementType: WidgetMeasurement.acceleration.rawValue,
            name: WidgetMeasurement.acceleration.name,
            iconName: WidgetMeasurement.acceleration.iconName,
            unit: WidgetMeasurement.acceleration.unit,
            maximumLabel: nil,
            maximumValue: "1.02",
            axisMaximumValues: ["x 0.82", "y 0.61", "z 1.01"],
            intensity: 0.72,
            updatedAt: .now
        )
    }
}

private struct MeasurementEntry: TimelineEntry {
    let date: Date
    let configuration: MeasurementConfigurationIntent
    let state: WatchMeasurementWidgetState?
}

private struct MeasurementComplicationView: View {
    @Environment(\.widgetFamily) private var family

    let entry: MeasurementEntry

    private var measurement: WidgetMeasurement {
        entry.configuration.measurement
    }

    private var name: String {
        entry.state?.name ?? measurement.name
    }

    private var iconName: String {
        entry.state?.iconName ?? measurement.iconName
    }

    private var unit: String {
        entry.state?.unit ?? measurement.unit
    }

    private var value: String {
        entry.state?.maximumValue ?? "..."
    }

    private var intensity: Double {
        entry.state?.intensity ?? 0
    }

    var body: some View {
        content
            .widgetURL(
                WatchWidgetDeepLink.measurementURL(
                    measurementType: measurement.rawValue
                )
            )
    }

    @ViewBuilder
    private var content: some View {
        switch family {
        case .accessoryCircular:
            Gauge(value: intensity, in: 0...1) {
                Image(systemName: iconName)
            } currentValueLabel: {
                Text(value)
                    .font(.caption2.monospacedDigit())
                    .minimumScaleFactor(0.55)
            }
            .gaugeStyle(.accessoryCircular)
            .widgetAccentable()

        case .accessoryInline:
            Label("\(measurement.shortName) max \(value) \(unit)", systemImage: iconName)

        case .accessoryCorner:
            Image(systemName: iconName)
                .font(.headline)
                .widgetAccentable()
                .widgetLabel {
                    Text("Max \(value) \(unit)")
                        .monospacedDigit()
                }

        default:
            HStack(spacing: 7) {
                Image(systemName: iconName)
                    .font(.title3)
                    .widgetAccentable()

                VStack(alignment: .leading, spacing: 1) {
                    Text("\(name) maximum")
                        .font(.headline)
                        .lineLimit(1)

                    HStack(alignment: .firstTextBaseline, spacing: 3) {
                        if let maximumLabel = entry.state?.maximumLabel {
                            Text("\(maximumLabel) max")
                                .foregroundStyle(.secondary)
                        } else {
                            Text("max")
                                .foregroundStyle(.secondary)
                        }

                        Text(value)
                            .font(.title3.monospacedDigit())
                            .minimumScaleFactor(0.7)

                        Text(unit)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }

                    if let axes = entry.state?.axisMaximumValues {
                        Text(axes.prefix(3).joined(separator: "  "))
                            .font(.caption2.monospacedDigit())
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.65)
                    }
                }
            }
        }
    }
}

private extension MeasurementConfigurationIntent {
    static var acceleration: MeasurementConfigurationIntent {
        let intent = MeasurementConfigurationIntent()
        intent.measurement = .acceleration
        return intent
    }
}
