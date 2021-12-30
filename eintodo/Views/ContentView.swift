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
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \ToDoList.listTitle, ascending: true)]) var lists: FetchedResults<ToDoList>

    @State var showAddView: Bool = false
    @State var showSettings: Bool = false
    
    //Communication between Views
    @EnvironmentObject public var userSelected: UserSelected
    @State var showDoneToDos: Bool = false

    var body: some View {
        NavigationView {
            List{
                NavigationLink(destination: CalendarView(showDoneToDos: $showDoneToDos, filter: .deadline)){
                    HStack{
                        Image(systemName: "calendar")
                        Text("Kalender")
                    }
                    Spacer()
                }
                NavigationLink(destination: ToDoListsView(showDoneToDos: $showDoneToDos)){
                    HStack{
                        Image(systemName: "list.dash")
                        Text("Listen")
                    }
                    Spacer()
                }
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
                            DetailView(detailViewType: .add, todo: ToDo(), list: lists[0].listTitle! , isPresented: $showAddView)
                        }
                        .keyboardShortcut("n", modifiers: [.command])
                }
                
                ToolbarItem{
                    Button(action: {
                        showSettings.toggle()
                    }, label:{
                        Label("Settings", systemImage: "gear")
                    })
                        .sheet(isPresented: $showSettings){
                            SettingsView(showSettings: $showSettings)
                        }
                }
            }
        }
        .onAppear{
            if lists.isEmpty{
                let newToDoList = ToDoList(context: viewContext)
                newToDoList.listID = UUID()
                newToDoList.listTitle = "Neue Liste"
                newToDoList.listDescription = "Eine Liste, wo man Erinnerungen hinzufügen kann"
                newToDoList.color = "indigo"
                newToDoList.symbol = "list.bullet"
                do{
                    try viewContext.save()
                }catch{
                    let nsError = error as NSError
                    fatalError("Could not add a first List in ContentView: \(nsError), \(nsError.userInfo)")
                }
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()
