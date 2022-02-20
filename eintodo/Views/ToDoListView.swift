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
        let fetchAttributes = filterToDo(us: userSelected, filterType: listFilterType)
        _todos = FetchRequest(sortDescriptors: fetchAttributes.sortDescriptors, predicate: fetchAttributes.predicate, animation: .default)
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
                                    Text("Erledigte einblenden")
                                        .padding(10)
                                        .foregroundColor(.gray)
                                        .overlay(
                                        RoundedRectangle(cornerRadius: 5)
                                            .stroke(Color.gray, lineWidth: 1)
                                        )
                                }).buttonStyle(.plain)
                                    .padding(.leading, 1)
                                Button(action: {
                                    withAnimation{
                                        for todo in todos{
                                            if todo.todoIsDone{
                                                viewContext.delete(todo)
                                                saveContext(context: viewContext)
                                            }
                                        }
                                    }
                                }, label: {
                                    Text("Alle Erledigten löschen")
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
    let SystemImageSize: CGFloat = 25
    @State var color: Color

    init(rowType: ToDoListRowType, todo: ToDo) {
        self.todo = todo
        let id = todo.todoID ?? UUID()
        _subToDos = FetchRequest(sortDescriptors: [], predicate: NSPredicate(format: "idOfMainToDo == %@", id as CVarArg), animation: .default)
        let listID = todo.idOfToDoList ?? UUID()
        _lists = FetchRequest(sortDescriptors: [], predicate: NSPredicate(format: "listID == %@", listID as CVarArg), animation: .default)
        self.rowType = rowType
        _color = State(initialValue: Colors.primaryColor)
    }

    var body: some View {
        if todo.todoIsDone && !userSelected.showDoneToDos{} else {
            ZStack{
                Button(action: {
                    isPresented.toggle()
                }, label: {
                    RoundedRectangle(cornerRadius: 8.5)
                        .fill(.ultraThinMaterial)
                        .shadow(color: color, radius: 3)
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
                            ZStack{
                                RoundedRectangle(cornerRadius: 5).fill(.white)
                                SystemImage(image: "checkmark.square.fill", color: color, size: SystemImageSize/5*4, isActivated: true)
                            }
                        } else {
                            SystemImage(image: "square", color: .gray, size: SystemImageSize, isActivated: true)
                        }
                    })
                        .frame(width: SystemImageSize/5*4, height: SystemImageSize/5*4)
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
                                SystemCircleIcon(image: "note.text", size: SystemImageSize, backgroundColor: color)
                            }
                            if(hasImage()){
                                SystemCircleIcon(image: "photo.fill", size: SystemImageSize, backgroundColor: color)
                            }
                            if(!subToDos.isEmpty){
                                SystemCircleIcon(image: getNumberIcon(), size: SystemImageSize, backgroundColor: color)
                            }
                            //Show List Icon if ToDoListRow is in CalendarView
                            if(rowType == .calendar){
                                SystemCircleIcon(image: lists.first?.listSymbol ?? "list.bullet", size: SystemImageSize, backgroundColor: getColorFromString(string: lists.first?.listColor ?? "standard"))
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
                        SystemCircleIcon(image: todo.todoIsMarked ? "star.fill" : "star", size: SystemImageSize, backgroundColor: todo.todoIsMarked ? .init(red: 250/255, green: 187/255, blue: 2/255) : .gray)
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


 
