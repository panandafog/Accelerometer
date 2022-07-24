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

private extension Axe {
    
    var alignment: Alignment {
        switch self {
        case .x:
            return .bottomLeading
        case .y:
            return .top
        case .z:
            return .bottomTrailing
        }
    }
    
    func offset(size: CGSize, multiplier: CGFloat) -> (x: CGFloat, y: CGFloat) {
        
        switch self {
        case .x:
            return (
                size.width * multiplier,
                -1 * (size.height * multiplier * 0.5)
            )
        case .y:
            return (0, size.height * multiplier)
        case .z:
            return (
                -1 * (size.width * multiplier),
                 -1 * (size.height * multiplier * 0.5)
            )
        }
    }
}

struct DiagramView_Previews: PreviewProvider {
    
    static let axesBinding1: Binding<Axes?> = {
        .init(
            get: {
                let axes = Axes(displayableAbsMax: 1.0)
                axes.properties.setValues(x: 0.4, y: 0.4, z: 0.4)
                return axes
            },
            set: { _ in }
        )
    }()
    
    static let axesBinding2: Binding<Axes?> = {
        .init(
            get: {
                let axes = Axes(displayableAbsMax: 1.0)
                axes.properties.setValues(x: 0.2, y: 0.5, z: 0.7)
                return axes
            },
            set: { _ in }
        )
    }()
    
    static var previews: some View {
        Group {
            DiagramView(axes: axesBinding1)
                .previewLayout(.fixed(width: 120, height: 120))
            DiagramView(axes: axesBinding2)
                .previewLayout(.fixed(width: 120, height: 120))
            DiagramView(axes: axesBinding1)
                .previewLayout(.fixed(width: 80, height: 80))
        }
    }
}
