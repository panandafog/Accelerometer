//
//  RecordingMeasurementChartView.swift
//  Accelerometer
//
//  Created by Andrey Pantyuhin on 22.03.2025.
//

import Charts
import SwiftUI

struct RecordingMeasurementChartView: View {
    
    let recording: Recording
    let measurementType: MeasurementType
    
    @State private var chartEntries: [Recording.Entry] = []
    @State private var isLoading = true
    
    @State private var isPresentingExporter = false
    @State private var exportURL: URL?
    
    @EnvironmentObject private var settings: Settings
    
    private let processor = RecordingProcessor()
    
    private var startDate: Date {
        chartEntries.first?.date ?? Date()
    }
    
    private var totalDuration: TimeInterval {
        guard let last = chartEntries.last?.date else { return 0 }
        return last.timeIntervalSince(startDate)
    }
    
    var title: String { measurementType.name.capitalizingFirstLetter() }
    
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
            let tickCount = Int(totalDuration / interval) + 1
            if tickCount <= 5 {
                return interval
            }
        }
        
        return totalDuration / 4.0
    }
    
    private func formatElapsedTime(_ seconds: TimeInterval) -> String {
        let absSeconds = abs(seconds)
        
        if absSeconds < 1 {
            return String(format: "%.1fs", seconds)
        } else if absSeconds < 60 {
            return String(format: "%.0fs", seconds)
        } else if absSeconds < 3600 {
            let minutes = seconds / 60
            return String(format: "%.0fm", minutes)
        } else {
            let hours = seconds / 3600
            if hours.truncatingRemainder(dividingBy: 1) == 0 {
                return String(format: "%.0fh", hours)
            } else {
                return String(format: "%.1fh", hours)
            }
        }
    }
    
    // MARK: - body
    var body: some View {
        VStack {
            Text(title)
                .font(.headline)
            
            if isLoading {
                ProgressView()
                    .frame(height: 200)
            } else {
                Chart(chartEntries) { entry in
                    CustomChartContent(entry: entry, startDate: startDate)
                }
                .frame(height: 200)
                .contextMenu {
                    Button("Export \(measurementType.name) to .csv") {
                        export()
                    }
                }
            }
        }
        .task {
            await loadChartData()
        }
        .fileExporter(
            isPresented: $isPresentingExporter,
            document: exportURL.map { FileDocumentWrapper(url: $0) },
            contentType: .plainText,
            defaultFilename: "\(measurementType.rawValue).csv"
        ) { _ in }
    }
    
    private func export() {
        Task {
            do {
                let url = try await processor.generateCSV(
                    from: recording,
                    for: measurementType,
                    dateFormat: settings.exportDateFormat
                )
                exportURL = url
                isPresentingExporter = true
            } catch {
                print("Export failed:", error)
            }
        }
    }
    
    private func loadChartData() async {
        isLoading = true
        let entries = await processor.sampledEntries(
            from: recording,
            for: measurementType,
            maxCount: 50
        )
        await MainActor.run {
            chartEntries = entries
            isLoading = false
        }
    }
}


private struct CustomChartContent: ChartContent {
    let entry: Recording.Entry
    let startDate: Date
    
    var body: AnyChartContent {
        let axes = entry.axes
        AnyChartContent(erasing: createLineMarks(axes: axes))
    }
    
    @ChartContentBuilder
    private func createLineMarks(axes: some Axes) -> some ChartContent {
        
        let axesTypes = type(of: axes).sortedAxesTypes
        
        ForEach(axesTypes) { axeType in
            if let yAxis = axes.values[axeType] {
                let elapsed = entry.date.timeIntervalSince(startDate)
                let xName = "elapsed"
                let yName = yAxis.type_.name
                
                LineMark(
                    x: .value(xName, elapsed),
                    y: .value(yName, yAxis.value)
                )
                .foregroundStyle(by: .value("name", yName))
            }
        }
    }
}

// MARK: - Previews

struct RecordingMeasurementChartView_Previews: PreviewProvider {
    
    // MARK: Test Data Configuration
    
    struct PreviewData {
        let title: String
        let totalPoints: Int
        let samplingRate: Double
        let interval: Double
        
        var entries: [Recording.Entry] {
            let startDate = Date()
            return (0..<totalPoints).map { index in
                let timeOffset = Double(index) * interval / samplingRate
                let date = startDate.addingTimeInterval(timeOffset)
                
                return Recording.Entry(
                    measurementType: .acceleration,
                    date: date,
                    axes: Self.randomAxes
                )
            }
        }
        
        private static var randomAxes: TriangleAxes {
            var axes = TriangleAxes.zero
            axes.displayableAbsMax = 1.0
            axes.values = [
                .x: Axis(type_: .x, value: Double.random(in: -1.0...1.0)),
                .y: Axis(type_: .y, value: Double.random(in: -1.0...1.0)),
                .z: Axis(type_: .z, value: Double.random(in: -1.0...1.0))
            ]
            return axes
        }
    }
    
    // MARK: Preview Scenarios
    
    static let shortDurationData: [PreviewData] = [
        PreviewData(title: "0.2s", totalPoints: Int(0.2 * 100), samplingRate: 100.0, interval: 1.0),
        PreviewData(title: "30s",  totalPoints: 30,               samplingRate: 1.0,  interval: 1.0),
        PreviewData(title: "59s",  totalPoints: 59,               samplingRate: 1.0,  interval: 1.0)
    ]
    
    static let mediumDurationData: [PreviewData] = [
        PreviewData(title: "1+ min", totalPoints: Int(61),   samplingRate: 1.0, interval: 1.0),
        PreviewData(title: "30 min", totalPoints: 30 * 60,   samplingRate: 1.0, interval: 1.0),
        PreviewData(title: "59 min", totalPoints: 59 * 60,   samplingRate: 1.0, interval: 1.0)
    ]
    
    static let longDurationData: [PreviewData] = [
        PreviewData(title: "1.1h",   totalPoints: Int(1.1 * 3600),  samplingRate: 1.0, interval: 1.0),
        PreviewData(title: "6h",     totalPoints: 6 * 3600,        samplingRate: 1.0, interval: 1.0),
        PreviewData(title: "105h",   totalPoints: 105 * 3600,      samplingRate: 1.0, interval: 1.0)
    ]
    
    // MARK: Preview Views
    
    static var previews: some View {
        Group {
            PreviewGroup(title: "Short Duration", data: shortDurationData)
            PreviewGroup(title: "Medium Duration", data: mediumDurationData)
            PreviewGroup(title: "Long Duration", data: longDurationData)
        }
    }
}

// MARK: Helper Views

private struct PreviewGroup: View {
    let title: String
    let data: [RecordingMeasurementChartView_Previews.PreviewData]
    
    var body: some View {
        VStack(spacing: 30) {
            ForEach(data.indices, id: \.self) { index in
                PreviewChart(data: data[index])
            }
        }
        .previewDisplayName(title)
        .previewLayout(.sizeThatFits)
    }
}

private struct PreviewChart: View {
    let data: RecordingMeasurementChartView_Previews.PreviewData
    
    var body: some View {
        VStack(spacing: 20) {
            Text(data.title)
                .font(.headline)
                .foregroundColor(.primary)
            
            RecordingMeasurementChartView(
                recording: Recording(
                    entries: data.entries,
                    state: .completed,
                    measurementTypes: [.acceleration]
                ),
                measurementType: .acceleration
            )
            .frame(height: 200)
        }
    }
}
