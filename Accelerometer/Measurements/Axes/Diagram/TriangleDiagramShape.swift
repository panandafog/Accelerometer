//
//  TriangleDiagramShape.swift
//  Accelerometer
//
//  Created by Andrey on 23.06.2022.
//

import SwiftUI

struct TriangleDiagramShape: Shape {
    
    var axes: TriangleAxes?
    let showMax: Bool
    
    var animatableData: TriangleAxes {
        get {
            axes ?? .zero
        }
        set {
            axes = newValue
        }
    }
    
    func angle(width: Double, height: Double) -> Double {
        .degrees(
            radians: atan((width * 0.5) / (height * (1.0 / 3.0)))
        )
    }
     
    func pointX(width: Double, height: Double) -> CGPoint {
        let zeroX = width / 2.0
        let zeroY = height / 1.5
        
        var axes = axes
        if axes == nil {
            axes = .zero
            axes?.displayableAbsMax = 1.0
        }
        
        let maxX = width / 2.0
        let angle = angle(width: width, height: height)
        let hypotenuse = maxXValue(maxX: maxX, angle: angle) * 
        (showMax ? 1.0 : (min(abs(axes!.values[.x]?.value ?? 0.0), axes!.displayableAbsMax) / axes!.displayableAbsMax))
        
        return CGPoint(
            x: zeroX - (hypotenuse * sin(Double.radians(degrees: angle))),
            y: zeroY + (hypotenuse * cos(Double.radians(degrees: angle)))
        )
    }
    
    func pointY(width: Double, height: Double) -> CGPoint {
        let zeroX = width / 2.0
        let zeroY = height / 1.5
        
        var axes = axes
        if axes == nil {
            axes = .zero
            axes?.displayableAbsMax = 1.0
        }
        
        let maxY = zeroY
        
        return CGPoint(
            x: zeroX,
            y: zeroY - (showMax ? 1.0 : (min(abs(axes!.values[.y]?.value ?? 0.0), axes!.displayableAbsMax) / axes!.displayableAbsMax)) * maxY
        )
    }
    
    func pointZ(width: Double, height: Double) -> CGPoint {
        let zeroX = width / 2.0
        let zeroY = height / 1.5
        
        var axes = axes
        if axes == nil {
            axes = .zero
            axes?.displayableAbsMax = 1.0
        }
        
        let maxX = width / 2.0
        let angle = angle(width: width, height: height)
        let hypotenuse = maxXValue(maxX: maxX, angle: angle) * 
        (showMax ? 1.0 : (min(abs(axes!.values[.z]?.value ?? 0.0), axes!.displayableAbsMax) / axes!.displayableAbsMax))
        
        return CGPoint(
            x: zeroX + (hypotenuse * sin(angle * Double.pi / 180)),
            y: zeroY + (hypotenuse * cos(angle * Double.pi / 180))
        )
    }
    
    
    func maxXValue(maxX: Double, angle: Double) -> Double {
        maxX / sin(.radians(degrees: angle))
    }
    
    func path(in rect: CGRect) -> Path {
        Path { path in
            //            let width: CGFloat = min(rect.width, rect.height)
            let width: CGFloat = rect.width
            //            let height = width
            let height = rect.height
            
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
