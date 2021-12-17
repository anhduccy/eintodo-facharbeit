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
    let size: CGFloat
    var body: some View {
        SystemImage(image: image, size: size)
            .foregroundColor(color)
        Text(title)
            .font(.title3)
        Spacer()
    }
}

struct SystemImage: View{
    let image: String
    let size: CGFloat
    var body: some View {
        Image(systemName: image)
            .resizable()
            .frame(width: size, height: size)
    }
}
