//
//  ChartContainerView.swift
//  Accelerometer
//
//  Created by Andrey Pantyuhin on 22.03.2025.
//

import SwiftUI
import Charts
import UniformTypeIdentifiers

struct ChartContainerView: View {
    
    let recording: Recording
    let measurementType: MeasurementType
    let style: Style
    
    @EnvironmentObject private var settings: Settings
    @State private var chartEntries: [Recording.Entry] = []
    @State private var isLoading = true
    @State private var isPresentingExporter = false
    @State private var exportURL: URL?
    
    private let processor = RecordingProcessor()
    
    private var startDate: Date {
        chartEntries.first?.date ?? Date()
    }
    
    private var totalDuration: TimeInterval {
        guard let last = chartEntries.last?.date else { return 0 }
        return last.timeIntervalSince(startDate)
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
            .fileExporter(
                isPresented: $isPresentingExporter,
                document: exportURL.map { FileDocumentWrapper(url: $0) },
                contentType: .plainText,
                defaultFilename: "\(measurementType.rawValue).csv"
            ) { _ in }
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
        Chart(chartEntries) { entry in
            RecordingChartContent(
                entry: entry,
                // Can be delay between start and first entry
                startDate: chartEntries.first?.date ?? recording.start
            )
        }
        .chartXScale(domain: 0...totalDuration)
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
    }
}

// MARK: - Previews

struct ChartContainerView_Previews: PreviewProvider {
    static let recording = PreviewUtils.mediumRecording
    static let type = measurementType(from: recording)

    static var previews: some View {
        Group {
            ChartContainerView(
                recording: recording,
                measurementType: type,
                style: .small
            )
            .frame(height: 200)
            .padding()
            .previewDisplayName("Small")

            ChartContainerView(
                recording: recording,
                measurementType: type,
                style: .big
            )
            .previewDisplayName("Big")
        }
        .environmentObject(Settings())
    }

    private static func measurementType(from recording: Recording) -> MeasurementType {
        recording.sortedMeasurementTypes.first ?? .acceleration
    }
}
