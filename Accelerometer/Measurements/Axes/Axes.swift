//
//  Axes.swift
//  Accelerometer
//
//  Created by Andrey on 04.07.2022.
//

import SwiftUI
import enum Accelerate.vDSP

final class Axes: ObservableObject {
    
    @Published var properties: AnimatableProperties
    
    init(displayableAbsMax: Double) {
        properties = .zero
        properties.displayableAbsMax = displayableAbsMax
    }
    
    func reset() {
        properties = AnimatableProperties(
            x: 0,
            y: 0,
            z: 0,
            minX: 0,
            minY: 0,
            minZ: 0,
            maxX: 0,
            maxY: 0,
            maxZ: 0,
            maxV: 0,
            minV: 0,
            displayableAbsMax: properties.displayableAbsMax
        )
    }
}

extension Axes {
    
    struct AnimatableProperties: VectorArithmetic {
        
        var x: Double
        var y: Double
        var z: Double
        
        var minX: Double
        var minY: Double
        var minZ: Double
        
        var maxX: Double
        var maxY: Double
        var maxZ: Double
        
        var vector: Double {
            sqrt(pow(x, 2.0) + pow(y, 2.0) + pow(z, 2.0))
        }
        
        var maxV: Double
        var minV: Double
        
        var magnitudeSquared: Double {
            let values = [x, y, z]
            return vDSP.sum(vDSP.multiply(values, values))
        }
        
        var displayableAbsMax: Double
        
        static var zero = AnimatableProperties(
            x: 0.0,
            y: 0.0,
            z: 0.0,
            minX: 0.0,
            minY: 0.0,
            minZ: 0.0,
            maxX: 0.0,
            maxY: 0.0,
            maxZ: 0.0,
            maxV: 0.0,
            minV: 0.0,
            displayableAbsMax: 0.0
        )
        
        static func + (lhs: AnimatableProperties, rhs: AnimatableProperties) -> Self {
            Self(
                x: lhs.x + rhs.x,
                y: lhs.y + rhs.y,
                z: lhs.z + rhs.z,
                minX: lhs.minX + rhs.minX,
                minY: lhs.minY + rhs.minY,
                minZ: lhs.minZ + rhs.minZ,
                maxX: lhs.minV + rhs.minV,
                maxY: lhs.maxX + rhs.maxX,
                maxZ: lhs.maxY + rhs.maxY,
                maxV: lhs.maxZ + rhs.maxZ,
                minV: lhs.maxV + rhs.maxV,
                displayableAbsMax: lhs.displayableAbsMax + rhs.displayableAbsMax
            )
        }
        
        static func - (lhs: AnimatableProperties, rhs: AnimatableProperties) -> Self {
            Self(
                x: lhs.x - rhs.x,
                y: lhs.y - rhs.y,
                z: lhs.z - rhs.z,
                minX: lhs.minX - rhs.minX,
                minY: lhs.minY - rhs.minY,
                minZ: lhs.minZ - rhs.minZ,
                maxX: lhs.minV - rhs.minV,
                maxY: lhs.maxX - rhs.maxX,
                maxZ: lhs.maxY - rhs.maxY,
                maxV: lhs.maxZ - rhs.maxZ,
                minV: lhs.maxV - rhs.maxV,
                displayableAbsMax: lhs.displayableAbsMax - rhs.displayableAbsMax
            )
        }
        
        static func == (lhs: AnimatableProperties, rhs: AnimatableProperties) -> Bool {
            lhs.x == rhs.x &&
            lhs.y == rhs.y &&
            lhs.z == rhs.z &&
            lhs.minX == rhs.minX &&
            lhs.minY == rhs.minY &&
            lhs.minZ == rhs.minZ &&
            lhs.minV == rhs.minV &&
            lhs.maxX == rhs.maxX &&
            lhs.maxY == rhs.maxY &&
            lhs.maxZ == rhs.maxZ &&
            lhs.maxV == rhs.maxV &&
            lhs.displayableAbsMax == rhs.displayableAbsMax
        }
        
        mutating func scale(by rhs: Double) {
            x *= rhs
            y *= rhs
            z *= rhs
            minX *= rhs
            minY *= rhs
            minZ *= rhs
            maxX *= rhs
            maxY *= rhs
            maxZ *= rhs
            minV *= rhs
            maxV *= rhs
        }
        
        mutating func setValues(x: Double, y: Double, z: Double) {
            self.x = x
            self.y = y
            self.z = z
            
            maxX = max(x, maxX)
            maxY = max(y, maxY)
            maxZ = max(z, maxZ)
            maxV = max(vector, maxV)
            
            minX = min(x, minX)
            minY = min(y, minY)
            minZ = min(z, minZ)
            minV = min(vector, minV)
        }
    }
}

extension Axes {
    
    var intensityColor: Color {
        let intensity = abs(properties.vector) / properties.displayableAbsMax
        return Color.intensity(intensity, opacity: 1.0)
    }
}
