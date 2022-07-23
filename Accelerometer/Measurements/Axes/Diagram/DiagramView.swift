//
//  DiagramView.swift
//  Accelerometer
//
//  Created by Andrey on 22.06.2022.
//

import SwiftUI

struct DiagramView: View {
    
    var axes: Binding<Axes?>
    var style: DiagramViewStyle = .default
    
    private let axesNamesSizeLimit: CGFloat = 120
    private let axesNamesOffsetMultiplier = 0.1
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                triangle(max: true)
                triangle(showAxesNames: shouldShowAxesNames(shapeSize: geometry.size))
            }
        }
    }
    
    func triangle(max: Bool = false, showAxesNames: Bool = false) -> some View {
        guard showAxesNames else {
            return AnyView(triangleShape(max: max))
        }
        
        return AnyView(ZStack {
            triangleShape(max: max)
            axeName(axe: .x)
            axeName(axe: .y)
            axeName(axe: .z)
        })
    }
    
    func axeName(axe: Axe) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: axe.alignment) {
                Color.clear
                let offsetSize = axe.offset(size: geometry.size, multiplier: axesNamesOffsetMultiplier)
                Text(axe.rawValue)
                    .offset(x: offsetSize.x, y: offsetSize.y)
                    .foregroundColor(.background)
            }
        }
    }
    
    func triangleShape(max: Bool = false) -> some View {
        TriangleDiagramShape(
            axes: axes.wrappedValue?.properties,
            showMax: max
        )
        .modify {
            if max {
                $0.fill(Color.accentColor.opacity(0.3))
            } else {
                $0.fill(Color.accentColor)
            }
        }
        .animation(.linear)
    }
    
    func shouldShowAxesNames(shapeSize: CGSize) -> Bool {
        if style.axesNames == .auto {
            return min(shapeSize.width, shapeSize.height) >= axesNamesSizeLimit
        } else {
            return style.axesNames == .show
        }
    }
}

struct DiagramView_Previews: PreviewProvider {
    static var previews: some View {
        DiagramView(
            axes: .init(get: {
                let axes = Axes(displayableAbsMax: 1.0)
                axes.properties.setValues(x: 0.4, y: 0.4, z: 0.4)
                return axes
            }, set: { _ in
                
            })
        ).frame(width: 120, height: 120)
    }
}

private extension Axe {
    
    var alignment: Alignment {
        switch self {
        case .x:
            return .top
        case .y:
            return .bottomLeading
        case .z:
            return .bottomTrailing
        }
    }
    
    func offset(size: CGSize, multiplier: CGFloat) -> (x: CGFloat, y: CGFloat) {
        
        switch self {
        case .x:
            return (0, size.height * multiplier)
        case .y:
            return (
                size.width * multiplier,
                -1 * (size.height * multiplier * 0.5)
            )
        case .z:
            return (
                -1 * (size.width * multiplier),
                -1 * (size.height * multiplier * 0.5)
            )
        }
    }
}
