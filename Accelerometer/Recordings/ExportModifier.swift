//
//  ExportModifier.swift
//  Accelerometer
//
//  Created by Andrey Pantyuhin on 03.10.2025.
//

import SwiftUI
import UniformTypeIdentifiers

struct ExportModifier: ViewModifier {
    
    @Binding var isPresented: Bool
    @Binding var url: URL?
    let filename: String
    
    init(
        isPresented: Binding<Bool>,
        url: Binding<URL?>,
        filename: String
    ) {
        _isPresented = isPresented
        _url = url
        self.filename = filename
    }
    
    init(
        isPresented: Binding<Bool>,
        url: Binding<URL?>,
        measurementType: MeasurementType
    ) {
        _isPresented = isPresented
        _url = url
        self.filename = "\(measurementType.rawValue).csv"
    }
    
    func body(content: Content) -> some View {
        content
            .fileExporter(
                isPresented: $isPresented,
                document: url.map { FileDocumentWrapper(url: $0) },
                contentType: UTType.plainText,
                defaultFilename: filename
            ) { _ in }
    }
}
