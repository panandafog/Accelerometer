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
    
    static let enabledButton = Color.accentColor
    static let disabledButton = Color.intensity(0.0)
    
    /// - Parameters:
    ///     - intensity: should be in 0.0 ... 1.0
    static func intensity(_ intensity: Double) -> Color {
        let intensity = min(1.0, abs(intensity))
        
        let hue = 10.0 / 360.0
        
        let minSaturation = 0.0
        let maxSaturation = 0.57
        let saturation = minSaturation + (maxSaturation - minSaturation) * intensity
        
        let minBrightness = 0.7
        let maxBrightness = 0.97
        let brightness = minBrightness + (maxBrightness - minBrightness) * intensity
        
        let minOpacity = 0.5
        let maxOpacity = 1.0
        let opacity = minOpacity + (maxOpacity - minOpacity) * intensity
        
        return Color(hue: hue, saturation: saturation, brightness: brightness, opacity: opacity)
    }
}

// FIXME: Fix previews

//struct Color_Previews: PreviewProvider {
//
//    static let axesBinding1: Binding<ObservableAxes?> = {
//        .init(
//            get: {
//                let axes = ObservableAxes(displayableAbsMax: 1.0)
//                axes.properties.setValues(x: 0.4, y: 0.4, z: 0.4)
//                return axes
//            },
//            set: { _ in }
//        )
//    }()
//    
//    static let measurer1: Measurer = {
//        let measurer = Measurer()
//        measurer.deviceMotion = .init(displayableAbsMax: 1.0)
//        measurer.saveData(x: 0, y: 0, z: 0, type: .deviceMotion)
//        return measurer
//    }()
//    
//    static let measurer2: Measurer = {
//        let measurer = Measurer()
//        measurer.deviceMotion = .init(displayableAbsMax: 1.0)
//        measurer.saveData(x: 0.5, y: 0.5, z: 0.5, type: .deviceMotion)
//        return measurer
//    }()
//    
//    static let measurer3: Measurer = {
//        let measurer = Measurer()
//        measurer.deviceMotion = .init(displayableAbsMax: 1.0)
//        measurer.saveData(x: 1, y: 1, z: 1, type: .deviceMotion)
//        return measurer
//    }()
//    
//    static var previews: some View {
//        Group {
//            Color.intensity(0.0)
//                .previewLayout(.fixed(width: 100, height: 100))
//            Color.intensity(0.5)
//                .previewLayout(.fixed(width: 100, height: 100))
//            Color.intensity(1.0)
//                .previewLayout(.fixed(width: 100, height: 100))
//            AxesSummaryView(measurer: measurer1, type: .deviceMotion)
//                .padding()
//                .previewLayout(.sizeThatFits)
//            AxesSummaryView(measurer: measurer2, type: .deviceMotion)
//                .padding()
//                .previewLayout(.sizeThatFits)
//            AxesSummaryView(measurer: measurer3, type: .deviceMotion)
//                .padding()
//                .previewLayout(.sizeThatFits)
//            AxesSummaryView(measurer: measurer1, type: .deviceMotion)
//                .padding()
//                .previewLayout(.sizeThatFits)
//                .preferredColorScheme(.dark)
//            AxesSummaryView(measurer: measurer2, type: .deviceMotion)
//                .padding()
//                .previewLayout(.sizeThatFits)
//                .preferredColorScheme(.dark)
//            AxesSummaryView(measurer: measurer3, type: .deviceMotion)
//                .padding()
//                .previewLayout(.sizeThatFits)
//                .preferredColorScheme(.dark)
//        }
//    }
//}
