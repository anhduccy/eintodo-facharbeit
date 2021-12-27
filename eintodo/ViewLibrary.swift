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
            Circle().fill(color).opacity(0.1)
            Image(systemName: name)
                .foregroundColor(color)
        }
        .padding(0)
        .frame(width: size, height: size)
    }
}
struct IconImage: View {
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
                            Text("Fällig am " + DateInString(date: todo.deadline ?? Dates.defaultDate))
                                .foregroundColor(text_color)
                            .fontWeight(.light)
                            Spacer()
                        }
                    }
                    if todo.notification != Dates.defaultDate{
                        HStack{
                            Text(DateInString(date: todo.notification ?? Dates.defaultDate))
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
            DetailView(detailViewType: .display, todo: todo, title: todo.title ?? "Error", notes: todo.notes ?? "Error", deadline: todo.deadline ?? Dates.defaultDate, notification: todo.notification ?? Dates.defaultDate, isMarked: todo.isMarked, isPresented: $isPresented, selectedDate: $selectedDate)
        }
    }
}
