//
//  ListView.swift
//  eintodo
//
//  Created by anh :) on 12.12.21.
//

import SwiftUI
import Foundation

struct ToDoListView: View {
    @Environment(\.managedObjectContext) public var viewContext
    @Environment(\.colorScheme) public var colorScheme
    @EnvironmentObject private var userSelected: UserSelected
    @FetchRequest var todos: FetchedResults<ToDo>
        
    init(title: String, rowType: ToDoListRowType, listFilterType: ToDoListFilterType = .dates, userSelected: UserSelected){
        let calendar = Calendar.current
        let dateFrom = calendar.startOfDay(for: userSelected.lastSelectedDate)
        let dateTo = calendar.date(byAdding: .minute, value: 1439, to: dateFrom)
        let defaultDate = Dates.defaultDate
        let currentDate = Date()
        
        switch(listFilterType){
        case .dates: //To-Dos with deadline and/or notfication
            if(userSelected.showDoneToDos == true){
                _todos = FetchRequest(
                    sortDescriptors: [
                        NSSortDescriptor(keyPath: \ToDo.todoIsDone, ascending: true),
                        NSSortDescriptor(keyPath: \ToDo.todoDeadline, ascending: true),
                        NSSortDescriptor(keyPath: \ToDo.todoNotification, ascending: true)],
                    predicate: NSPredicate(format: "(todoDeadline <= %@ && todoDeadline >= %@) || (todoNotification <= %@ && todoNotification >= %@)", dateTo! as CVarArg, dateFrom as CVarArg, dateTo! as CVarArg, dateFrom as CVarArg),
                    animation: .default)
            } else { //To-Dos with deadline and/or notfication and show done to-dos is false
                _todos = FetchRequest(
                    sortDescriptors: [
                        NSSortDescriptor(keyPath: \ToDo.todoIsDone, ascending: true),
                        NSSortDescriptor(keyPath: \ToDo.todoDeadline, ascending: true),
                        NSSortDescriptor(keyPath: \ToDo.todoNotification, ascending: true)],
                    predicate: NSPredicate(format: "((todoDeadline <= %@ && todoDeadline >= %@) || (todoNotification <= %@ && todoNotification >= %@)) && todoIsDone == false", dateTo! as CVarArg, dateFrom as CVarArg, dateTo! as CVarArg, dateFrom as CVarArg),
                    animation: .default)
            }
        case .noDates: //To-Dos without deadline and notification
            if(userSelected.showDoneToDos == true){
                _todos = FetchRequest(
                    sortDescriptors: [
                        NSSortDescriptor(keyPath: \ToDo.todoIsDone, ascending: true),
                        NSSortDescriptor(keyPath: \ToDo.todoTitle, ascending: true)],
                    predicate: NSPredicate(format: "todoDeadline == %@ && todoNotification == %@",
                                           defaultDate as CVarArg,  defaultDate as CVarArg),
                    animation: .default)
            } else { //To-Dos without deadline and notfication and show done to-dos is false
                _todos = FetchRequest(
                    sortDescriptors: [
                        NSSortDescriptor(keyPath: \ToDo.todoTitle, ascending: true)],
                    predicate: NSPredicate(format: "todoDeadline == %@ && todoNotification == %@ && todoIsDone == false",
                                           defaultDate as CVarArg, defaultDate as CVarArg),
                    animation: .default)
            }
        case .inPastAndNotDone: //All To-Dos in the past and which has not been done yet
            if(userSelected.showDoneToDos == true){
                _todos = FetchRequest(
                    sortDescriptors: [
                        NSSortDescriptor(keyPath: \ToDo.todoIsDone, ascending: true),
                        NSSortDescriptor(keyPath: \ToDo.todoDeadline, ascending: true),
                        NSSortDescriptor(keyPath: \ToDo.todoNotification, ascending: true)],
                    predicate: NSPredicate(format: "todoDeadline < %@ && todoDeadline != %@", currentDate as CVarArg, defaultDate as CVarArg),
                    animation: .default)
            } else {
                _todos = FetchRequest(
                    sortDescriptors: [
                        NSSortDescriptor(keyPath: \ToDo.todoIsDone, ascending: true),
                        NSSortDescriptor(keyPath: \ToDo.todoDeadline, ascending: true),
                        NSSortDescriptor(keyPath: \ToDo.todoNotification, ascending: true)],
                    predicate: NSPredicate(format: "todoDeadline < %@ && todoDeadline != %@ && todoIsDone == false", currentDate as CVarArg, defaultDate as CVarArg),
                    animation: .default)
            }
        case .marked:
            if(userSelected.showDoneToDos == true){
                _todos = FetchRequest(
                    sortDescriptors: [
                        NSSortDescriptor(keyPath: \ToDo.todoIsDone, ascending: true),
                        NSSortDescriptor(keyPath: \ToDo.todoDeadline, ascending: true),
                        NSSortDescriptor(keyPath: \ToDo.todoNotification, ascending: true)],
                    predicate: NSPredicate(format: "todoIsMarked == true"),
                    animation: .default)
            } else {
                _todos = FetchRequest(
                    sortDescriptors: [
                        NSSortDescriptor(keyPath: \ToDo.todoIsDone, ascending: true),
                        NSSortDescriptor(keyPath: \ToDo.todoDeadline, ascending: true),
                        NSSortDescriptor(keyPath: \ToDo.todoNotification, ascending: true)],
                    predicate: NSPredicate(format: "todoIsMarked == true && todoIsDone == false"),
                    animation: .default)
            }
        case .all: //All To-Dos
            if(userSelected.showDoneToDos == true){
                _todos = FetchRequest(sortDescriptors: [
                    NSSortDescriptor(keyPath: \ToDo.todoIsDone, ascending: true),
                    NSSortDescriptor(keyPath: \ToDo.todoDeadline, ascending: true),
                    NSSortDescriptor(keyPath: \ToDo.todoNotification, ascending: true)], animation: .default)
            } else { //All To-Dos which has not been done yet
                _todos = FetchRequest(sortDescriptors: [
                    NSSortDescriptor(keyPath: \ToDo.todoIsDone, ascending: true),
                    NSSortDescriptor(keyPath: \ToDo.todoDeadline, ascending: true),
                    NSSortDescriptor(keyPath: \ToDo.todoNotification, ascending: true)],
                                      predicate: NSPredicate(format: "todoIsDone == false"), animation: .default)
            }
        case .list:
            if(userSelected.showDoneToDos == true){
                _todos = FetchRequest(sortDescriptors: [
                    NSSortDescriptor(keyPath: \ToDo.todoIsDone, ascending: true),
                    NSSortDescriptor(keyPath: \ToDo.todoDeadline, ascending: true),
                    NSSortDescriptor(keyPath: \ToDo.todoNotification, ascending: true)], predicate: NSPredicate(format: "idOfToDoList == %@", userSelected.selectedToDoListID as CVarArg), animation: .default)
            } else { //All To-Dos which has not been done yet
                _todos = FetchRequest(sortDescriptors: [
                    NSSortDescriptor(keyPath: \ToDo.todoIsDone, ascending: true),
                    NSSortDescriptor(keyPath: \ToDo.todoDeadline, ascending: true),
                    NSSortDescriptor(keyPath: \ToDo.todoNotification, ascending: true)],
                                      predicate: NSPredicate(format: "idOfToDoList == %@ && todoIsDone == false", userSelected.selectedToDoListID as CVarArg), animation: .default)
            }
        }
        self.title = title
        self.rowType = rowType
    }
    
