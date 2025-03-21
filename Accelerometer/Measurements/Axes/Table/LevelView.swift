//
//  LevelView.swift
//  Accelerometer
//
//  Created by Andrey on 21.06.2022.
//

import SwiftUI

struct LevelView: View {
    
    var name: String
    var value: Double?
    var max: Double?
    var min: Double?
    
    var showTitles = false
    
    var body: some View {
        HStack {
            if showTitles {
                Text(name)
                    .foregroundColor(.secondary)
                Spacer()
            }
            Text((min ?? 0.0).displayableString)
            Spacer()
            Text((value ?? 0.0).displayableString)
            Spacer()
            Text((max ?? 0.0).displayableString)
        }
    }
}

private extension Double {
    
    var displayableString: String {
        var roundedValueString = String(self, roundPlaces: Settings.measurementsDisplayRoundPlaces)
        if self > 0.0 {
            roundedValueString = " " + roundedValueString
        }
        return roundedValueString
    }
}

struct LevelView_Previews: PreviewProvider {
    
    static func levelView(name: String, _ min: Double, _ value: Double, _ max: Double) -> some View {
        LevelView(
            name: name,
            value: min,
            max: value,
            min: max
        )
        .previewLayout(.sizeThatFits)
    }
    
    static var previews: some View {
        VStack {
            levelView(name: "x", 0.687, 0.5, 1.0329)
            levelView(name: "y", 0.79, -0.5789, 1.686)
            levelView(name: "z", 321.0, 0.5, -1.0)
        }
        .previewLayout(.sizeThatFits)
    }
}
