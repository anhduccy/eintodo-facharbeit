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

    var body: some View {
        NavigationView {
            List{
                NavigationLink(destination: CalendarView(selectedDate: $selectedDate, lastSelectedDate: $lastSelectedDate)){
                    HStack{
                        Image(systemName: "calendar")
                        Text("Kalender")
                    }
                    Spacer()
                }
            }
            .listStyle(.sidebar)
            .toolbar {
                ToolbarItem {
                    Button(action:{
                        showAddView.toggle()
                    }, label: {
                        Label("Add Item", systemImage: "plus")
                    })
                        .sheet(isPresented: $showAddView){
                            AddView(showAddView: $showAddView, selectedDate: $selectedDate)
                        }
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
