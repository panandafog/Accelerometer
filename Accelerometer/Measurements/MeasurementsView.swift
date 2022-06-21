//
//  MeasurementsView.swift
//  Accelerometer
//
//  Created by Andrey on 21.06.2022.
//

import SwiftUI

struct MeasurementsView: View {
    @ObservedObject var measurer = Measurer.shared
    
    var body: some View {
        HStack {
            Spacer()
            VStack {
                Spacer()
                Text("Rotation:")
                    .font(.headline)
                    .padding()
                DiagramView(axes: $measurer.rotation)
                    .padding([.bottom])
                Text("Acceleration:")
                    .font(.headline)
                    .padding()
                DiagramView(axes: $measurer.acceleration)
                Spacer()
            }
            Spacer()
        }
    }
}

struct MeasurementsView_Previews: PreviewProvider {
    static var previews: some View {
        MeasurementsView()
    }
}
