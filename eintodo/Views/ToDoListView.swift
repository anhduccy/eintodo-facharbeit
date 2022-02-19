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
        
        var sortDescriptor: [NSSortDescriptor] = [NSSortDescriptor()]
        var predicate: NSPredicate = NSPredicate()
        var predicateFormat: String = ""
        
        switch(listFilterType){
        case .dates: //To-Dos with deadline and/or notfication
            sortDescriptor =
                [NSSortDescriptor(keyPath: \ToDo.todoIsDone, ascending: true),
                NSSortDescriptor(keyPath: \ToDo.todoDeadline, ascending: true),
                NSSortDescriptor(keyPath: \ToDo.todoNotification, ascending: true)]
            predicateFormat = "(todoDeadline <= %@ && todoDeadline >= %@) || (todoNotification <= %@ && todoNotification >= %@)"
            predicate = NSPredicate(format: predicateFormat, dateTo! as CVarArg, dateFrom as CVarArg, dateTo! as CVarArg, dateFrom as CVarArg)
        case .noDates: //To-Dos without deadline and notification
            sortDescriptor =
                [NSSortDescriptor(keyPath: \ToDo.todoIsDone, ascending: true),
                NSSortDescriptor(keyPath: \ToDo.todoTitle, ascending: true)]
            predicateFormat = "todoDeadline == %@ && todoNotification == %@"
            predicate = NSPredicate(format: predicateFormat, defaultDate as CVarArg,  defaultDate as CVarArg)
        case .inPastAndNotDone: //All To-Dos in the past and which has not been done yet
            sortDescriptor =
                [NSSortDescriptor(keyPath: \ToDo.todoIsDone, ascending: true),
                NSSortDescriptor(keyPath: \ToDo.todoDeadline, ascending: true),
                NSSortDescriptor(keyPath: \ToDo.todoNotification, ascending: true)]
            predicateFormat = "todoDeadline < %@ && todoDeadline != %@"
            predicate = NSPredicate(format: predicateFormat, currentDate as CVarArg, defaultDate as CVarArg)
        case .marked:
            sortDescriptor =
                [NSSortDescriptor(keyPath: \ToDo.todoIsDone, ascending: true),
                NSSortDescriptor(keyPath: \ToDo.todoDeadline, ascending: true),
                NSSortDescriptor(keyPath: \ToDo.todoNotification, ascending: true)]
            predicateFormat = "todoIsMarked == true"
            predicate = NSPredicate(format: predicateFormat)
        case .all: //All To-Dos
            sortDescriptor = [ NSSortDescriptor(keyPath: \ToDo.todoIsDone, ascending: true),
                               NSSortDescriptor(keyPath: \ToDo.todoDeadline, ascending: true),
                               NSSortDescriptor(keyPath: \ToDo.todoNotification, ascending: true)]
        case .list:
            sortDescriptor = [NSSortDescriptor(keyPath: \ToDo.todoIsDone, ascending: true),
                               NSSortDescriptor(keyPath: \ToDo.todoDeadline, ascending: true),
                               NSSortDescriptor(keyPath: \ToDo.todoNotification, ascending: true)]
            predicateFormat = "idOfToDoList == %@"
            predicate = NSPredicate(format: predicateFormat, userSelected.selectedToDoListID as CVarArg)
        }
        _todos = FetchRequest(sortDescriptors: sortDescriptor, predicate: predicate, animation: .default)
        self.title = title
        self.rowType = rowType
    }
    let title: String
    let rowType: ToDoListRowType
    
    var body: some View {
        VStack{
            VStack(spacing: 10){
                LeftText(text: title, font: .largeTitle, fontWeight: .bold)
                List{
                    if(todos.isEmpty){
                        VStack{
                            LeftText(text: "Du hast noch nichts für den Tag geplant")
                                .foregroundColor(.gray)
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
        if todo.todoIsDone && !userSelected.showDoneToDos{} else {
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
                        LeftText(text: todo.todoTitle ?? "Error", font: .headline, fontWeight: .semibold)
                            .foregroundColor(text_color)
                        if todo.todoDeadline != Dates.defaultDate{
                            LeftText(text: DateInString(date: todo.todoDeadline ?? Dates.defaultDate, type: "deadline"), fontWeight: .light)
                                .foregroundColor(text_color)
                        }
                        if todo.todoNotification != Dates.defaultDate{
                            LeftText(text: DateInString(date: todo.todoNotification ?? Dates.defaultDate, type: "notification"), fontWeight: .light)
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
                    ToDoEditView(editViewType: .edit, todo: todo, list: todo.todoList ?? "Error", listID: todo.idOfToDoList ?? UUID(), isPresented: $isPresented)
                }
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


 
