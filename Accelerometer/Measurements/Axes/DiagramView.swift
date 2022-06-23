//
//  DiagramView.swift
//  Accelerometer
//
//  Created by Andrey on 22.06.2022.
//

import SwiftUI

struct DiagramView: View {
    
    @Binding var axes: Measurer.Axes?
    
    func pointX(pathWidth: Double, pathHeight: Double, showMax: Bool = false) -> CGPoint {
        let zeroX = pathWidth / 2.0
        let zeroY = pathHeight / 2.0
        
        guard let axes = axes else {
            return CGPoint(x: zeroX, y: zeroY)
        }
        
        let maxX = pathWidth / 2.0
        let hypotenuse = maxXValue(maxX: maxX) * (showMax ? 1.0 : (abs(axes.x) / axes.displayableAbsMax))

        return CGPoint(
            x: zeroX - (hypotenuse * sin(60.0 * Double.pi / 180)),
            y: zeroY + (hypotenuse * sin(30.0 * Double.pi / 180))
        )
    }
    
    func pointY(pathWidth: Double, pathHeight: Double, showMax: Bool = false) -> CGPoint {
        let zeroX = pathWidth / 2.0
        let zeroY = pathHeight / 2.0
        
        guard let axes = axes else {
            return CGPoint(x: zeroX, y: zeroY)
        }
        
        let maxY = pathHeight / 2.0
        
        return CGPoint(
            x: zeroX,
            y: zeroY - (showMax ? 1.0 : (abs(axes.y) / axes.displayableAbsMax)) * maxY
        )
    }
    
    func pointZ(pathWidth: Double, pathHeight: Double, showMax: Bool = false) -> CGPoint {
        let zeroX = pathWidth / 2.0
        let zeroY = pathHeight / 2.0
        
        guard let axes = axes else {
            return CGPoint(x: zeroX, y: zeroY)
        }
        
        let maxX = pathWidth / 2.0
        let hypotenuse = maxXValue(maxX: maxX) * (showMax ? 1.0 : (abs(axes.z) / axes.displayableAbsMax))
        
        return CGPoint(
            x: zeroX + (hypotenuse * sin(60.0 * Double.pi / 180)),
            y: zeroY + (hypotenuse * sin(30.0 * Double.pi / 180))
        )
    }
    
    func maxXValue(maxX: Double) -> Double {
        maxX / sin(60.0 * Double.pi / 180)
    }
    
    var body: some View {
            ZStack {
                triangle(max: true)
                triangle()
            }
    }
    
    func triangle(max: Bool = false) -> some View {
        GeometryReader { geometry in
            Path { path in
                let width: CGFloat = min(geometry.size.width, geometry.size.height)
                let height = width
                
                let xPoint = pointX(pathWidth: width, pathHeight: height, showMax: max)
                let yPoint = pointY(pathWidth: width, pathHeight: height, showMax: max)
                let zPoint = pointZ(pathWidth: width, pathHeight: height, showMax: max)
                
                path.move(to: xPoint)
                path.addLine(to: yPoint)
                path.addLine(to: zPoint)
                path.addLine(to: xPoint)
            }
            .modify {
                if max {
                    $0.fill(Color.accentColor.opacity(0.3))
                } else {
                    $0.fill(Color.accentColor)
                }
            }
        }
    }
}

struct DiagramView_Previews: PreviewProvider {
    static var previews: some View {
        DiagramView(axes: .init(get: {
            let axes = Measurer.Axes(x: 10, y: 10, z: 10, displayableAbsMax: 10.0)
            axes.setValues(x: 5, y: 6, z: 4)
            return axes
        }, set: { _ in
            
        }))
    }
}
