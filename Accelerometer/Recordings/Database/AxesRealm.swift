//
//  AxesRealm.swift
//  Accelerometer
//
//  Created by Andrey on 05.08.2022.
//

import Foundation
import RealmSwift

class AxesRealm: Object {
    
    @objc dynamic var x: Double = 0
    @objc dynamic var y: Double = 0
    @objc dynamic var z: Double = 0
    @objc dynamic var displayableAbsMax: Double = 0
    
    let minX = RealmProperty<Double?>()
    let minY = RealmProperty<Double?>()
    let minZ = RealmProperty<Double?>()
    
    let maxX = RealmProperty<Double?>()
    let maxY = RealmProperty<Double?>()
    let maxZ = RealmProperty<Double?>()
    
    let maxV = RealmProperty<Double?>()
    let minV = RealmProperty<Double?>()
    
    let measurementTypes: List<String> = .init()
    
    convenience init(
        x: Double,
        y: Double,
        z: Double,
        minX: Double?,
        minY: Double?,
        minZ: Double?,
        maxX: Double?,
        maxY: Double?,
        maxZ: Double?,
        maxV: Double?,
        minV: Double?,
        displayableAbsMax: Double
    ) {
        self.init()
        self.x = x
        self.y = y
        self.z = z
        
        self.minX.value = minX
        self.minY.value = minY
        self.minZ.value = minZ
        
        self.maxX.value = maxX
        self.maxY.value = maxY
        self.maxZ.value = maxZ
        
        self.maxV.value = maxV
        self.minV.value = minV
        
        self.displayableAbsMax = displayableAbsMax
    }
    
//    override class func primaryKey() -> String? {
//        "id"
//    }
}

extension AxesRealm {
    
    var axes: Axes {
        Axes(
            x: x,
            y: y,
            z: z,
            minX: minX.value,
            minY: minY.value,
            minZ: minZ.value,
            maxX: maxX.value,
            maxY: maxY.value,
            maxZ: maxZ.value,
            maxV: maxV.value,
            minV: minV.value,
            displayableAbsMax: displayableAbsMax
        )
    }
    
    convenience init(axes: Axes) {
        self.init(
            x: axes.x,
            y: axes.y,
            z: axes.z,
            minX: axes.minX,
            minY: axes.minY,
            minZ: axes.minZ,
            maxX: axes.maxX,
            maxY: axes.maxY,
            maxZ: axes.maxZ,
            maxV: axes.maxV,
            minV: axes.minV,
            displayableAbsMax: axes.displayableAbsMax
        )
    }
}
