//
//  RecordingWidgetLiveActivity.swift
//  RecordingWidget
//
//  Created by Andrey on 16.04.2023.
//

import ActivityKit
import WidgetKit
import SwiftUI

public struct RecordingWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        
//        var value: Int
//
//        public init(value: Int) {
//            self.value = value
//        }
        
        var duration: TimeInterval
        
        public init(duration: TimeInterval = 0) {
            self.duration = duration
        }
        
        public init(start: Date) {
            self.duration = Date().timeIntervalSinceReferenceDate - start.timeIntervalSinceReferenceDate
        }
    }

    // Fixed non-changing properties about your activity go here!
    var measurementTypes: [String]
    var start: Date
    
    public init(measurementTypes: [MeasurementType], start: Date? = nil) {
        self.init(measurementTypes: measurementTypes.map { $0.rawValue })
    }
    
    public init(measurementTypes: [String], start: Date? = nil) {
        self.measurementTypes = measurementTypes
        self.start = start ?? Date()
    }
}

struct RecordingWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: RecordingWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            HStack {
                VStack(alignment: .leading) {
                    Text("Recording").font(.title3)
                        .padding(.bottom, 5)
                    Text(context
                        .attributes
                        .measurementTypes
                        .joined(separator: ", ")
                    )
                    .lineLimit(1)
                }
                .padding(.trailing)
                Spacer()
//                Text(String(Int(Date().timeIntervalSince(context.attributes.start))))
                Text(String(context.state.duration))
            }
            .padding()
//            .activityBackgroundTint(Color.accentColor)
//            .activitySystemActionForegroundColor(Color.)
            .foregroundColor(.gray)
                .activityBackgroundTint(Color.white)
                .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T")
            } minimal: {
                Text("Min")
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

//struct RecordingWidgetLiveActivity_Previews: PreviewProvider {
//    static let attributes = RecordingWidgetAttributes(name: "Me")
//    static let contentState = RecordingWidgetAttributes.ContentState(value: 3)
//
//    static var previews: some View {
//        attributes
//            .previewContext(contentState, viewKind: .dynamicIsland(.compact))
//            .previewDisplayName("Island Compact")
//        attributes
//            .previewContext(contentState, viewKind: .dynamicIsland(.expanded))
//            .previewDisplayName("Island Expanded")
//        attributes
//            .previewContext(contentState, viewKind: .dynamicIsland(.minimal))
//            .previewDisplayName("Minimal")
//        attributes
//            .previewContext(contentState, viewKind: .content)
//            .previewDisplayName("Notification")
//    }
//}
