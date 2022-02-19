//
//  ListView.swift
//  eintodo
//
//  Created by anh :) on 12.12.21.
//

import SwiftUI
import Foundation

struct ProgressCircle: View{
    let todos: FetchedResults<ToDo>
    var body: some View{
        HStack(spacing: 7.5){
            Text("\(progress().done)/\(progress().all)").bold().foregroundColor(.gray)
            ZStack{
                Circle()
                    .stroke(lineWidth: 6)
                    .opacity(0.2)
                    .foregroundColor(Colors.primaryColor)
                Circle()
                    .trim(from: 0.0, to: progress().percentage)
                    .stroke(style: StrokeStyle(lineWidth: 6, lineCap: .round, lineJoin: .round))
                    .foregroundColor(Colors.primaryColor)
                    .rotationEffect(Angle(degrees: 270))
            }
            .frame(width: 30, height: 30)
        }
    }
    private func progress()->(percentage: CGFloat, done: Int, all: Int){
        var doneToDo = 0
        let allToDo = todos.count
        for todo in todos{
            if todo.todoIsDone{
                doneToDo += 1
            }
        }
        var percentage: Double = 0
        if(allToDo != 0){
            percentage = Double(doneToDo) / Double(allToDo)
        }
        return (percentage, doneToDo, allToDo)
    }
}

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
                HStack{
                    LeftText(text: title, font: .largeTitle, fontWeight: .bold)
                    Spacer()
                    if(!todos.isEmpty){
                        ProgressCircle(todos: todos)
                    }
                }.padding(.leading, 7.5)
                List{
                    if(todos.isEmpty){
                        VStack{
                            LeftText(text: "Du hast noch nichts für den Tag geplant")
                                .foregroundColor(.gray)
                        }
                    } else if(isAllDone() && !userSelected.showDoneToDos){
                        VStack{
                            LeftText(text: "Du hast alle Erinnerungen bereits erledigt")
                                .foregroundColor(.gray)
                            HStack{
                                Button(action: {
                                    withAnimation{
                                        userSelected.showDoneToDos.toggle()
                                    }
                                }, label: {
                                    Text("Erledigte Erinnerungen einblenden")
                                        .padding(10)
                                        .foregroundColor(.gray)
                                        .overlay(
                                        RoundedRectangle(cornerRadius: 5)
                                            .stroke(Color.gray, lineWidth: 1)
                                        )
                                }).buttonStyle(.plain)
                                    .padding(.leading, 1)
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
                        .padding(.top, 3)
                        .padding(.bottom, 3)
                        .padding(.trailing, 12.5)
                        .padding(.leading, 12.5)
                    }
                }
            }
            .listStyle(.plain)
        }
        .padding()
        .frame(minWidth: 375)
        .background(colorScheme == .dark ? .clear : .white)
    }
    public func isAllDone()->Bool{
        var item = 0
        for todo in todos{
            if todo.todoIsDone{
                item += 1
            }
        }
        if item == todos.count{
            return true
        } else {
            return false
        }
    }
}

//Subviews
struct ToDoListRow: View {
    @Environment(\.managedObjectContext) public var viewContext
    @Environment(\.colorScheme) var appearance
    @EnvironmentObject private var userSelected: UserSelected
    @FetchRequest var lists: FetchedResults<ToDoList>
    @FetchRequest var subToDos: FetchedResults<SubToDo>
    
    @ObservedObject var todo: ToDo
    @State var isPresented: Bool = false
    
    let rowType: ToDoListRowType
    let SystemImageSize: CGFloat = 20

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
                    RoundedRectangle(cornerRadius: 8.5)
                        .fill(.ultraThinMaterial)
                        .shadow(color: .blue, radius: 3)
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
                            SystemImage(image: "checkmark.square.fill", color: .blue, size: SystemImageSize, isActivated: true)
                        } else {
                            SystemImage(image: "square", color: .gray, size: SystemImageSize, isActivated: true)
                        }
                    })
                        .frame(width: SystemImageSize, height: SystemImageSize)
                        .buttonStyle(.plain)
                    
                    Button(action: {
                        isPresented.toggle()
                    }, label: {
                        //Labelling
                        VStack(spacing: 1){
                            LeftText(text: todo.todoTitle ?? "Error", font: .headline, fontWeight: .semibold)
                            if todo.todoDeadline != Dates.defaultDate{
                                LeftText(text: DateInString(date: todo.todoDeadline ?? Dates.defaultDate, type: "deadline"), fontWeight: .light)
                                    .foregroundColor(isDateInPast(date: todo.todoDeadline ?? Dates.defaultDate, defaultColor: .gray))
                            }
                            if todo.todoNotification != Dates.defaultDate{
                                LeftText(text: DateInString(date: todo.todoNotification ?? Dates.defaultDate, type: "notification"),  fontWeight: .light)
                                    .foregroundColor(.gray)
                            }
                        }
                        HStack(spacing: 4.5){
                            //Information of content in ToDo
                            if(todo.todoNotes != ""){
                                SystemCircleIcon(image: "note.text", size: 25, backgroundColor: Colors.primaryColor)
                            }
                            if(hasImage()){
                                SystemCircleIcon(image: "photo.fill", size: 25, backgroundColor: Colors.primaryColor)
                            }
                            if(!subToDos.isEmpty){
                                SystemCircleIcon(image: getNumberIcon(), size: 25, backgroundColor: Colors.primaryColor)
                            }
                            //Show List Icon if ToDoListRow is in CalendarView
                            if(rowType == .calendar){
                                SystemCircleIcon(image: lists[0].listSymbol ?? "list.bullet", size: 25, backgroundColor: getColorFromString(string: lists[0].listColor ?? "indigo"))
                            }
                        }
                    }).buttonStyle(.plain)
                    
                    //IsMarked button
                    Button(action: {
                        withAnimation{
                            todo.todoIsMarked.toggle()
                            saveContext(context: viewContext)
                        }
                    }, label: {
                        SystemCircleIcon(image: todo.todoIsMarked ? "star.fill" : "star", size: 25, backgroundColor: .init(red: 250/255, green: 187/255, blue: 2/255))
                    }).buttonStyle(.plain)
                }.padding(12.5)
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


 
