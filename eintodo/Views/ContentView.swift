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
    @Environment(\.colorScheme) public var colorScheme


    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ToDo.title, ascending: true)],
        animation: .default)
    public var items: FetchedResults<ToDo>
    @State var showAddView: Bool = false

    var body: some View {
        NavigationView {
            List{
                NavigationLink(destination: CalendarView()){
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
                            AddView(showAddView: $showAddView)
                        }
                }
            }
            CalendarView()
            ListView()
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
