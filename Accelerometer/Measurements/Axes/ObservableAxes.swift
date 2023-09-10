//
//  ObservableAxes.swift
//  Accelerometer
//
//  Created by Andrey on 04.07.2022.
//

import SwiftUI

final class ObservableAxes<T: Axes>: ObservableObject {
    // TODO: rename properties -> axes
    @Published var properties: T
    
    init(axes: T = .zero) {
        properties = axes
    }
    
    func reset() {
        properties = T.zero
    }
}
