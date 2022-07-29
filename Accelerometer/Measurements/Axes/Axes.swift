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
            minX: nil,
            minY: nil,
            minZ: nil,
            maxX: nil,
            maxY: nil,
            maxZ: nil,
            displayableAbsMax: properties.displayableAbsMax
        )
    }
}

extension Axes {
    
    struct AnimatableProperties: VectorArithmetic {
        
        var x: Double
        var y: Double
        var z: Double
        
        var minX: Double?
        var minY: Double?
        var minZ: Double?
        
        var maxX: Double?
        var maxY: Double?
        var maxZ: Double?
        
        var vector: Double {
            sqrt(pow(x, 2.0) + pow(y, 2.0) + pow(z, 2.0))
        }
        
        var maxV: Double?
        var minV: Double?
        
        var magnitudeSquared: Double {
            let values = [x, y, z]
            return vDSP.sum(vDSP.multiply(values, values))
        }
        
        var displayableAbsMax: Double
        
        static var zero = AnimatableProperties(
            x: 0.0,
            y: 0.0,
            z: 0.0,
            minX: nil,
            minY: nil,
            minZ: nil,
            maxX: nil,
            maxY: nil,
            maxZ: nil,
            maxV: nil,
            minV: nil,
            displayableAbsMax: 0.0
        )
        
        static func + (lhs: AnimatableProperties, rhs: AnimatableProperties) -> Self {
            Self(
                x: lhs.x + rhs.x,
                y: lhs.y + rhs.y,
                z: lhs.z + rhs.z,
                minX: (lhs.minX ?? 0) + (rhs.minX ?? 0.0),
                minY: (lhs.minY ?? 0) + (rhs.minY ?? 0.0),
                minZ: (lhs.minZ ?? 0) + (rhs.minZ ?? 0.0),
                maxX: (lhs.maxX ?? 0) + (rhs.maxX ?? 0.0),
                maxY: (lhs.maxY ?? 0) + (rhs.maxY ?? 0.0),
                maxZ: (lhs.maxZ ?? 0) + (rhs.maxZ ?? 0.0),
                maxV: (lhs.maxV ?? 0) + (rhs.maxV ?? 0.0),
                minV: (lhs.minV ?? 0) + (rhs.minV ?? 0.0),
                displayableAbsMax: lhs.displayableAbsMax + rhs.displayableAbsMax
            )
        }
        
        static func - (lhs: AnimatableProperties, rhs: AnimatableProperties) -> Self {
            Self(
                x: lhs.x - rhs.x,
                y: lhs.y - rhs.y,
                z: lhs.z - rhs.z,
                minX: (lhs.minX ?? 0.0) - (rhs.minX ?? 0.0),
                minY: (lhs.minY ?? 0.0) - (rhs.minY ?? 0.0),
                minZ: (lhs.minZ ?? 0.0) - (rhs.minZ ?? 0.0),
                maxX: (lhs.maxX ?? 0.0) - (rhs.maxX ?? 0.0),
                maxY: (lhs.maxY ?? 0.0) - (rhs.maxY ?? 0.0),
                maxZ: (lhs.maxZ ?? 0.0) - (rhs.maxZ ?? 0.0),
                maxV: (lhs.maxV ?? 0.0) - (rhs.maxV ?? 0.0),
                minV: (lhs.minV ?? 0.0) - (rhs.minV ?? 0.0),
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
            
            minX = rhs * (minX ?? 0.0)
            minY = rhs * (minY ?? 0.0)
            minZ = rhs * (minZ ?? 0.0)
            
            maxX = rhs * (maxX ?? 0.0)
            maxY = rhs * (maxY ?? 0.0)
            maxZ = rhs * (maxZ ?? 0.0)
            
            maxV = rhs * (maxV ?? 0.0)
            minV = rhs * (minV ?? 0.0)
        }
        
        mutating func setValues(x: Double, y: Double, z: Double) {
            self.x = x
            self.y = y
            self.z = z
            
            maxX = max(x, maxX ?? x - 1)
            maxY = max(y, maxY ?? y - 1)
            maxZ = max(z, maxZ ?? z - 1)
            maxV = max(vector, maxV ?? vector - 1)
            
            minX = min(x, minX ?? x + 1)
            minY = min(y, minY ?? y + 1)
            minZ = min(z, minZ ?? z + 1)
            minV = min(vector, minV ?? vector + 1)
        }
    }
}

extension Axes {
    
    var intensityColor: Color {
        let intensity = abs(properties.vector) / properties.displayableAbsMax
        return Color.intensity(intensity)
    }
}
