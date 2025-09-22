//
//  Settings.swift
//  Accelerometer
//
//  Created by Andrey on 03.08.2022.
//

import Foundation
import Combine

class Settings: ObservableObject {
    
    static let maxUpdateInterval = 1.0
    static let minUpdateInterval = 0.1
    static let updateIntervalStep = 0.1
    static let updateIntervalRoundPlaces = 1
    
    static let measurementsDisplayRoundPlaces = 3
    
    static let minFreeSpaceMB = 500
    
    private static let initialUpdateInterval = 0.5
    
    // MARK: - User options
    
    var exportDateFormat: ExportDateFormat {
        get {
            let stringValue = UserDefaults.standard.string(forKey: Key.exportDateFormat.rawValue)
            if let value = ExportDateFormat(rawValue: stringValue ?? "") {
                return value
            } else {
                return .byDefault
            }
        }
        set {
            objectWillChange.send()
            UserDefaults.standard.set(newValue.rawValue, forKey: Key.exportDateFormat.rawValue)
        }
    }
    
    private let updateIntervalSubject = PassthroughSubject<Double, Never>()
    var updateIntervalPublisher: AnyPublisher<Double, Never> {
        updateIntervalSubject.eraseToAnyPublisher()
    }
    var updateInterval: Double {
        get {
            let defaultValue = UserDefaults.standard.double(forKey: Key.measurementsUpdateInterval.rawValue)
            if defaultValue == 0.0 || defaultValue < Self.minUpdateInterval || defaultValue > Self.maxUpdateInterval {
                return Self.initialUpdateInterval
            } else {
                return defaultValue
            }
        }
        set {
            let roundedValue = newValue.rounded(toPlaces: Self.updateIntervalRoundPlaces)
            UserDefaults.standard.set(roundedValue, forKey: Key.measurementsUpdateInterval.rawValue)
            
            objectWillChange.send()
            updateIntervalSubject.send(roundedValue)
        }
    }
    
    // MARK: - Debug options
    #if DEBUG
    var enableAnimations: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Key.enableAnimations.rawValue)
        }
        set {
            objectWillChange.send()
            UserDefaults.standard.set(newValue, forKey: Key.enableAnimations.rawValue)
        }
    }

    var alwaysNotEnoughMemory: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Key.alwaysNotEnoughMemory.rawValue)
        }
        set {
            objectWillChange.send()
            UserDefaults.standard.set(newValue, forKey: Key.alwaysNotEnoughMemory.rawValue)
        }
    }
    #endif
}

// MARK: - ExportDateFormat

extension Settings {
    
    enum ExportDateFormat: String, CaseIterable {
        case unix
        case excel
        case dateFormat
        
        static var byDefault: ExportDateFormat {
            .unix
        }
        
        var displayableName: String {
            switch self {
            case .unix:
                return rawValue.capitalizingFirstLetter()
            case .excel:
                return "Spreadsheet Serial Date (1900 System)"
            case .dateFormat:
                return DateFormatter.Recordings.csvStringFormat
            }
        }
    }
}

// MARK: - Keys

extension Settings {
    enum Key: String {
        case exportDateFormat = "ExportDateFormat"
        #if DEBUG
        case enableAnimations = "EnableAnimations"
        case alwaysNotEnoughMemory = "AlwaysNotEnoughMemory"
        #endif
        case measurementsUpdateInterval = "MeasurementsUpdateInterval"
    }
}
