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
    @State var isSelected: Bool = false
    @State var showDoneToDos: Bool = false
    @State var listViewIsActive: Bool = false
    
    let day: Int = 3600*24
    
    var body: some View {
        NavigationView{
            VStack{
                VStack {
                    NavigationLink(destination: ListView(selectedDate: selectedDate, bool: $showDoneToDos), isActive: $listViewIsActive){ EmptyView() }
                }.hidden()
                ForEach(0...7, id: \.self){ dayValue in
                    Button(action: {
                        selectedDate = Date().addingTimeInterval(TimeInterval(day*dayValue))
                        self.listViewIsActive = true
                        self.isSelected = true
                    }){
                        if isSameDay(date1: Date(), date2: Date().addingTimeInterval(TimeInterval(day*dayValue))) {
                            Text(DateToStringFormatter(date: Date().addingTimeInterval(TimeInterval(day*dayValue))))
                                .foregroundColor(.blue)
                        } else {
                            Text(DateToStringFormatter(date: Date().addingTimeInterval(TimeInterval(day*dayValue))))
                        }
                    }
                }
            }
        }
        .navigationTitle("Kalender")
        .toolbar{
            ToolbarItem{
                Button("Alles löschen"){
                    deleteAllItems()
                }
            }
            ToolbarItem{
                Button(showDoneToDos ? "Erledigte ausblenden" : "Erledigte einblenden"){
                    showDoneToDos.toggle()
                }
            }
        }
    }
}
