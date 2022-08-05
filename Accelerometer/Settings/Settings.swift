//
//  Settings.swift
//  Accelerometer
//
//  Created by Andrey on 03.08.2022.
//

import Foundation

class Settings: ObservableObject {
    
    static let shared = Settings()
    private init() { }
    
    var exportDateFormat: ExportDateFormat {
        get {
            let stringValue = UserDefaults.standard.string(forKey: "ExportDateFormat")
            if let value = ExportDateFormat(rawValue: stringValue ?? "") {
                return value
            } else {
                return .byDefault
            }
        }
        set {
            objectWillChange.send()
            UserDefaults.standard.set(newValue.rawValue, forKey: "ExportDateFormat")
        }
    }
}

extension Settings {
    
    enum ExportDateFormat: String, CaseIterable {
        case dateFormat
        case excel
        case unix
        
        static var byDefault: ExportDateFormat {
            .dateFormat
        }
        
        var displayableName: String {
            switch self {
            case .dateFormat:
                return DateFormatter.Recordings.csvStringFormat
            case .excel:
                return rawValue.capitalizingFirstLetter()
            case .unix:
                return rawValue.capitalizingFirstLetter()
            }
        }
    }
}
