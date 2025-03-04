//
//  TextFile.swift
//  Accelerometer
//
//  Created by Andrey on 03.08.2022.
//

import SwiftUI
import UniformTypeIdentifiers

struct TextFile: FileDocument {
    
    static let readableContentTypes = [UTType.commaSeparatedText]
    
    var text = ""
    
    init(initialText: String = "") {
        text = initialText
    }

    
    init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            text = String(decoding: data, as: UTF8.self)
        }
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = Data(text.utf8)
        return FileWrapper(regularFileWithContents: data)
    }
}
