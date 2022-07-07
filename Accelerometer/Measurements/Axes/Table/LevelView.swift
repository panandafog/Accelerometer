//
//  LevelView.swift
//  Accelerometer
//
//  Created by Andrey on 21.06.2022.
//

import SwiftUI

struct LevelView: View {
    @Binding var value: Double?
    @Binding var max: Double?
    @Binding var min: Double?
    
    var body: some View {
        HStack {
            Text(String(min ?? 0.0, roundPlaces: Measurer.measurementsDisplayRoundPlaces))
            Spacer()
            Text(String(value ?? 0.0, roundPlaces: Measurer.measurementsDisplayRoundPlaces))
            Spacer()
            Text(String(max ?? 0.0, roundPlaces: Measurer.measurementsDisplayRoundPlaces))
        }
    }
}

struct LevelView_Previews: PreviewProvider {
    static var previews: some View {
        LevelView(
            value: .init(
                get: { 0.5 },
                set: { _ in }
            ),
            max: .init(
                get: { 1.0 },
                set: { _ in }
            ),
            min: .init(
                get: { 0.0 },
                set: { _ in }
            )
        )
    }
}
