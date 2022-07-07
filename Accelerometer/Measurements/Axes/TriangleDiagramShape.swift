//
//  TriangleDiagramShape.swift
//  Accelerometer
//
//  Created by Andrey on 23.06.2022.
//

import SwiftUI

struct TriangleDiagramShape: Shape {
    
    var axes: Axes.AnimatableProperties?
    let showMax: Bool
    
    var animatableData: Axes.AnimatableProperties {
        get {
            axes ?? .zero
        }
        set {
            axes = newValue
        }
    }
    
    func pointX(viewWidth: Double, viewHeight: Double) -> CGPoint {
        let zeroX = viewWidth / 2.0
        let zeroY = viewHeight / 2.0
        
        guard let axes = axes else {
            return CGPoint(x: zeroX, y: zeroY)
        }
        
        let maxX = viewWidth / 2.0
        let hypotenuse = maxXValue(maxX: maxX) * (showMax ? 1.0 : (abs(axes.x) / axes.displayableAbsMax))
        
        return CGPoint(
            x: zeroX - (hypotenuse * sin(60.0 * Double.pi / 180)),
            y: zeroY + (hypotenuse * sin(30.0 * Double.pi / 180))
        )
    }
    
    func pointY(viewWidth: Double, viewHeight: Double) -> CGPoint {
        let zeroX = viewWidth / 2.0
        let zeroY = viewHeight / 2.0
        
        guard let axes = axes else {
            return CGPoint(x: zeroX, y: zeroY)
        }
        
        let maxY = viewHeight / 2.0
        
        return CGPoint(
            x: zeroX,
            y: zeroY - (showMax ? 1.0 : (abs(axes.y) / axes.displayableAbsMax)) * maxY
        )
    }
    
    func pointZ(viewWidth: Double, viewHeight: Double) -> CGPoint {
        let zeroX = viewWidth / 2.0
        let zeroY = viewHeight / 2.0
        
        guard let axes = axes else {
            return CGPoint(x: zeroX, y: zeroY)
        }
        
        let maxX = viewWidth / 2.0
        let hypotenuse = maxXValue(maxX: maxX) * (showMax ? 1.0 : (abs(axes.z) / axes.displayableAbsMax))
        
        return CGPoint(
            x: zeroX + (hypotenuse * sin(60.0 * Double.pi / 180)),
            y: zeroY + (hypotenuse * sin(30.0 * Double.pi / 180))
        )
    }
    
    
    func maxXValue(maxX: Double) -> Double {
        maxX / sin(60.0 * Double.pi / 180)
    }
    
    func path(in rect: CGRect) -> Path {
        Path { path in
//            let width: CGFloat = min(rect.width, rect.height)
//            let height = width
            
            let xPoint = pointX(viewWidth: rect.width, viewHeight: rect.height)
            let yPoint = pointY(viewWidth: rect.width, viewHeight: rect.height)
            let zPoint = pointZ(viewWidth: rect.width, viewHeight: rect.height)
            
            path.move(to: xPoint)
            path.addLine(to: yPoint)
            path.addLine(to: zPoint)
            path.addLine(to: xPoint)
        }
    }
}
