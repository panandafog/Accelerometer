//
//  Color.swift
//  Accelerometer
//
//  Created by Andrey on 22.06.2022.
//

import SwiftUI

extension Color {
    
    static let highlightedBackground = Color("HighlightedBackgroundColor")
    
    #if os(macOS)
    static let background = Color(NSColor.windowBackgroundColor)
    static let secondaryBackground = Color(NSColor.underPageBackgroundColor)
    static let tertiaryBackground = Color(NSColor.controlBackgroundColor)
    #else
    static let background = Color(UIColor.systemBackground)
    static let secondaryBackground = Color(UIColor.secondarySystemBackground)
    static let tertiaryBackground = Color(UIColor.tertiarySystemBackground)
    #endif
    
    /// - Parameters:
    ///     - intensity: should be in 0.0 ... 1.0
    static func intensity(_ intensity: Double, opacity: Double = 1.0) -> Color {
        let intensity = min(1.0, abs(intensity))
        let hue = 11.0 / 360.0
        let saturation = 0.61
        let brightness = 0.9
        
        return Color(hue: hue, saturation: saturation * intensity, brightness: brightness, opacity: opacity)
    }
}

struct Color_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            Color.intensity(0.0)
                .previewLayout(.fixed(width: 100, height: 100))
            Color.intensity(0.5)
                .previewLayout(.fixed(width: 100, height: 100))
            Color.intensity(1.0)
                .previewLayout(.fixed(width: 100, height: 100))
            Color.intensity(1.5)
                .previewLayout(.fixed(width: 100, height: 100))
        }
    }
}
