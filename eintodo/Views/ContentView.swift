//
//  ContentView.swift
//  eintodo
//
//  Created by anh :) on 12.12.21.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) public var viewContext
    @AppStorage("deadlineTime") private var deadlineTime: Date = Date()
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \ToDoList.listTitle, ascending: true)]) var lists: FetchedResults<ToDoList>
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \ToDo.todoTitle, ascending: true)]) var todos: FetchedResults<ToDo>
    @FetchRequest(sortDescriptors: []) var subtodos: FetchedResults<SubToDo>

    //Show view attributes
    @State var showAddView: Bool = false
    @State var showToDoListCollectionEditView: Bool = false

    //Communication between Views
    @EnvironmentObject private var userSelected: UserSelected

    var body: some View {
        NavigationView {
            List{
                NavigationLink(destination: Home(), tag: 0, selection: $userSelected.selectedView){
                    HStack{
                        Image(systemName: "house")
                            .foregroundColor(userSelected.selectedView == 0 ? .white : Colors.primaryColor)
                        Text("Start")
                    }
                }
                NavigationLink(destination: CalendarView(filter: .deadline), tag: 1, selection: $userSelected.selectedView){
                    HStack{
                        Image(systemName: "calendar")
                            .foregroundColor(userSelected.selectedView == 1 ? .white : Colors.primaryColor)
                        Text("Kalender")
                    }
                }
                
                Section("Sortierte Listen"){
                    ToDoListCollectionDefaultRow(us: userSelected, title: "Alle", systemName: "tray.2", tag: 2, filter: .all)
                    ToDoListCollectionDefaultRow(us: userSelected, title: "Fällig", systemName: "clock", tag: 3, filter: .inPast)
                    ToDoListCollectionDefaultRow(us: userSelected, title: "Markiert", systemName: "star", tag: 4, filter: .marked)
                }
                
                Section(header: Text("Meine Listen")){
                    ForEach(Array(zip(lists.indices, lists)), id: \.1){ index, list in
                        NavigationLink(
                            destination: ToDoListView(title: userSelected.selectedToDoList, rowType: .list, listFilterType: .list, userSelected: userSelected)
                                .onAppear{
                                    userSelected.selectedToDoList = list.listTitle ?? "Error"
                                    userSelected.selectedToDoListID = list.listID ?? UUID()
                                },
                            tag: index + 5,
                            selection: $userSelected.selectedView
                        ){
                            HStack{
                                ToDoListCollectionRow(list: list)
                            }
                        }
                    }
                }
            }
            .listStyle(.sidebar)
            .frame(minWidth: 175)
            .toolbar{
                ToolbarItemGroup(placement: .automatic){
                    Menu(content: {
                        Button(action:{
                            showAddView.toggle()
                        }, label: {
                            Label("Erinnerung hinzufügen", systemImage: "checkmark.circle.fill")
                        })
                        Button(action: {
                            showToDoListCollectionEditView.toggle()
                        }, label: {
                            Label("Liste hinzufügen", systemImage: "list.bullet")
                        })
                    }, label: {
                        Image(systemName: "plus.circle")
                    })
                }
                ToolbarItem(placement: .primaryAction){
                    Button(userSelected.showDoneToDos ? "Erledigte ausblenden" : "Erledigte einblenden"){
                        userSelected.showDoneToDos.toggle()
                    }
                }
            }
        }
        .sheet(isPresented: $showAddView){
            ToDoEditView(editViewType: .add, todo: ToDo(), list: lists.first!.listTitle! , listID: lists.first!.listID!, isPresented: $showAddView)
        }
        .sheet(isPresented: $showToDoListCollectionEditView){
            ToDoListCollectionEditView(type: .add, isPresented: $showToDoListCollectionEditView, toDoList: ToDoList())
        }
        //INITIALIZING FOR THE APP
        .onAppear{
            //Create a list if there is no lists at the beginning
            if(lists.isEmpty){createList(viewContext: viewContext)}
            
            //Set the first list as the selected to do list
            userSelected.selectedToDoList = lists.first?.listTitle ?? ""
            userSelected.selectedToDoListID = lists.first?.listID ?? UUID()
            
            askForUserNotificationPermission()
            for todo in todos{
                if todo.todoID == nil {
                    viewContext.delete(todo)
                    saveContext(context: viewContext)
                }
            }
        }
        .onChange(of: deadlineTime){ newValue in
            for todo in todos{
                let formattedDate = combineDateAndTime(date: getDate(date: todo.todoDeadline!), time: getTime(date: deadlineTime))
                if todo.todoDeadline != Dates.defaultDate{
                    todo.todoDeadline = formattedDate
                    updateUserNotification(title: todo.todoTitle!, id: todo.todoID!, date: formattedDate, type: "deadline")
                }
                saveContext(context: viewContext)
            }
        }
    }
}
