//
//  RecordingWidgetBundle.swift
//  RecordingWidget
//
//  Created by Andrey on 16.04.2023.
//

import WidgetKit
import SwiftUI

@main
struct RecordingWidgetBundle: WidgetBundle {
    var body: some Widget {
        RecordingWidget()
        RecordingWidgetLiveActivity()
    }
}
