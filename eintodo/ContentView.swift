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

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ToDo.timestamp, ascending: true)],
        animation: .default)
    public var items: FetchedResults<ToDo>
    @State var showAddView: Bool = false

    var body: some View {
        NavigationView {
            Text("Hallo")
            .toolbar {
                ToolbarItem {
                    Button(action:{
                        addItem()
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
