//
//  NewRecordingWatchView.swift
//  Accelerometer Watch Watch App
//
//  Created by Andrey on 13.08.2023.
//

import SwiftUI

struct NewRecordingWatchView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    //    @ObservedObject var recorder = Recorder.shared
    //
    //    @State var measurementTypes: [MeasurementType: Bool] = {
    //        var dictionary: [MeasurementType: Bool] = [:]
    //        MeasurementType.allCases.forEach {
    //            dictionary[$0] = false
    //        }
    //        return dictionary
    //    }()
    
    @State var measurementTypes: [MeasurementType: Bool] = [:]
    
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
        //        let enabledMeasurementTypes: Set<MeasurementType> = Set(measurementTypes.compactMap {
        //            $0.value ? $0.key : nil
        //        })
        //        recorder.record(measurements: enabledMeasurementTypes)
        //        presentationMode.wrappedValue.dismiss()
    }
    
    var startRecordingButton: some View {
        let startAllowed = !allMeasurementAreUnselected
        let text = startAllowed ? "Start recording" : "Select measurements to start recording"
        //        let backgroundColor: Color = startAllowed ? .enabledButton : .disabledButton
        
        return Button(
            action: {
                startRecording()
            }
        ) {
            Text(text)
            //                .foregroundColor(.background)
            
        }
        .disabled(!startAllowed)
        //        .padding(.defaultPadding)
        //        .background(backgroundColor)
        //        .cornerRadius(CGFloat.defaultCornerRadius)
    }
    
    var body: some View {
        ZStack {
            List {
                ForEach(MeasurementType.allCases, id: \.self) { measurementType in
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
                VStack {
                    Spacer()
                    startRecordingButton
                }
            }
        //        NavigationView {
        //            VStack {
        //                HStack {
        //                    Spacer()
        //                    Button(action: {
        //                        if allMeasurementAreSelected {
        //                            setAllMeasurementTypes(selected: false)
        //                        } else {
        //                            setAllMeasurementTypes(selected: true)
        //                        }
        //                    }, label: {
        //                        Text(allMeasurementAreSelected ? "Unselect all" : "Select all")
        //                            .padding()
        //                    })
        //                }
        //                List {
        //                    ForEach(MeasurementType.allCases, id: \.self) { measurementType in
        //                        HStack {
        //                            Toggle(isOn: .init(
        //                                get: {
        //                                    measurementTypes[measurementType] ?? false
        //                                },
        //                                set: { newValue in
        //                                    measurementTypes[measurementType] = newValue
        //                                }
        //                            )) {
        //                                Text(measurementType.name)
        //                            }
        //                        }
        //                    }
        //                }
        ////                .listStyle(.inset)
        //                startRecordingButton
        //                    .padding()
        //            }
        //            .navigationTitle("New recording")
        //            .toolbar {
        //                Button("Cancel") {
        //                    presentationMode.wrappedValue.dismiss()
        //                }
        //            }
    }
}
}

struct NewRecordingView_Previews: PreviewProvider {
    
    static var previews: some View {
        NewRecordingWatchView()
        NewRecordingWatchView()
            .preferredColorScheme(.dark)
    }
}
