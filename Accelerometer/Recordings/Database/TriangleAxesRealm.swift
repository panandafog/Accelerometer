//
//  TriangleAxesRealm.swift
//  Accelerometer
//
//  Created by Andrey on 05.08.2022.
//

import Foundation
import RealmSwift

class TriangleAxesRealm: Object {
    
    @objc dynamic var x: Double = 0
    @objc dynamic var y: Double = 0
    @objc dynamic var z: Double = 0
    @objc dynamic var v: Double = 0
    @objc dynamic var displayableAbsMax: Double = 0
    
    let minX = RealmProperty<Double?>()
    let minY = RealmProperty<Double?>()
    let minZ = RealmProperty<Double?>()
    let minV = RealmProperty<Double?>()
    
    let maxX = RealmProperty<Double?>()
    let maxY = RealmProperty<Double?>()
    let maxZ = RealmProperty<Double?>()
    let maxV = RealmProperty<Double?>()
    
    convenience init(
        x: Double,
        y: Double,
        z: Double,
        v: Double,
        minX: Double?,
        minY: Double?,
        minZ: Double?,
        minV: Double?,
        maxX: Double?,
        maxY: Double?,
        maxZ: Double?,
        maxV: Double?,
        displayableAbsMax: Double
    ) {
        self.init()
        
        self.x = x
        self.y = y
        self.z = z
        self.v = v
        
        self.minX.value = minX
        self.minY.value = minY
        self.minZ.value = minZ
        self.minV.value = minV
        
        self.maxX.value = maxX
        self.maxY.value = maxY
        self.maxZ.value = maxZ
        self.maxV.value = maxV
        
        self.displayableAbsMax = displayableAbsMax
    }
    
//    override class func primaryKey() -> String? {
//        "id"
//    }
}

extension TriangleAxesRealm {
    
    var axes: TriangleAxes {
        TriangleAxes(
            axes: [
                .x: .init(type_: .x, value: x, min: minX.value, max: maxX.value),
                .y: .init(type_: .y, value: y, min: minY.value, max: maxY.value),
                .z: .init(type_: .z, value: z, min: minZ.value, max: maxZ.value)
            ],
            displayableAbsMax: displayableAbsMax,
            vector: .init(type_: .vector, value: v, min: minV.value, max: maxV.value)
        )
    }
    
    convenience init(axes: TriangleAxes) {
        self.init(
            x: axes.values[.x]?.value ?? .zero,
            y: axes.values[.y]?.value ?? .zero,
            z: axes.values[.z]?.value ?? .zero,
            v: axes.vector.value,
            minX: axes.values[.x]?.min ?? .zero,
            minY: axes.values[.y]?.min ?? .zero,
            minZ: axes.values[.z]?.min ?? .zero,
            minV: axes.vector.min,
            maxX: axes.values[.x]?.max ?? .zero,
            maxY: axes.values[.y]?.max ?? .zero,
            maxZ: axes.values[.z]?.max ?? .zero,
            maxV: axes.vector.max,
            displayableAbsMax: axes.displayableAbsMax
        )
    }
}
