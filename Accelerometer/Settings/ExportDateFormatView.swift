//
//  ExportDateFormatView.swift
//  Accelerometer
//
//  Created by Andrey on 03.08.2022.
//

import SwiftUI

struct ExportDateFormatView: View {
    
    @EnvironmentObject var settings: Settings
    
    func selectedDateFormat() -> Settings.ExportDateFormat {
        settings.exportDateFormat
    }
    
    func setSelectedDateFormat(_ newValue: Settings.ExportDateFormat) {
        settings.exportDateFormat = newValue
    }
    
    var body: some View {
        Picker(
            "Export date format",
            selection: .init(
                get: { selectedDateFormat() },
                set: { newFormat in
                    setSelectedDateFormat(newFormat)
                }
            )
        ) {
            ForEach(Settings.ExportDateFormat.allCases, id: \.self) {
                Text($0.displayableName)
            }
        }
        .pickerStyle(.automatic)
    }
}

struct ExportDateFormatView_Previews: PreviewProvider {
    static var previews: some View {
        ExportDateFormatView()
            .previewLayout(.sizeThatFits)
            .environmentObject(Settings())
    }
}
