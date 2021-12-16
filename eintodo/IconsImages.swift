//
//  IconsImages.swift
//  eintodo
//
//  Created by anh :) on 16.12.21.
//

import SwiftUI

struct IconsImage: View {
    let title: String
    let image: String
    let color: Color
    var body: some View {
        Image(systemName: image)
            .resizable()
            .frame(width: 25, height: 25)
            .foregroundColor(color)
        Text(title)
            .font(.title3)
        Spacer()
    }
}
