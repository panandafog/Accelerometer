//
//  MeasurementsAxesView.swift
//  Accelerometer
//
//  Created by Andrey on 21.06.2022.
//

import SwiftUI

struct MeasurementsAxesView: View {
    @Binding var axes: Axes?
    
    var showSummary = true
    
    var rows: [RowData] {
        var rows = [
            RowData(
                name: "x",
                min: axes?.properties.minX,
                value: axes?.properties.x,
                max: axes?.properties.maxX
            ),
            RowData(
                name: "y",
                min: axes?.properties.minY,
                value: axes?.properties.y,
                max: axes?.properties.maxY
            ),
            RowData(
                name: "z",
                min: axes?.properties.minZ,
                value: axes?.properties.z,
                max: axes?.properties.maxZ
            )
        ]
        if showSummary {
            rows.append(
                RowData(
                    name: "summary",
                    min: axes?.properties.minV,
                    value: axes?.properties.vector,
                    max: axes?.properties.maxV
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
            let axes = Axes(displayableAbsMax: 1.0)
            axes.properties.setValues(x: 0.5, y: 0.6, z: 0.7)
            axes.properties.setValues(x: 0.2, y: 0.3, z: 0.4)
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
