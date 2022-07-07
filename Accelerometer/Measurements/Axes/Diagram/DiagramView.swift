//
//  DiagramView.swift
//  Accelerometer
//
//  Created by Andrey on 22.06.2022.
//

import SwiftUI

struct DiagramView: View {
    
    var axes: Binding<Axes?>
    
    var body: some View {
        ZStack {
            triangle(max: true)
            triangle()
        }
    }
    
    func triangle(max: Bool = false) -> some View {
        TriangleDiagramShape(
            axes: axes.wrappedValue?.properties,
            showMax: max
        )
        .modify {
            if max {
                $0.fill(Color.accentColor.opacity(0.3))
            } else {
                $0.fill(Color.accentColor)
            }
        }
        .animation(.linear)
    }
}

struct DiagramView_Previews: PreviewProvider {
    static var previews: some View {
        DiagramView(axes: .init(get: {
            let axes = Axes(displayableAbsMax: 1.0)
            axes.properties.setValues(x: 5, y: 6, z: 4)
            return axes
        }, set: { _ in
            
        }))
    }
}
