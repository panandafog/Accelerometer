//
//  DiagramViewStyle.swift
//  Accelerometer
//
//  Created by Andrey on 11.07.2022.
//

struct DiagramViewStyle {
    
    static let `default`: Self = .init(
        axesNames: .auto
    )
    
    let axesNames: DiagramAxesNamesStyle
}
