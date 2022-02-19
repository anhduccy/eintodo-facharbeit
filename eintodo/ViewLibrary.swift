//
//  ViewLibrary.swift
//  eintodo
//
//  Created by anh :) on 16.12.21.
//

import SwiftUI

//Label
struct LeftText: View{
    let text: String
    let font: Font
    let fontWeight: Font.Weight
    init(text: String, font: Font = .body, fontWeight: Font.Weight = .regular){
        self.text = text
        self.font = font
        self.fontWeight = fontWeight
    }
    var body: some View{
        HStack{
            Text(text)
                .font(font)
                .fontWeight(fontWeight)
            Spacer()
        }
    }
}

//System Icons and Image Settings

//Icon for SF Symbols which has not ".circle.fill"
struct SystemCircleIcon: View{
    init(image: String, size: CGFloat, foregroundColor: Color = .white, backgroundColor: Color){
        self.image = image
        self.size = size
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
    }
    
    let image: String
    let size: CGFloat
    let foregroundColor: Color
    let backgroundColor: Color
    
    var body: some View{
        ZStack{
            Circle().fill(backgroundColor)
                .frame(width: size, height: size)
            Image(systemName: image)
                .resizable()
                .scaledToFit()
                .frame(width: size/2, height: size/2)
                .foregroundColor(foregroundColor)
        }
    }
}

//Icon for SF Symbols which has ".circle.fill"
struct SystemIcon: View {
    init(image: String, color: Color = Colors.primaryColor, size: CGFloat, isActivated: Bool, opacity: CGFloat = 1){
        self.image = image
        self.color = color
        self.size = size
        self.isActivated = isActivated
        self.opacity = opacity
    }
    let image: String
    let color: Color
    let size: CGFloat
    let isActivated: Bool
    let opacity: CGFloat
    var body: some View {
        ZStack{
            Circle()
                .fill(.white)
                .frame(width: size-1, height: size-1)
            SystemImage(image: image, color: color, size: size, isActivated: isActivated, opacity: opacity)
        }
    }
}
struct SystemImage: View{
    @Environment(\.colorScheme) public var colorScheme
    let image: String
    let color: Color
    let size: CGFloat
    let isActivated: Bool
    let opacity: CGFloat
    init(image: String, color: Color = Colors.primaryColor, size: CGFloat, isActivated: Bool, opacity: CGFloat = 1){
        self.image = image
        self.color = color
        self.size = size
        self.isActivated = isActivated
        self.opacity = opacity
    }
    var body: some View {
        if(isActivated){
            Image(systemName: image)
                .resizable()
                .scaledToFit()
                .frame(width: size)
                .foregroundColor(color)
                .opacity(opacity)
        } else {
            Image(systemName: image)
                .resizable()
                .scaledToFit()
                .frame(width: size)
                .foregroundColor(.gray)
                .opacity(colorScheme == .dark ? 1 : 0.5)
        }
    }
}

//Submit Button
struct SubmitButtonsWithCondition: View{
    @Environment(\.colorScheme) var appearance
    let condition: Bool
    @Binding var isPresented: Bool
    
    let updateAction: () -> Void
    let deleteAction: () -> Void
    let cancelAction: () -> Void
    let type: EditViewTypes
    @State var overDeleteButton: Bool = false
    var body: some View{
        HStack{
            //Cancel Button
            Button("Abbrechen"){
                cancelAction()
                isPresented.toggle()
            }
            .foregroundColor(.gray)
            .buttonStyle(.plain)
            //Delete Button
            if type == .edit{
                Spacer()
                Button(action: {
                    deleteAction()
                    isPresented.toggle()
                }, label: {
                    SystemIcon(image: "trash.circle.fill", color: overDeleteButton ? Colors.primaryColor : .red, size: 25, isActivated: true)
                })
                    .buttonStyle(.plain)
                    .onHover{ over in
                        withAnimation{
                            overDeleteButton = over
                        }
                    }
            }
            Spacer()
            //Done Button
            if(condition){
                Button(action: {
                    updateAction()
                    isPresented.toggle()
                }, label: {
                    Text("Fertig")
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundColor(appearance == .dark ? Colors.secondaryColor : Colors.primaryColor)
                })
                .buttonStyle(.plain)
            } else {
                Button(action: {
                    isPresented.toggle()
                }, label: {
                    Text("Fertig")
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundColor(.gray)
                })
                .buttonStyle(.plain)
            }
        }
    }
}
