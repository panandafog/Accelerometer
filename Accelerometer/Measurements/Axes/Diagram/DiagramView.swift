//
//  DiagramView.swift
//  Accelerometer
//
//  Created by Andrey on 22.06.2022.
//

import SwiftUI

struct DiagramView: View {
    
    var axes: Binding<ObservableAxes?>
    var style: DiagramViewStyle = .default
    
    private let axesNamesSizeLimit: CGFloat = 120
    private let axesNamesOffsetMultiplier = 0.1
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                triangle(max: true)
                triangle(showAxesNames: shouldShowAxesNames(shapeSize: geometry.size))
                    .animation(
                        .linear(duration: Settings.shared.updateInterval),
                        value: axes.wrappedValue?.axes as? TriangleAxes
                    )
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
    
    func axeName(axe: AxeType) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: axe.alignment ?? .center) {
                Color.clear
                let offsetSize = axe.offset(
                    size: geometry.size,
                    multiplier: axesNamesOffsetMultiplier
                ) ?? (x: 0.0, y: 0.0)
                Text(axe.rawValue)
                    .offset(x: offsetSize.x, y: offsetSize.y)
                    .foregroundColor(.white)
            }
        }
    }
    
    func triangleShape(max: Bool = false) -> some View {
        TriangleDiagramShape(
            axes: axes.wrappedValue?.axes as? TriangleAxes,
            showMax: max
        )
        .modify {
            if max {
                $0.fill(Color.accentColor.opacity(0.3))
            } else {
                $0.fill(Color.accentColor)
            }
        }
    }
    
    func shouldShowAxesNames(shapeSize: CGSize) -> Bool {
        if style.axesNames == .auto {
            return min(shapeSize.width, shapeSize.height) >= axesNamesSizeLimit
        } else {
            return style.axesNames == .show
        }
    }
}

private extension AxeType {
    
    var alignment: Alignment? {
        switch self {
        case .x:
            return .bottomLeading
        case .y:
            return .top
        case .z:
            return .bottomTrailing
        case .vector:
            return nil
        case .unnamed:
            return nil
        case .roll:
            return nil
        case .pitch:
            return nil
        case .yaw:
            return nil
        case .bool:
            return nil
        }
    }
    
    func offset(size: CGSize, multiplier: CGFloat) -> (x: CGFloat, y: CGFloat)? {
        
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
        case .vector:
            return nil
        case .unnamed:
            return nil
        case .roll:
            return nil
        case .pitch:
            return nil
        case .yaw:
            return nil
        case .bool:
            return nil
        }
    }
}

struct DiagramView_Previews: PreviewProvider {
    
    static let axesBinding1: Binding<ObservableAxes?> = {
        .init(
            get: {
                var axes = TriangleAxes(
                    measurementType: .acceleration,
                    displayableAbsMax: 1.0
                )
                axes.set(values: [
                    .x: 0.4,
                    .y: 0.4,
                    .z: 0.4
                ])
                return ObservableAxes(axes: axes)
            },
            set: { _ in }
        )
    }()
    
    static let axesBinding2: Binding<ObservableAxes?> = {
        .init(
            get: {
                var axes = TriangleAxes(
                    measurementType: .acceleration,
                    displayableAbsMax: 1.0
                )
                axes.set(values: [
                    .x: 0.2,
                    .y: 0.5,
                    .z: 0.7
                ])
                return ObservableAxes(axes: axes)
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
            DiagramView(axes: axesBinding2)
                .preferredColorScheme(.dark)
                .previewLayout(.fixed(width: 120, height: 120))
            DiagramView(axes: axesBinding1)
                .previewLayout(.fixed(width: 80, height: 80))
        }
    }
}
