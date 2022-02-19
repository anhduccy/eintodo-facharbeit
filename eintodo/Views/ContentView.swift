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
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \ToDo.todoTitle, ascending: true)]) var todos: FetchedResults<ToDo>
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \ToDoList.listTitle, ascending: true)]) var lists: FetchedResults<ToDoList>

    //Show view attributes
    @State var showAddView: Bool = false
    @State var showToDoListCollectionEditView: Bool = false

    //Communication between Views
    @EnvironmentObject private var userSelected: UserSelected

    var body: some View {
        NavigationView {
            List{
                Section{
                    NavigationLink(destination: Home(), tag: 0, selection: $userSelected.selectedView){
                        HStack{
                            Image(systemName: "house")
                            Text("Start")
                        }
                    }
                    NavigationLink(destination: CalendarView(filter: .deadline), tag: 1, selection: $userSelected.selectedView){
                        HStack{
                            Image(systemName: "calendar")
                            Text("Kalender")
                        }
                    }
                }
                
                Section(header: Text("Meine Listen")){
                    ForEach(Array(zip(lists.indices, lists)), id: \.1){ index, list in
                        NavigationLink(
                            destination: ToDoListView(title: userSelected.selectedToDoList, rowType: .list, listFilterType: .list, userSelected: userSelected)
                                .onAppear{
                                    userSelected.selectedToDoList = list.listTitle ?? "Error"
                                    userSelected.selectedToDoListID = list.listID ?? UUID()
                                },
                            tag: index + 2,
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
            .frame(minWidth: 200)
            .toolbar{
                ToolbarItemGroup(placement: .automatic){
                    Spacer()
                    Button(action:{
                        showAddView.toggle()
                    }, label: {
                        Label("Add ToDo", systemImage: "checkmark.circle.fill")
                    })
                        .sheet(isPresented: $showAddView){
                            ToDoEditView(editViewType: .add, todo: ToDo(), list: lists[0].listTitle! , listID: lists[0].listID!, isPresented: $showAddView)
                        }
                        .keyboardShortcut("n", modifiers: [.command])
                    Button(action: {
                        showToDoListCollectionEditView.toggle()
                    }, label: {
                        Label("Add ToDo", systemImage: "list.bullet")

                    })
                    .sheet(isPresented: $showToDoListCollectionEditView){
                        ToDoListCollectionEditView(type: .add, isPresented: $showToDoListCollectionEditView, toDoList: ToDoList())
                    }
                }
                ToolbarItem(placement: .primaryAction){
                    Button(userSelected.showDoneToDos ? "Erledigte ausblenden" : "Erledigte einblenden"){
                        userSelected.showDoneToDos.toggle()
                    }
                }
            }
        }
        //INITIALIZING FOR THE APP
        .onAppear{
            //Create a list if there is no lists at the beginning
            if(lists.isEmpty){createList(viewContext: viewContext)}
            
            //Set the first list as the selected to do list
            userSelected.selectedToDoList = lists[0].listTitle ?? ""
            userSelected.selectedToDoListID = lists[0].listID ?? UUID()
            
            askForUserNotificationPermission()
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
