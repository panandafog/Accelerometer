//
//  DiagramView.swift
//  Accelerometer
//
//  Created by Andrey on 21.06.2022.
//

import SwiftUI

struct DiagramView: View {
    @Binding var axes: Measurer.Axes?
    
    var body: some View {
        VStack {
            Text(String(axes?.x ?? 0.0))
            Text(String(axes?.y ?? 0.0))
            Text(String(axes?.z ?? 0.0))
        }
        .padding()
    }
}

struct DiagramView_Previews: PreviewProvider {
    static var previews: some View {
        DiagramView(axes: .init(get: {
            Measurer.Axes(x: 1, y: 2, z: 3)
        }, set: { _ in
            
        }))
    }
}
