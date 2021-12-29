//
//  ContentView.swift
//  eintodo
//
//  Created by anh :) on 12.12.21.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @State var showAddView: Bool = false
    @State var showSettings: Bool = false
    @State var selectedDate: Date = Date()
    @State var lastSelectedDate: Date = Dates.defaultDate
    @State var showDoneToDos: Bool = false

    var body: some View {
        NavigationView {
            List{
                NavigationLink(destination: CalendarView(selectedDate: $selectedDate, lastSelectedDate: $lastSelectedDate, showDoneToDos: $showDoneToDos, filter: .deadline)){
                    HStack{
                        Image(systemName: "calendar")
                        Text("Kalender")
                    }
                    Spacer()
                }
                NavigationLink(destination: ToDoListsView(showDoneToDos: $showDoneToDos)){
                    HStack{
                        Image(systemName: "list.dash")
                        Text("Alle Listen")
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
                            DetailView(detailViewType: .add, todo: ToDo(), title: "", notes: "", deadline: Date(), notification: Date(), isMarked: false, priority: 0, list: "", isPresented: $showAddView, selectedDate: $selectedDate)
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

    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()
