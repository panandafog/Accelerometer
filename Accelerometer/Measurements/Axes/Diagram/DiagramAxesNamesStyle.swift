//
//  DiagramAxesNamesStyle.swift
//  Accelerometer
//
//  Created by Andrey on 11.07.2022.
//

enum DiagramAxesNamesStyle {
    case auto
    case show
    case hide
    
    init(show: Bool? = nil) {
        if let show = show {
            self = show ? .show : .hide
        } else {
            self = .auto
        }
    }
}
