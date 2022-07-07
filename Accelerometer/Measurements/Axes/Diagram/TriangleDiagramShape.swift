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
    
    func pointX(width: Double, height: Double) -> CGPoint {
        let zeroX = width / 2.0
        let zeroY = height / 2.0
        
        guard let axes = axes else {
            return CGPoint(x: zeroX, y: zeroY)
        }
        
        let maxX = width / 2.0
        let hypotenuse = maxXValue(maxX: maxX) * (showMax ? 1.0 : (min(abs(axes.x), axes.displayableAbsMax) / axes.displayableAbsMax))
        
        return CGPoint(
            x: zeroX - (hypotenuse * sin(60.0 * Double.pi / 180)),
            y: zeroY + (hypotenuse * sin(30.0 * Double.pi / 180))
        )
    }
    
    func pointY(width: Double, height: Double) -> CGPoint {
        let zeroX = width / 2.0
        let zeroY = height / 2.0
        
        guard let axes = axes else {
            return CGPoint(x: zeroX, y: zeroY)
        }
        
        let maxY = height / 2.0
        
        return CGPoint(
            x: zeroX,
            y: zeroY - (showMax ? 1.0 : (min(abs(axes.y), axes.displayableAbsMax) / axes.displayableAbsMax)) * maxY
        )
    }
    
    func pointZ(width: Double, height: Double) -> CGPoint {
        let zeroX = width / 2.0
        let zeroY = height / 2.0
        
        guard let axes = axes else {
            return CGPoint(x: zeroX, y: zeroY)
        }
        
        let maxX = width / 2.0
        let hypotenuse = maxXValue(maxX: maxX) * (showMax ? 1.0 : (min(abs(axes.z), axes.displayableAbsMax) / axes.displayableAbsMax))
        
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
            let width: CGFloat = min(rect.width, rect.height)
            //            let width: CGFloat = rect.width
            let height = width
            //            let height = rect.height
            
            let xPoint = pointX(width: width, height: height)
            let yPoint = pointY(width: width, height: height)
            let zPoint = pointZ(width: width, height: height)
            
            path.move(to: xPoint)
            path.addLine(to: yPoint)
            path.addLine(to: zPoint)
            path.addLine(to: xPoint)
        }
    }
}