    let title: String
    let rowType: ToDoListRowType
    
    var body: some View {
        VStack{
            VStack(spacing: 10){
                HStack{
                    Text(title).font(.largeTitle.bold())
                    Spacer()
                }
                List{
                    if(todos.isEmpty){
                        VStack{
                            HStack{
                                Text("Du hast noch nichts für den Tag geplant")
                                    .foregroundColor(.gray)
                                Spacer()
                            }
                        }
                    } else {
                        //ListView
                        ForEach(todos, id: \.self){ todo in
                            HStack{
                                ToDoListRow(rowType: rowType, todo: todo)
                            }
                        }
                    }
                }
            }
            .listStyle(.plain)
        }
        .padding()
        .frame(minWidth: 375)
        .background(colorScheme == .dark ? .clear : .white)
        .toolbar{
            ToolbarItem{
                Button(userSelected.showDoneToDos ? "Erledigte ausblenden" : "Erledigte einblenden"){
                    userSelected.showDoneToDos.toggle()
                }
            }
        }
    }
}

//Subviews
struct ToDoListRow: View {
    @Environment(\.managedObjectContext) public var viewContext
    @EnvironmentObject private var userSelected: UserSelected
    @FetchRequest var lists: FetchedResults<ToDoList>
    @FetchRequest var subToDos: FetchedResults<SubToDo>
    
