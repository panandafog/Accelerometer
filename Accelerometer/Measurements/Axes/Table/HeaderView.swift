//
//  HeaderView.swift
//  Accelerometer
//
//  Created by Andrey on 22.06.2022.
//

import SwiftUI

struct HeaderView: View {
    
    var body: some View {
        HStack {
            Text("min")
                .foregroundColor(.secondary)
            Spacer()
            Text("current")
                .foregroundColor(.secondary)
            Spacer()
            Text("max")
                .foregroundColor(.secondary)
        }
    }
}

struct HeaderView_Previews: PreviewProvider {
    static var previews: some View {
        HeaderView()
            .previewLayout(.sizeThatFits)
    }
}
