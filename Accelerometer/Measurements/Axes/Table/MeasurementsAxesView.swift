//
//  MeasurementsAxesView.swift
//  Accelerometer
//
//  Created by Andrey on 21.06.2022.
//

import SwiftUI

struct MeasurementsAxesView: View {
    @Binding var axes: ObservableAxes?
    
    var triangleAxes: TriangleAxes? {
        axes?.axes as? TriangleAxes
    }
    
    var showSummary = true
    
    var rows: [RowData] {
        var rows = [
            RowData(
                name: "x",
                min: triangleAxes?.values[.x]?.min,
                value: triangleAxes?.values[.x]?.value,
                max: triangleAxes?.values[.x]?.max
            ),
            RowData(
                name: "y",
                min: triangleAxes?.values[.y]?.min,
                value: triangleAxes?.values[.y]?.value,
                max: triangleAxes?.values[.y]?.max
            ),
            RowData(
                name: "z",
                min: triangleAxes?.values[.z]?.min,
                value: triangleAxes?.values[.z]?.value,
                max: triangleAxes?.values[.z]?.max
            )
        ]
        if showSummary {
            rows.append(
                RowData(
                    name: "summary",
                    min: triangleAxes?.values[.z]?.min,
                    value: triangleAxes?.values[.z]?.value,
                    max: triangleAxes?.values[.z]?.max
                )
            )
        }
        return rows
    }
    
    var body: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading) {
                Text("x")
                    .foregroundColor(.secondary)
                Text("y")
                    .foregroundColor(.secondary)
                Text("z")
                    .foregroundColor(.secondary)
                if showSummary {
                    Text("summary")
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
        MeasurementsAxesView(axes: .init(get: {
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

extension MeasurementsAxesView {
    
    struct RowData: Hashable {
        let name: String
        let min: Double?
        let value: Double?
        let max: Double?
    }
}
