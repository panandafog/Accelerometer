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
        var dict: [MeasurementType: Bool] = [:]
        MeasurementType.allShownCases.forEach { dict[$0] = true }
        return dict
    }()
    
    private func startRecording() {
        let enabled = measurementTypes
            .compactMap { $0.value ? $0.key : nil }
        recorder.record(measurements: Set(enabled))
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
                            set: { newValue in
                                withAnimation(.easeInOut) {
                                    measurementTypes[type] = newValue
                                }
                            }
                        ))
                        .tint(.accentColor)
                    }
                }
                .listStyle(.insetGrouped)
                .animation(.easeInOut, value: measurementTypes)
                
                Button("Start Recording") {
                    startRecording()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .tint(noneSelected ? .gray : .accentColor)
                .disabled(noneSelected)
                .padding(.horizontal)
                .animation(.easeInOut, value: noneSelected)
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
