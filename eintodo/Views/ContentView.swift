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

    @State var showAddView: Bool = false
    
    @State var selectedView: Int? = 1
    
    //Communication between Views
    @EnvironmentObject private var userSelected: UserSelected

    var body: some View {
        NavigationView {
            List{
                NavigationLink(destination: Home(), tag: 0, selection: $selectedView){
                    HStack{
                        Image(systemName: "house")
                        Text("Start")
                    }
                }
                NavigationLink(destination: CalendarView(filter: .deadline), tag: 1, selection: $selectedView){
                    HStack{
                        Image(systemName: "calendar")
                        Text("Kalender")
                    }
                }
                NavigationLink(destination: ToDoListCollectionView(), tag: 2, selection: $selectedView){
                    HStack{
                        Image(systemName: "list.dash")
                        Text("Listen")
                    }
                }
                Spacer()
            }
            .listStyle(.sidebar)
            .frame(minWidth: 210)
            .toolbar {
                ToolbarItem {
                    Button(action:{
                        showAddView.toggle()
                    }, label: {
                        Label("Add Item", systemImage: "plus")
                    })
                        .sheet(isPresented: $showAddView){
                            DetailView(detailViewType: .add, todo: ToDo(), list: lists[0].listTitle! , listID: lists[0].listID!, isPresented: $showAddView)
                        }
                        .keyboardShortcut("n", modifiers: [.command])
                }
            }
        }
        //INITIALIZING FOR THE APP
        .onAppear{
            //Create a list if there is no lists at the beginning
            if lists.isEmpty{
                let newToDoList = ToDoList(context: viewContext)
                newToDoList.listID = UUID()
                newToDoList.listTitle = "Neue Liste"
                newToDoList.listDescription = "Eine Liste, wo man Erinnerungen hinzufügen kann"
                newToDoList.listColor = "indigo"
                newToDoList.listSymbol = "list.bullet"
                do{
                    try viewContext.save()
                }catch{
                    let nsError = error as NSError
                    fatalError("Could not add a first List in ContentView: \(nsError), \(nsError.userInfo)")
                }
            }
            
            //Set the first list as the selected to do list
            userSelected.selectedToDoList = lists[0].listTitle!
            userSelected.selectedToDoListID = lists[0].listID!
        }
        .onChange(of: deadlineTime){ newValue in
            for todo in todos{
                let formattedDate = combineDateAndTime(date: getDate(date: todo.todoDeadline!), time: getTime(date: deadlineTime))
                if todo.todoDeadline != Dates.defaultDate{
                    todo.todoDeadline = formattedDate
                    updateUserNotification(title: todo.todoTitle!, id: todo.todoID!, date: formattedDate, type: "deadline")
                }
                do{
                    try viewContext.save()
                }catch{
                    let nsError = error as NSError
                    fatalError("Could not update all to-dos due a change of AppStorage DeadlineTime in SettingsView: \(nsError), \(nsError.userInfo)")
                }
            }
        }
    }
}
