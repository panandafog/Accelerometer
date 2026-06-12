//
//  RecordingStatusWidget.swift
//  Accelerometer Watch Widget
//

import AppIntents
import RelevanceKit
import SwiftUI
import WidgetKit

struct RecordingStatusWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: WatchRecordingWidgetState.widgetKind,
            provider: RecordingStatusProvider()
        ) { entry in
            RecordingStatusView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Recording status")
        .description("Starts a recording and shows its elapsed time.")
        .supportedFamilies([
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline,
            .accessoryCorner
        ])
    }
}

private struct RecordingStatusProvider: TimelineProvider {
    func placeholder(in context: Context) -> RecordingStatusEntry {
        RecordingStatusEntry(
            date: .now,
            state: WatchRecordingWidgetState(start: .now, measurementCount: 4)
        )
    }

    func getSnapshot(
        in context: Context,
        completion: @escaping @Sendable (RecordingStatusEntry) -> Void
    ) {
        completion(RecordingStatusEntry(date: .now, state: WatchRecordingWidgetState.load()))
    }

    func getTimeline(
        in context: Context,
        completion: @escaping @Sendable (Timeline<RecordingStatusEntry>) -> Void
    ) {
        completion(
            Timeline(
                entries: [
                    RecordingStatusEntry(date: .now, state: WatchRecordingWidgetState.load())
                ],
                policy: .never
            )
        )
    }

    func relevance() async -> WidgetRelevance<Void> {
        guard let state = WatchRecordingWidgetState.load() else {
            return WidgetRelevance([])
        }

        return WidgetRelevance([
            WidgetRelevanceAttribute(
                context: RelevantContext.date(
                    from: state.start,
                    to: state.start.addingTimeInterval(12 * 60 * 60)
                )
            )
        ])
    }
}

private struct RecordingStatusEntry: TimelineEntry {
    let date: Date
    let state: WatchRecordingWidgetState?

    var relevance: TimelineEntryRelevance? {
        state == nil ? nil : TimelineEntryRelevance(score: 100, duration: 12 * 60 * 60)
    }
}

private struct RecordingStatusView: View {
    @Environment(\.widgetFamily) private var family

    let entry: RecordingStatusEntry

    var body: some View {
        if let state = entry.state {
            Button(intent: OpenRecordingIntent()) {
                activeContent(state: state)
            }
            .buttonStyle(.plain)
        } else {
            Button(intent: StartRecordingIntent()) {
                inactiveContent
            }
            .buttonStyle(.plain)
        }
    }

    @ViewBuilder
    private func activeContent(state: WatchRecordingWidgetState) -> some View {
        switch family {
        case .accessoryCircular:
            VStack(spacing: 1) {
                Image(systemName: "record.circle.fill")
                    .foregroundStyle(.red)
                    .widgetAccentable()

                Text(state.start, style: .timer)
                    .font(.caption2.monospacedDigit())
                    .minimumScaleFactor(0.6)
            }

        case .accessoryInline:
            Label {
                Text(state.start, style: .timer)
                    .monospacedDigit()
            } icon: {
                Image(systemName: "record.circle.fill")
            }

        case .accessoryCorner:
            Image(systemName: "record.circle.fill")
                .foregroundStyle(.red)
                .widgetAccentable()
                .widgetLabel {
                    Text(state.start, style: .timer)
                        .monospacedDigit()
                }

        default:
            HStack(spacing: 8) {
                Circle()
                    .fill(.red)
                    .frame(width: 12, height: 12)

                VStack(alignment: .leading, spacing: 1) {
                    Text("Recording")
                        .font(.headline)
                        .foregroundStyle(.red)

                    Text(state.start, style: .timer)
                        .font(.title3.monospacedDigit())
                }

                Spacer(minLength: 2)

                VStack(alignment: .trailing, spacing: 1) {
                    Image(systemName: "waveform.path.ecg")
                        .foregroundStyle(.secondary)

                    Text("\(state.measurementCount)")
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    @ViewBuilder
    private var inactiveContent: some View {
        switch family {
        case .accessoryCircular:
            VStack(spacing: 1) {
                Image(systemName: "record.circle")
                    .font(.title3)
                    .widgetAccentable()

                Text("Start")
                    .font(.caption2)
            }

        case .accessoryInline:
            Label("Start recording", systemImage: "record.circle")

        case .accessoryCorner:
            Image(systemName: "record.circle")
                .widgetAccentable()
                .widgetLabel("Start")

        default:
            HStack(spacing: 8) {
                Image(systemName: "record.circle")
                    .font(.title3)
                    .widgetAccentable()

                VStack(alignment: .leading, spacing: 1) {
                    Text("Start recording")
                        .font(.headline)
                    Text("All sensors")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 0)
            }
        }
    }
}
