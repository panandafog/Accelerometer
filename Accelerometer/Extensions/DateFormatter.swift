//
//  DateFormatter.swift
//  Accelerometer
//
//  Created by Andrey on 01.08.2022.
//

import Foundation

extension DateFormatter {
    
    enum Recordings {
        
        static let csvStringFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        
        static func csvString(from date: Date) -> String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = csvStringFormat
            return dateFormatter.string(from: date)
        }
        
        static func string(from date: Date) -> String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.doesRelativeDateFormatting = true

            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "h:mm:ss a"
            
            let dateString = dateFormatter.string(from: date)
            let timeString = timeFormatter.string(from: date)
            
            return [dateString, timeString].joined(separator: ", ")
        }
    }
}
