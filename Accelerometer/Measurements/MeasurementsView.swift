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
        List {
            Section(header: Spacer()) {
                VStack(alignment: .leading) {
                    Text("Rotation:")
                        .font(.headline)
                        .padding()
                    DiagramView(axes: $measurer.rotation)
                        .padding([.bottom])
                }
            }
            Section {
                VStack(alignment: .leading) {
                    Text("Acceleration:")
                        .font(.headline)
                        .padding()
                    DiagramView(axes: $measurer.acceleration)
                }
            }
        }
    }
}

struct MeasurementsView_Previews: PreviewProvider {
    static var previews: some View {
        MeasurementsView()
    }
}
