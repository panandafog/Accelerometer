//
//  ContentView.swift
//  Accelerometer Watch Watch App
//
//  Created by Andrey Pantyuhin on 06.11.2025.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var recorder: WatchRecorder
    @Environment(\.scenePhase) private var scenePhase
    @State private var path: [WatchRoute] = []

    var body: some View {
        NavigationStack(path: $path) {
            List {
                NavigationLink(value: WatchRoute.measurements) {
                    Label("Measurements", systemImage: "waveform.path.ecg")
                }

                NavigationLink(value: WatchRoute.recordings) {
                    HStack {
                        Label("Recordings", systemImage: "record.circle")

                        Spacer()

                        if recorder.isRecording {
                            Image(systemName: "record.circle.fill")
                                .foregroundStyle(.red)
                        }
                    }
                }
            }
            .navigationTitle("Accelerometer")
            .navigationDestination(for: WatchRoute.self) { route in
                switch route {
                case .measurements:
                    WatchMeasurementsView()
                        .navigationTitle("Measurements")
                case let .measurement(type):
                    WatchMeasurementDetailView(type: type)
                case .recordings:
                    WatchRecordingsView()
                }
            }
            .onAppear(perform: consumeWidgetAction)
            .onOpenURL(perform: openWidgetURL)
            .onChange(of: scenePhase) { _, phase in
                if phase == .active {
                    consumeWidgetAction()
                }
            }
        }
    }

    private func openWidgetURL(_ url: URL) {
        guard let rawType = WatchWidgetDeepLink.measurementType(from: url),
              let type = MeasurementType(rawValue: rawType) else {
            return
        }

        path = [.measurement(type)]
    }

    private func consumeWidgetAction() {
        guard let request = WatchWidgetActionRequest.consume() else {
            return
        }

        switch request.route {
        case .measurement:
            guard let rawType = request.measurementType,
                  let type = MeasurementType(rawValue: rawType) else {
                path = [.measurements]
                return
            }
            path = [.measurement(type)]

        case .recordings:
            if request.shouldStartRecording, !recorder.isRecording {
                recorder.start(measurements: Set(MeasurementType.allShownCases))
            }
            path = [.recordings]
        }
    }
}

private enum WatchRoute: Hashable {
    case measurements
    case measurement(MeasurementType)
    case recordings
}

struct ContentView_Previews: PreviewProvider {
    static let settings = Settings()
    static let measurer = Measurer(settings: settings)
    static let recorder = WatchRecorder(measurer: measurer)
    
    static var previews: some View {
        ContentView()
            .environmentObject(settings)
            .environmentObject(measurer)
            .environmentObject(recorder)
            .previewDevice("Apple Watch Series 8 - 45mm")
    }
}
