//
//  MeasurementsAxesView.swift
//  Accelerometer
//
//  Created by Andrey on 21.06.2022.
//

import SwiftUI

struct MeasurementsAxesView: View {
    @Binding var axes: ObservableAxes<TriangleAxes>?
    
    var showSummary = true
    
    var rows: [RowData] {
        var rows = [
            RowData(
                name: "x",
                min: axes?.properties.axes[.x]?.min,
                value: axes?.properties.axes[.x]?.value,
                max: axes?.properties.axes[.x]?.max
            ),
            RowData(
                name: "y",
                min: axes?.properties.axes[.y]?.min,
                value: axes?.properties.axes[.y]?.value,
                max: axes?.properties.axes[.y]?.max
            ),
            RowData(
                name: "z",
                min: axes?.properties.axes[.z]?.min,
                value: axes?.properties.axes[.z]?.value,
                max: axes?.properties.axes[.z]?.max
            )
        ]
        if showSummary {
            rows.append(
                RowData(
                    name: "summary",
                    min: axes?.properties.vector.min,
                    value: axes?.properties.vector.value,
                    max: axes?.properties.vector.max
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
            let axes = ObservableAxes<TriangleAxes>()
            axes.properties.displayableAbsMax = 1.0
            axes.properties.set(values: [
                .x: 0.5, .y: 0.6, .z: 0.7
            ])
            axes.properties.set(values: [
                .x: 0.2, .y: 0.3, .z: 0.4
            ])
            return axes
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
