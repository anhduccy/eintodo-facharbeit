//
//  ViewLibrary.swift
//  eintodo
//
//  Created by anh :) on 16.12.21.
//

import SwiftUI

//Images and Icons
struct CalendarViewMonthButton: View {
    let name: String
    let color: Color
    let size: CGFloat = 22.5
    
    var body: some View{
        ZStack{
            Circle().fill(color).opacity(0.2)
            Image(systemName: name)
                .foregroundColor(color)
        }
        .padding(0)
        .frame(width: size, height: size)
    }
}
struct IconImage: View {
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
                .frame(width: size, height: size)
                .foregroundColor(color)
                .opacity(opacity)
        } else {
            Image(systemName: image)
                .resizable()
                .frame(width: size, height: size)
                .foregroundColor(.gray)
                .opacity(colorScheme == .dark ? 1 : 0.5)
        }
    }
}

//Buttons
struct SheetButton: View {
    @ObservedObject var todo: ToDo
    @State var isPresented: Bool = false
    @Binding var selectedDate: Date
    
    let text_color: Color = .white

    init(_ todo: ToDo, selectedDate: Binding<Date>) {
        self.todo = todo
        _selectedDate = selectedDate
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
                    if todo.deadline != Dates.defaultDate{
                        HStack{
                            Text(DateInString(date: todo.deadline ?? Dates.defaultDate, type: "deadline"))
                                .foregroundColor(text_color)
                                .fontWeight(.light)
                            Spacer()
                        }
                    }
                    if todo.notification != Dates.defaultDate{
                        HStack{
                            Text(DateInString(date: todo.notification ?? Dates.defaultDate, type: "notification"))
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
                SystemImage(image: "note.text", color: .white, size: 15, isActivated: true)
            }
        }
        .sheet(isPresented: $isPresented) {
            DetailView(detailViewType: .display, todo: todo, title: todo.title ?? "Error", notes: todo.notes ?? "Error", deadline: todo.deadline ?? Dates.defaultDate, notification: todo.notification ?? Dates.defaultDate, isMarked: todo.isMarked, priority: Int(todo.priority), isPresented: $isPresented, selectedDate: $selectedDate)
        }
    }
}
