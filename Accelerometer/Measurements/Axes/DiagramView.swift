//
//  DiagramView.swift
//  Accelerometer
//
//  Created by Andrey on 22.06.2022.
//

import SwiftUI

struct DiagramView: View {
    
    @Binding var axes: Measurer.Axes
    
    func pointX(pathWidth: Double, pathHeight: Double) -> CGPoint {
        let zeroX = pathWidth / 2.0
        let zeroY = pathHeight / 2.0
        
        let maxX = pathWidth / 2.0
        
        return CGPoint(
            x: zeroX - (maxXValue(maxX: maxX) * (axes.x / axes.maxX) * sin(60.0 * Double.pi / 180)),
            y: zeroY + (maxXValue(maxX: maxX) * (axes.x / axes.maxX) * sin(30.0 * Double.pi / 180))
        )
    }
    
    func pointY(pathWidth: Double, pathHeight: Double) -> CGPoint {
        let zeroX = pathWidth / 2.0
        let zeroY = pathHeight / 2.0
        
        let maxY = pathHeight / 2.0
        
        return CGPoint(
            x: zeroX,
            y: zeroY - (axes.y / axes.maxY) * maxY
        )
    }
    
    func pointZ(pathWidth: Double, pathHeight: Double) -> CGPoint {
        let zeroX = pathWidth / 2.0
        let zeroY = pathHeight / 2.0
        
        let maxX = pathWidth / 2.0
        
        return CGPoint(
            x: zeroX + (maxXValue(maxX: maxX) * (axes.z / axes.maxX) * sin(60.0 * Double.pi / 180)),
            y: zeroY + (maxXValue(maxX: maxX) * (axes.z / axes.maxX) * sin(30.0 * Double.pi / 180))
        )
    }
    
    func maxXValue(maxX: Double) -> Double {
        maxX / sin(60.0 * Double.pi / 180)
    }
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width: CGFloat = min(geometry.size.width, geometry.size.height)
                let height = width
                
                let xPoint = pointX(pathWidth: width, pathHeight: height)
                let yPoint = pointY(pathWidth: width, pathHeight: height)
                let zPoint = pointZ(pathWidth: width, pathHeight: height)

                path.move(to: xPoint)
                path.addLine(to: yPoint)
                path.addLine(to: zPoint)
                path.addLine(to: xPoint)
            }
            .fill(Color.accentColor)
        }
    }
}

struct DiagramView_Previews: PreviewProvider {
    static var previews: some View {
        DiagramView(axes: .init(get: {
            var axes = Measurer.Axes(x: 10, y: 10, z: 10)
            axes.setValues(x: 5, y: 6, z: 4)
            return axes
        }, set: { _ in
            
        }))
    }
}
