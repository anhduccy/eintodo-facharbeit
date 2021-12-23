//
//  CalendarView.swift
//  eintodo
//
//  Created by anh :) on 12.12.21.
//

import SwiftUI

struct CalendarView: View {
    @Environment(\.managedObjectContext) public var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ToDo.title, ascending: true)],
        animation: .default)
    public var todos: FetchedResults<ToDo>
    
    @State var selectedDate: Date = Date()
    
    var body: some View {
        NavigationView{
            
            NavigationLink(destination: ListView(selectedDate: Date(timeIntervalSince1970: 0))){
                Text("CalendarView")
            }
        }
        .navigationTitle("CalendarView")
        .toolbar{
            ToolbarItem{
                Button("Alles löschen"){
                    deleteAllItems()
                }
            }
        }
    }
}
