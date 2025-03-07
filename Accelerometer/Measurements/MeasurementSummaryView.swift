//
//  MeasurementSummaryView.swift
//  Accelerometer
//
//  Created by Andrey on 22.06.2022.
//

import SwiftUI

struct MeasurementSummaryView: View {
    @EnvironmentObject var measurer: Measurer
    @EnvironmentObject var recorder: Recorder
    
    let type: MeasurementType
    
    var axesBinding: Binding<ObservableAxes?> {
        Binding<ObservableAxes?>.init(
            get: {
                measurer.observableAxes[type]
            },
            set: { _ in }
        )
    }
    
    var recordButton: some View {
        let enabled = !recorder.recordingInProgress
        let text = enabled ? "Start recording this value" : "Recording is already enabled"
        let backgroundColor: Color = enabled ? .enabledButton : .disabledButton
        
        return Button(
            action: {
                recorder.record(measurements: [type])
            }, label: {
                Text(text)
                    .foregroundColor(.background)
            }
        )
        .disabled(!enabled)
        .padding(.defaultPadding)
        .background(backgroundColor)
        .cornerRadius(.defaultCornerRadius)
    }
    
    var body: some View {
        GeometryReader { geometryVStack in
            VStack {
                Text(type.description)
                    .padding()
                    .padding([.horizontal])
                
                if axesBinding.wrappedValue?.axes.measurementType?
                    .supportsDiagramRepresentation ?? false {
                    
                    HStack (spacing: geometryVStack.size.width * 0.1) {
                        let diagramSize = geometryVStack.size.width * 0.3
                        
                        AxesSummaryViewExtended(type: type)
                            .frame(width: diagramSize, height: diagramSize)
                        DiagramView(axes: axesBinding)
                            .frame(width: diagramSize, height: diagramSize)
                            .padding()
                    }
                }
                
                AxesTableView(observableAxes: axesBinding)
                    .padding()
                Spacer()
                recordButton
                    .padding()
                    .padding(.vertical)
            }
            .navigationTitle(type.name.capitalizingFirstLetter())
        }
        .toolbar {
            Button("Reset min / max") {
                measurer.reset(type)
            }
        }
    }
}

struct MeasurementSummaryView_Previews: PreviewProvider {
    
    static let settings = Settings()
    
    static let measurer: Measurer = {
        let measurer = Measurer(settings: settings)
        measurer.saveData(
            axesType: TriangleAxes.self,
            measurementType: .acceleration,
            values: [
                .x: 0.5,
                .y: 0.5,
                .z: 0.5
            ]
        )
        return measurer
    }()
    
    static let recorder1: Recorder = {
        let recorder = Recorder(measurer: measurer)
        return recorder
    }()
    
    static let recorder2: Recorder = {
        let recorder = Recorder(measurer: measurer)
        recorder.record(measurements: [.acceleration])
        return recorder
    }()
    
    static var previews: some View {
        MeasurementSummaryView(type: .acceleration)
            .environmentObject(settings)
            .environmentObject(measurer)
            .environmentObject(recorder1)
        MeasurementSummaryView(type: .acceleration)
            .environmentObject(settings)
            .environmentObject(measurer)
            .environmentObject(recorder2)
    }
}
