//
//  RecordingChartContainerView.swift
//  Accelerometer
//
//  Created by Andrey Pantyuhin on 22.03.2025.
//

import SwiftUI
import Charts
import UniformTypeIdentifiers

struct RecordingChartContainerView: View {
    
    let recording: Recording
    let measurementType: MeasurementType
    let style: Style
    let displayMode: RecordingChartDisplayMode
    
    @EnvironmentObject private var settings: Settings
    @State private var chartEntries: [Recording.Entry] = []
    @State private var chartGaps: [RecordingGap] = []
    @State private var isLoading = true
    @State private var isPresentingExporter = false
    @State private var exportURL: URL?
    
    private let processor = RecordingProcessor()

    private var effectiveDisplayMode: RecordingChartDisplayMode {
        measurementType.supportsVectorChartRepresentation ? displayMode : .axes
    }
    
    private var startDate: Date {
        chartEntries.first?.date ?? recording.start
    }
    
    private var totalDuration: TimeInterval {
        guard let last = chartEntries.last?.date else { return 0 }
        return max(0, last.timeIntervalSince(startDate))
    }

    private var chartGapRanges: [ChartGapRange] {
        chartGaps.compactMap { gap in
            let startElapsed = gap.start.timeIntervalSince(startDate)
            let endElapsed = gap.end.timeIntervalSince(startDate)
            let lowerBound = max(0, min(startElapsed, endElapsed))
            let upperBound = min(totalDuration, max(startElapsed, endElapsed))

            guard upperBound > lowerBound else { return nil }

            return ChartGapRange(
                id: gap.id,
                startElapsed: lowerBound,
                endElapsed: upperBound
            )
        }
    }
    
    private var chartXAxisStride: Double {
        let niceIntervals: [Double] = [
            // seconds
            0.1, 0.2, 0.5, 1, 2, 5, 10, 15, 30, 60,
            // minutes
            2*60, 5*60, 10*60, 15*60, 30*60,
            // hours
            60*60, 2*60*60, 3*60*60, 6*60*60, 12*60*60
        ]
        
        for interval in niceIntervals {
            let tickCount = Int(totalDuration / interval)
            if tickCount <= style.tickCount {
                return interval
            }
        }
        
        return totalDuration / Double(style.tickCount)
    }
    
    private func formatElapsedTime(_ seconds: TimeInterval) -> String {
        let absSeconds = abs(seconds)
        
        if absSeconds < 1 {
            return String(format: "%.1fs", seconds)
        } else if absSeconds < 60 {
            return String(format: "%.0fs", seconds)
        } else if absSeconds < 3600 {
            // If stride is less than a minute, display minutes:seconds
            if chartXAxisStride < 60 {
                let minutes = Int(seconds / 60)
                let remainingSeconds = Int(seconds.truncatingRemainder(dividingBy: 60))
                return String(format: "%dm%02ds", minutes, remainingSeconds)
            } else {
                // Otherwise only minutes
                let minutes = seconds / 60
                return String(format: "%.0fm", minutes)
            }
        } else {
            if chartXAxisStride < 3600 {
                let hours = Int(seconds / 3600)
                let minutes = Int((seconds.truncatingRemainder(dividingBy: 3600)) / 60)
                return String(format: "%dh%02dm", hours, minutes)
            } else {
                let hours = seconds / 3600
                if hours.truncatingRemainder(dividingBy: 1) == 0 {
                    return String(format: "%.0fh", hours)
                } else {
                    return String(format: "%.1fh", hours)
                }
            }
        }
    }
    
    var body: some View {
        chart
            .exportable(
                isPresented: $isPresentingExporter,
                url: $exportURL,
                measurementType: measurementType
            )
            .task {
                await loadData()
            }
    }
    
    @ViewBuilder
    var chartContainer: some View {
        if isLoading {
            ProgressView()
        } else {
            chart
        }
    }
    
