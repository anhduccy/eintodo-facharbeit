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
struct ToDoListsViewMainButtonIcon: View{
    let title: String
    let imageName: String
    let size: CGFloat
    let foregroundColor: Color
    let backgroundColor: Color
    
    init(title: String, imageName: String, size: CGFloat = 25, foregroundColor: Color = .white, backgroundColor: Color){
        self.title = title
        self.imageName = imageName
        self.size = size
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
    }
    
    var body: some View{
        HStack{
            Image(systemName: imageName)
                .resizable()
                .frame(width: size, height: size)
                .foregroundColor(foregroundColor)
            Text(title).font(.headline)
                .foregroundColor(foregroundColor)
            Spacer()
        }
        .padding(7.5)
        .background(backgroundColor)
        .cornerRadius(5)
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
                .scaledToFit()
                .frame(width: size, height: size)
                .foregroundColor(color)
                .opacity(opacity)
        } else {
            Image(systemName: image)
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
                .foregroundColor(.gray)
                .opacity(colorScheme == .dark ? 1 : 0.5)
        }
    }
}

//Buttons
struct ListRow: View {
    @EnvironmentObject private var userSelected: UserSelected
    @FetchRequest var subToDos: FetchedResults<SubToDo>
    
    @ObservedObject var todo: ToDo
    @State var isPresented: Bool = false
        
    let text_color: Color = .white

    init(_ todo: ToDo) {
        self.todo = todo
        _subToDos = FetchRequest(sortDescriptors: [], predicate: NSPredicate(format: "idOfMainToDo == %@", todo.todoID! as CVarArg), animation: .default)
    }

    var body: some View {
        HStack{
            //Labelling
            Button(action: {
                isPresented.toggle()
            }, label: {
                VStack{
                    HStack{
                        Text(todo.todoTitle ?? "Error")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(text_color)
                        Spacer()
                    }
                    if todo.todoDeadline != Dates.defaultDate{
                        HStack{
                            Text(DateInString(date: todo.todoDeadline ?? Dates.defaultDate, type: "deadline"))
                                .foregroundColor(text_color)
                                .fontWeight(.light)
                            Spacer()
                        }
                    }
                    if todo.todoNotification != Dates.defaultDate{
                        HStack{
                            Text(DateInString(date: todo.todoNotification ?? Dates.defaultDate, type: "notification"))
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
            if(todo.todoNotes != ""){
                SystemImage(image: "note.text", color: .white, size: 15, isActivated: true)
            }
            if(hasImage()){
                SystemImage(image: "photo.fill", color: .white, size: 15, isActivated: true)
            }
            if(!subToDos.isEmpty){
                SystemImage(image: getNumberIcon(), color: .white, size: 15, isActivated: true)
            }
        }
        .sheet(isPresented: $isPresented) {
            DetailView(detailViewType: .display, todo: todo, list: todo.todoList ?? "Error", listID: todo.idOfToDoList ?? UUID(), isPresented: $isPresented)
        }
    }
    func getNumberIcon()->String{
        let int = subToDos.count
        let iconName = "\(int).circle.fill"
        return iconName
    }
    func hasImage()->Bool{
        if CoreDataToNSImageArray(coreDataObject: todo.todoImages)?.isEmpty ?? [].isEmpty{
            return false
        } else {
            return true
        }
    }
}

struct SheetButtonToDoList: View{
    @ObservedObject var list: ToDoList
    @EnvironmentObject private var userSelected: UserSelected
    @State var showToDoListsDetailView: Bool = false
    
    var body: some View{
        Button(action: {
            showToDoListsDetailView.toggle()
        }, label: {
            Image(systemName: "info.circle")
                .foregroundColor(userSelected.selectedToDoListID == list.listID ?? UUID() ? .white : Colors.primaryColor)
        }).buttonStyle(.plain)
            .sheet(isPresented: $showToDoListsDetailView){
                ToDoListDetailView(type: .display, isPresented: $showToDoListsDetailView, toDoList: list)
            }
    }
}
