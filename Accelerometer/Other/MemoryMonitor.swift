//
//  MemoryMonitor.swift
//  Accelerometer
//
//  Created by Andrey Pantyuhin on 19.09.2025.
//

import Foundation

actor MemoryMonitor {
    
    func freeSpaceMB() -> Double {
        let fm = FileManager.default
        
        guard let url = fm.urls(for: .documentDirectory, in: .userDomainMask).first,
              let attrs = try? fm.attributesOfFileSystem(forPath: url.path),
              let free = attrs[.systemFreeSize] as? NSNumber
        else {
            return .infinity
        }
        
        return free.doubleValue / 1_048_576.0
    }
}
