//
//  NewRecordingView.swift
//  Accelerometer
//
//  Created by Andrey on 30.07.2022.
//

import SwiftUI

struct NewRecordingView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @EnvironmentObject var recorder: Recorder
    
    @State var measurementTypes: [MeasurementType: Bool] = {
        var dictionary: [MeasurementType: Bool] = [:]
        MeasurementType.allShownCases.forEach {
            dictionary[$0] = true
        }
        return dictionary
    }()
    
    func setAllMeasurementTypes(selected: Bool) {
        for key in Array(measurementTypes.keys) {
            measurementTypes[key] = selected
        }
    }
    
    func allMeasurementTypesAre(selected: Bool) -> Bool {
        !Array(measurementTypes.values).contains {
            $0 == !selected
        }
    }
    
    var allMeasurementAreSelected: Bool {
        allMeasurementTypesAre(selected: true)
    }
    
    var allMeasurementAreUnselected: Bool {
        allMeasurementTypesAre(selected: false)
    }
    
    func startRecording() {
        let enabledMeasurementTypes: Set<MeasurementType> = Set(measurementTypes.compactMap {
            $0.value ? $0.key : nil
        })
        recorder.record(measurements: enabledMeasurementTypes)
        presentationMode.wrappedValue.dismiss()
    }
    
    var startRecordingButton: some View {
        let startAllowed = !allMeasurementAreUnselected
        let text = startAllowed ? "Start recording" : "Select measurements to start recording"
        let backgroundColor: Color = startAllowed ? .enabledButton : .disabledButton
        
        return Button(
            action: {
                startRecording()
            }
        ) {
            Text(text)
                .foregroundColor(.background)
            
        }
        .disabled(!startAllowed)
        .padding(.defaultPadding)
        .background(backgroundColor)
        .cornerRadius(CGFloat.defaultCornerRadius)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        if allMeasurementAreSelected {
                            setAllMeasurementTypes(selected: false)
                        } else {
                            setAllMeasurementTypes(selected: true)
                        }
                    }, label: {
                        Text(allMeasurementAreSelected ? "Unselect all" : "Select all")
                            .padding()
                    })
                }
                List {
                    ForEach(MeasurementType.allShownCases, id: \.self) { measurementType in
                        HStack {
                            Toggle(isOn: .init(
                                get: {
                                    measurementTypes[measurementType] ?? false
                                },
                                set: { newValue in
                                    measurementTypes[measurementType] = newValue
                                }
                            )) {
                                Text(measurementType.name)
                            }
                        }
                    }
                }
                .listStyle(.inset)
                startRecordingButton
                    .padding()
            }
            .navigationTitle("New recording")
            .toolbar {
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
}

struct NewRecordingView_Previews: PreviewProvider {
    
    static var previews: some View {
        NewRecordingView()
        NewRecordingView()
            .preferredColorScheme(.dark)
    }
}
