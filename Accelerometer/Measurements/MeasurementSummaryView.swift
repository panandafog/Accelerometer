//
//  MeasurementSummaryView.swift
//  Accelerometer
//
//  Created by Andrey on 22.06.2022.
//

import SwiftUI

struct MeasurementSummaryView: View {
    @ObservedObject var measurer = Measurer.shared
    @ObservedObject var recorder = Recorder.shared
    
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
                
                HStack (spacing: geometryVStack.size.width * 0.1) {
                    //                    Spacer()
                    let diagramSize = geometryVStack.size.width * 0.3
                    AxesSummaryViewExtended(measurer: measurer, type: type)
                        .frame(width: diagramSize, height: diagramSize)
                    //                    Spacer()
                    DiagramView(axes: axesBinding)
                        .frame(width: diagramSize, height: diagramSize)
                        .padding()
                    //                    .frame(maxWidth: .infinity)
                    //                    Spacer()
                }
                
                AxesTableView(axes: axesBinding, showSummary: false)
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
    
    static let measurer: Measurer = {
        let measurer = Measurer()
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
        let recorder = Recorder()
        return recorder
    }()
    
    static let recorder2: Recorder = {
        let recorder = Recorder()
        recorder.record(measurements: [.acceleration])
        return recorder
    }()
    
    static var previews: some View {
        MeasurementSummaryView(measurer: measurer, recorder: recorder1, type: .acceleration)
        MeasurementSummaryView(measurer: measurer, recorder: recorder2, type: .acceleration)
    }
}
