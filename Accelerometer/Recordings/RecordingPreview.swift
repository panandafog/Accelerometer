//
//  RecordingPreview.swift
//  Accelerometer
//
//  Created by Andrey on 01.08.2022.
//

import SwiftUI

struct RecordingPreview: View {
    
    let recording: Recording
    
    var startString: String {
        let startString: String
        if let start = recording.start {
            startString = DateFormatter.Recordings.string(from: start)
        } else {
            startString = "???"
        }
        return startString
    }
    
    var durationString: String {
        let durationString: String
        if let duration = recording.duration {
            durationString = duration.durationString
        } else {
            durationString = "???"
        }
        return durationString
    }
    
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 5) {
                Text("Started: " + startString)
                Text("Duration: " + durationString)
                    .padding([.bottom], 5)
                Text("Measurements:")
                ForEach(Array(recording.measurementTypes).sorted(by: { lhs, rhs in
                    lhs.name < rhs.name
                }), id: \.self) { measurementType in
                    Text(measurementType.name)
                        .padding(.leading)
                        .foregroundColor(.accentColor)
                }
            }
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
                    value: nil
                )
            ],
            state: .completed,
            measurementTypes: [
                .acceleration,
                .deviceMotion,
                .rotation
            ]
        ))
        .previewLayout(.sizeThatFits)
        RecordingPreview(recording: Recording(
            entries: [
                Recording.Entry(
                    measurementType: .acceleration,
                    date: Date() - 5 - 5 * 60 - 60 * 60,
                    value: nil
                ),
                Recording.Entry(
                    measurementType: .acceleration,
                    date: Date(),
                    value: nil
                )
            ],
            state: .completed,
            measurementTypes: [
                .acceleration,
                .deviceMotion,
                .rotation
            ]
        ))
        .previewLayout(.sizeThatFits)
        RecordingPreview(recording: Recording(
            entries: [
                Recording.Entry(
                    measurementType: .acceleration,
                    date: Date() - 5 - 5 * 60 - 10 * 360,
                    value: nil
                ),
                Recording.Entry(
                    measurementType: .acceleration,
                    date: Date(),
                    value: nil
                )
            ],
            state: .completed,
            measurementTypes: [
                .acceleration,
                .deviceMotion,
                .rotation
            ]
        ))
        .previewLayout(.sizeThatFits)
        RecordingPreview(recording: Recording(
            entries: [
                Recording.Entry(
                    measurementType: .acceleration,
                    date: Date() - 5,
                    value: nil
                ),
                Recording.Entry(
                    measurementType: .acceleration,
                    date: Date(),
                    value: nil
                )
            ],
            state: .completed,
            measurementTypes: [.acceleration]
        ))
        .previewLayout(.sizeThatFits)
        RecordingPreview(recording: Recording(
            entries: [
                Recording.Entry(
                    measurementType: .acceleration,
                    date: Date() - 5 * 60 - 5,
                    value: nil
                ),
                Recording.Entry(
                    measurementType: .acceleration,
                    date: Date(),
                    value: nil
                )
            ],
            state: .completed,
            measurementTypes: [.acceleration]
        ))
        .previewLayout(.sizeThatFits)
        RecordingPreview(recording: Recording(
            entries: [
                Recording.Entry(
                    measurementType: .acceleration,
                    date: Date() - 5 * 60 * 60 - 5 * 60 - 5,
                    value: nil
                ),
                Recording.Entry(
                    measurementType: .acceleration,
                    date: Date(),
                    value: nil
                )
            ],
            state: .completed,
            measurementTypes: [.acceleration]
        ))
        .previewLayout(.sizeThatFits)
        RecordingPreview(recording: Recording(
            entries: [
                Recording.Entry(
                    measurementType: .acceleration,
                    date: Date() - 50000 * 60 * 60 - 5 * 60 - 5,
                    value: nil
                ),
                Recording.Entry(
                    measurementType: .acceleration,
                    date: Date(),
                    value: nil
                )
            ],
            state: .completed,
            measurementTypes: [.acceleration]
        ))
        .previewLayout(.sizeThatFits)
    }
}
