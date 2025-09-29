//
//  RecordingPreview.swift
//  Accelerometer
//
//  Created by Andrey on 01.08.2022.
//

import SwiftUI
import Combine

struct RecordingPreview: View {
    
    let recording: Recording

    @State private var timerPublisher = Timer.publish(
        every: 1, on: .main, in: .common
    )
    @State private var timerCancellable: Cancellable?
    
    @State private var durationStringState: String = ""
    
    private var durationString: String {
        return if let duration = recording.duration {
            duration.durationString
        } else {
            "???"
        }
    }
    
    private var startString: String {
        DateFormatter.Recordings.string(from: recording.start)
    }
    
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 5) {
                Text("Started: " + startString)
                Text("Duration: " + durationStringState)
                    .padding([.bottom], 5)
                Text("Measurements:")
                ForEach(Array(recording.sortedMeasurementTypes).sorted(by: { lhs, rhs in
                    lhs.name < rhs.name
                }), id: \.self) { measurementType in
                    Text(measurementType.name)
                        .padding(.leading)
                        .foregroundColor(.accentColor)
                }
            }
        }
        .onAppear {
            durationStringState = durationString
            updateTimer()
        }
        .onChange(of: recording.state) {
            updateTimer()
        }
        .onReceive(timerPublisher) { _ in
            durationStringState = durationString
        }
    }

    private func updateTimer() {
        timerCancellable?.cancel()
        if recording.state == .inProgress {
            timerCancellable = timerPublisher.connect()
        }
    }
}

struct RecordingListRowView_Previews: PreviewProvider {
    static var previews: some View {
        RecordingPreview(recording: Recording(
            entries: [
                Recording.Entry(
                    measurementType: .acceleration,
                    date: Date(),
                    axes: TriangleAxes()
                )
            ],
            state: .completed,
            measurementTypes: [
                .acceleration,
                .userAcceleration,
                .rotationRate
            ]
        ))
        .previewLayout(.sizeThatFits)
        
        RecordingPreview(recording: Recording(
            entries: [
                Recording.Entry(
                    measurementType: .acceleration,
                    date: Date() - 5 - 5 * 60 - 60 * 60,
                    axes: TriangleAxes()
                ),
                Recording.Entry(
                    measurementType: .acceleration,
                    date: Date(),
                    axes: TriangleAxes()
                )
            ],
            state: .completed,
            measurementTypes: [
                .acceleration,
                .userAcceleration,
                .rotationRate
            ]
        ))
        .previewLayout(.sizeThatFits)
        
        RecordingPreview(recording: Recording(
            entries: [
                Recording.Entry(
                    measurementType: .acceleration,
                    date: Date() - 5 - 5 * 60 - 10 * 360,
                    axes: TriangleAxes()
                ),
                Recording.Entry(
                    measurementType: .acceleration,
                    date: Date(),
                    axes: TriangleAxes()
                )
            ],
            state: .completed,
            measurementTypes: [
                .acceleration,
                .userAcceleration,
                .rotationRate
            ]
        ))
        .previewLayout(.sizeThatFits)
        
        RecordingPreview(recording: Recording(
            entries: [
                Recording.Entry(
                    measurementType: .acceleration,
                    date: Date() - 5,
                    axes: TriangleAxes()
                ),
                Recording.Entry(
                    measurementType: .acceleration,
                    date: Date(),
                    axes: TriangleAxes()
                )
            ],
            state: .completed,
            measurementTypes: [
                .acceleration,
                .userAcceleration,
                .rotationRate
            ]
        ))
        .previewLayout(.sizeThatFits)
        
        RecordingPreview(recording: Recording(
            entries: [
                Recording.Entry(
                    measurementType: .acceleration,
                    date: Date() - 5 * 60 - 5,
                    axes: TriangleAxes()
                ),
                Recording.Entry(
                    measurementType: .acceleration,
                    date: Date(),
                    axes: TriangleAxes()
                )
            ],
            state: .completed,
            measurementTypes: [
                .acceleration,
                .userAcceleration,
                .rotationRate
            ]
        ))
        .previewLayout(.sizeThatFits)
        
        RecordingPreview(recording: Recording(
            entries: [
                Recording.Entry(
                    measurementType: .acceleration,
                    date: Date() - 5 * 60 * 60 - 5 * 60 - 5,
                    axes: TriangleAxes()
                ),
                Recording.Entry(
                    measurementType: .acceleration,
                    date: Date(),
                    axes: TriangleAxes()
                )
            ],
            state: .completed,
            measurementTypes: [
                .acceleration,
                .userAcceleration,
                .rotationRate
            ]
        ))
        .previewLayout(.sizeThatFits)
        
        RecordingPreview(recording: Recording(
            entries: [
                Recording.Entry(
                    measurementType: .acceleration,
                    date: Date() - 50000 * 60 * 60 - 5 * 60 - 5,
                    axes: TriangleAxes()
                ),
                Recording.Entry(
                    measurementType: .acceleration,
                    date: Date(),
                    axes: TriangleAxes()
                )
            ],
            state: .completed,
            measurementTypes: [
                .acceleration,
                .userAcceleration,
                .rotationRate
            ]
        ))
        .previewLayout(.sizeThatFits)
    }
}
