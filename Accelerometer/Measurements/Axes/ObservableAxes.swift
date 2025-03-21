//
//  ObservableAxes.swift
//  Accelerometer
//
//  Created by Andrey on 04.07.2022.
//

import SwiftUI

final class ObservableAxes: ObservableObject {
    @Published var axes: any Axes
    
    init(axes newAxes: any Axes) {
        axes = newAxes
    }
    
    func reset() {
        if let newAxes = axes.resetValues() as? (any Axes) {
            axes = newAxes
        }
    }
}
