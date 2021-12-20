//
//  IconsImages.swift
//  eintodo
//
//  Created by anh :) on 16.12.21.
//

import SwiftUI


//ButtonStyles
struct DeleteButton: ButtonStyle {
    @Environment(\.colorScheme) public var colorScheme

    @State private var backgroundColor: Color = .indigo
    @State private var overButton = false
    
    let secondaryColor: Color = Color(red: 139/255, green: 136/255, blue: 248/255)
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(minWidth: 0, maxWidth: 367)
            .padding(12.5)
            .background(colorScheme == .dark ? (overButton ? .red : secondaryColor) : (overButton ? .red : backgroundColor))
            .foregroundColor(.white)
            .cornerRadius(10)
            .font(.body)
            .onHover { over in
                withAnimation{
                    overButton = over
                }
            }
    }
}

//Images
struct IconsImage: View {
    let title: String
    let image: String
    let color: Color
    let size: CGFloat
    var body: some View {
        ZStack{
            Circle()
                .fill(.white)
                .frame(width: size-1, height: size-1)
            SystemImage(image: image, size: size, color: color)
        }
        Text(title)
            .font(.title3)
            .foregroundColor(.white)
        Spacer()
    }
}

struct SystemImage: View{
    let image: String
    let size: CGFloat
    let color: Color
    var body: some View {
        Image(systemName: image)
            .resizable()
            .frame(width: size, height: size)
            .foregroundColor(color)
    }
}

//Buttons

struct SheetButton: View {
    @ObservedObject var todo: ToDo
    @State var isPresented: Bool = false
    
    let text_color: Color = .white

    init(_ todo: ToDo) {
        self.todo = todo
    }

    var body: some View {
        HStack{
            //Labelling
            Button(action: {
                isPresented.toggle()
            }, label: {
                VStack{
                    HStack{
                        Text(todo.title ?? "Error")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(text_color)
                        Spacer()
                    }
                    if todo.deadline != Date(timeIntervalSince1970: 0){
                        HStack{
                            Text("Fällig am " + DateToStringFormatter(date: todo.deadline ?? Date(timeIntervalSince1970: 0)))
                                .foregroundColor(text_color)
                            .fontWeight(.light)
                            Spacer()
                        }
                    }
                    if todo.notification != Date(timeIntervalSince1970: 0){
                        HStack{
                            Text(DateToStringFormatter(date: todo.notification ?? Date(timeIntervalSince1970: 0)))
                                .foregroundColor(text_color)
                                .fontWeight(.light)
                            Spacer()
                        }
                    }
                }
                .padding(.top, 5)
                .padding(.bottom, 5)
            })
                .buttonStyle(.plain)
            if(todo.notes != ""){
                SystemImage(image: "note.text", size: 15, color: .white)
            }
        }
        .sheet(isPresented: $isPresented) {
            DetailView(todo: todo, title: todo.title ?? "Error", notes: todo.notes ?? "Error", deadline: todo.deadline ?? Date(timeIntervalSince1970: 0), notification: todo.notification ?? Date(timeIntervalSince1970: 0), isMarked: todo.isMarked, isPresented: $isPresented)
        }
    }
}
