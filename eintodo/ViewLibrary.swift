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

struct SheetButton: View {
    @ObservedObject var todo: ToDo
    @State var isPresented: Bool = false

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
                        Spacer()
                    }
                    if todo.deadline != Date(timeIntervalSince1970: 0){
                        HStack{
                            Text("Fällig am " + DateToStringFormatter(date: todo.deadline ?? Date(timeIntervalSince1970: 0)))
                            .foregroundColor(.gray)
                            Spacer()
                        }
                    }
                    if todo.notification != Date(timeIntervalSince1970: 0){
                        HStack{
                            Text(DateToStringFormatter(date: todo.notification ?? Date(timeIntervalSince1970: 0)))
                                .foregroundColor(.gray)
                            Spacer()
                        }
                    }
                }
                .padding(.top, 2)
                .padding(.bottom, 2)
            })
                .buttonStyle(.plain)
        }
        .sheet(isPresented: $isPresented) {
            DetailView(todo: todo, title: todo.title ?? "Error", deadline: todo.deadline ?? Date(timeIntervalSince1970: 0), notification: todo.notification ?? Date(timeIntervalSince1970: 0), isPresented: $isPresented)
        }
    }
}