    @ObservedObject var todo: ToDo
    @State var isPresented: Bool = false
    
    let rowType: ToDoListRowType
    let text_color: Color = .white
    let SystemImageSize: CGFloat = 17.5

    init(rowType: ToDoListRowType, todo: ToDo) {
        self.todo = todo
        _subToDos = FetchRequest(sortDescriptors: [], predicate: NSPredicate(format: "idOfMainToDo == %@", todo.todoID! as CVarArg), animation: .default)
        _lists = FetchRequest(sortDescriptors: [], predicate: NSPredicate(format: "listID == %@", todo.idOfToDoList! as CVarArg), animation: .default)
        self.rowType = rowType
    }

    var body: some View {
        ZStack{
            Button(action: {
                isPresented.toggle()
            }, label: {
                RoundedRectangle(cornerRadius: 8.5).fill(isDateInPast(date: todo.todoDeadline ?? Dates.defaultDate, defaultColor: Colors.primaryColor))
            }).buttonStyle(.plain)
            HStack{
                //Checkmark button
                Button(action: {
                    todo.todoIsDone.toggle()
                    if(todo.todoIsDone == true){
                        deleteUserNotification(identifier: todo.todoID!)
                    }
                    saveContext(context: viewContext)
                    }, label: {
                    if(todo.todoIsDone){
                        SystemImage(image: "checkmark.square.fill", color: .white, size: SystemImageSize, isActivated: true)
                    } else {
                        SystemImage(image: "square", color: .white, size: SystemImageSize, isActivated: true)
                    }
                })
                    .frame(width: SystemImageSize, height: SystemImageSize)
                    .buttonStyle(.plain)
                
                //Labelling
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
                
                //Information of content in ToDo
                if(todo.todoNotes != ""){
                    SystemImage(image: "note.text", color: .white, size: 15, isActivated: true)
                }
                if(hasImage()){
                    SystemImage(image: "photo.fill", color: .white, size: 15, isActivated: true)
                }
                if(!subToDos.isEmpty){
                    SystemImage(image: getNumberIcon(), color: .white, size: 15, isActivated: true)
                }
                //Show List Icon if ToDoListRow is in CalendarView
                if(rowType == .calendar){
                    SystemCircleIcon(image: lists[0].listSymbol ?? "list.bullet", size: 25, backgroundColor: getColorFromString(string: lists[0].listColor ?? "indigo"))
                }
                //IsMarked button
                Button(action: {
                    todo.todoIsMarked.toggle()
                    saveContext(context: viewContext)
                }, label: {
                    if(todo.todoIsMarked){
                        SystemImage(image: "star.fill", color: .yellow, size: 15, isActivated: true)
                    } else {
                        SystemImage(image: "star", color: .white, size: 15, isActivated: true)
                    }
                }).buttonStyle(.plain)
            }.padding(10)
            .sheet(isPresented: $isPresented) {
                DetailView(detailViewType: .edit, todo: todo, list: todo.todoList ?? "Error", listID: todo.idOfToDoList ?? UUID(), isPresented: $isPresented)
            }
        }
    }
    private func getNumberIcon()->String{
        let int = subToDos.count
        let iconName = "\(int).circle.fill"
        return iconName
    }
    private func hasImage()->Bool{
        if CoreDataToNSImageArray(coreDataObject: todo.todoImages)?.isEmpty ?? [].isEmpty{
            return false
        } else {
            return true
        }
    }
}


 
