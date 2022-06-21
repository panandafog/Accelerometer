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
            Spacer()
            Text("current")
            Spacer()
            Text("max")
        }
    }
}

struct HeaderView_Previews: PreviewProvider {
    static var previews: some View {
        HeaderView()
    }
}
