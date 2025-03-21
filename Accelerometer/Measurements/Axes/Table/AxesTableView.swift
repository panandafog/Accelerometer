//
//  AxesTableView.swift
//  Accelerometer
//
//  Created by Andrey on 21.06.2022.
//

import SwiftUI

struct AxesTableView: View {
    @Binding var observableAxes: ObservableAxes?
    
    var axes: (any Axes)? { observableAxes?.axes }
    var magnitudeAxes: (any MagnitudeAxes)? { observableAxes?.axes as? any MagnitudeAxes }
    
    var axesTypes: [AxeType] {
        guard let axes = axes else { return [] }
        return type(of: axes).sortedAxesTypes
    }
    
    var showSummary: Bool { magnitudeAxes != nil }
    
    var rows: [RowData] {
        guard let axes = axes else { return [] }
        
        var rows: [RowData] = axesTypes.map { axeType in
            rowData(axes: axes, axeType: axeType)
        }
        
        if let magnitudeAxes = magnitudeAxes {
            rows.append(summaryData(axes: magnitudeAxes))
        }
        return rows
    }
    
    private func rowData<AxesType: Axes>(axes: AxesType, axeType: AxeType) -> RowData {
        RowData(
            name: axeType.name,
            min: axes.values[axeType]?.min as? Double,
            value: axes.values[axeType]?.value as? Double,
            max: axes.values[axeType]?.max as? Double
        )
    }
    
    private func summaryData<AxesType: MagnitudeAxes>(axes: AxesType) -> RowData {
        RowData(
            name: AxeType.magnitude.name,
            min: axes.magnitude.min as? Double,
            value: axes.magnitude.value as? Double,
            max: axes.magnitude.max as? Double
        )
    }
    
    var body: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading) {
                ForEach(axesTypes, id: \.self) { axeType in
                    Text(axeType.name)
                        .foregroundColor(.secondary)
                }
                if showSummary {
                    Text("magnitude")
                        .foregroundColor(.secondary)
                }
            }.padding([.trailing])
            
            VStack {
                HeaderView()
                    .padding([.bottom])
                VStack {
                    ForEach(rows, id: \.self) { row in
                        LevelView(
                            name: row.name,
                            value: row.value,
                            max: row.max,
                            min: row.min,
                            showTitles: false
                        )
                    }
                }
            }
        }
        .padding()
    }
}

struct MeasurementsAxesView_Previews: PreviewProvider {
    
    static var previews: some View {
        AxesTableView(observableAxes: .init(get: {
            var axes = TriangleAxes(
                measurementType: .acceleration,
                displayableAbsMax: 1.0
            )
            axes.set(values: [
                .x: 0.5,
                .y: 0.6,
                .z: 0.7
            ])
            axes.set(values: [
                .x: 0.2,
                .y: 0.3,
                .z: 0.4
            ])
            return ObservableAxes(axes: axes)
        }, set: { _ in
            
        }))
        .previewLayout(.sizeThatFits)
    }
}

extension AxesTableView {
    
    struct RowData: Hashable {
        let name: String
        let min: Double?
        let value: Double?
        let max: Double?
    }
}