    @ViewBuilder
    var chart: some View {
        Chart {
            ForEach(chartEntries) { entry in
                RecordingChartContent(
                    entry: entry,
                    // Can be delay between start and first entry
                    startDate: startDate,
                    displayMode: effectiveDisplayMode
                )
            }
        }
        .chartXScale(domain: 0...totalDuration)
        .chartBackground { proxy in
            GeometryReader { geometry in
                let plotFrame = geometry[proxy.plotAreaFrame]

                ZStack(alignment: .topLeading) {
                    ForEach(chartGapRanges) { gap in
                        if let startX = proxy.position(forX: gap.startElapsed),
                           let endX = proxy.position(forX: gap.endElapsed) {
                            let lowerX = min(max(min(startX, endX), 0), plotFrame.width)
                            let upperX = min(max(max(startX, endX), 0), plotFrame.width)
                            let width = max(upperX - lowerX, 1)

                            if upperX > lowerX {
                                Rectangle()
                                    .fill(Color.orange.opacity(style.gapOpacity))
                                    .frame(
                                        width: width,
                                        height: plotFrame.height
                                    )
                                    .position(
                                        x: plotFrame.minX + lowerX + width / 2,
                                        y: plotFrame.midY
                                    )
                                    .accessibilityHidden(true)
                            }
                        }
                    }
                }
            }
        }
        .chartXAxis {
            let values = AxisMarkValues.stride(by: chartXAxisStride)
            AxisMarks(values: values) { value in
                AxisGridLine()
                AxisTick()
                if let seconds = value.as(Double.self) {
                    AxisValueLabel {
                        Text(formatElapsedTime(seconds))
                    }
                }
            }
        }
        .modify {
            switch style {
            case .big:
                $0
                    .chartScrollableAxes(.horizontal)
                    .chartScrollPosition(initialX: Int.max)
            case .small:
                $0
            }
        }
        .contextMenu {
            Button("Export \(measurementType.name)") {
                export()
            }
        }
    }
    
    private func loadData() async {
        isLoading = true
        chartGaps = recording.detectedGaps(for: measurementType)
        chartEntries = await RecordingProcessor()
            .sampledEntries(
                from: recording,
                for: measurementType,
                maxCount: style.maxEntries
            )
        isLoading = false
    }
    
    private func export() {
        Task {
            if let url = try? await processor.generateCSV(
                from: recording,
                for: measurementType,
                dateFormat: settings.exportDateFormat
            ) {
                exportURL = url
                isPresentingExporter = true
            }
        }
    }
    
    enum Style {
        case big
        case small
        
        var maxEntries: Int {
            switch self {
            case .big:
                300
            case .small:
                100
            }
        }
        
        var tickCount: Int {
            switch self {
            case .big:
                16
            case .small:
                4
            }
        }

        var gapOpacity: Double {
            switch self {
            case .big:
                0.18
            case .small:
                0.14
            }
        }
    }

    private struct ChartGapRange: Identifiable {
        let id: String
        let startElapsed: TimeInterval
        let endElapsed: TimeInterval
    }
}

// MARK: - Previews

#if DEBUG
struct RecordingChartContainerView_Previews: PreviewProvider {
    static let recording = PreviewUtils.mediumRecording
    static let type = measurementType(from: recording)

    static var previews: some View {
        Group {
            RecordingChartContainerView(
                recording: recording,
                measurementType: type,
                style: .small,
                displayMode: .axes
            )
            .frame(height: 200)
            .padding()
            .previewDisplayName("Small")

            RecordingChartContainerView(
                recording: recording,
                measurementType: type,
                style: .big,
                displayMode: .axes
            )
            .previewDisplayName("Big")
        }
        .environmentObject(Settings())
    }

    private static func measurementType(from recording: Recording) -> MeasurementType {
        recording.sortedMeasurementTypes.first ?? .acceleration
    }
}
#endif
