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
    
    private func setAll(_ selected: Bool) {
        measurementTypes.keys.forEach { measurementTypes[$0] = selected }
    }
    
    private var allSelected: Bool {
        !measurementTypes.values.contains(false)
    }
    
    private var noneSelected: Bool {
        !measurementTypes.values.contains(true)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                
                HStack {
                    Spacer()
                    Button(allSelected ? "Unselect All" : "Select All") {
                        setAll(!allSelected)
                    }
                    .buttonStyle(.bordered)
                    .tint(.accentColor)
                }
                .padding(.horizontal)
                
                List {
                    ForEach(MeasurementType.allShownCases, id: \.self) { type in
                        Toggle(type.name, isOn: Binding(
                            get: { measurementTypes[type] ?? false },
                            set: { measurementTypes[type] = $0 }
                        ))
                        .tint(.accentColor)
                    }
                }
                .listStyle(.insetGrouped)
                
                Button {
                    startRecording()
                } label: {
                    Text("Start Recording")
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(noneSelected)
                .padding(.horizontal)
            }
            .navigationTitle("New Recording")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
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
