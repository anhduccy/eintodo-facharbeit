//
//  ListView.swift
//  eintodo
//
//  Created by anh :) on 12.12.21.
//

import SwiftUI

struct ListView: View {
    @Environment(\.managedObjectContext) public var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ToDo.timestamp, ascending: true)],
        animation: .default)
    public var todos: FetchedResults<ToDo>
    
    @State var showDetailView: Bool = false

    var body: some View {
        List(todos, id: \.self){ todo in
            Button(todo.title ?? "Error"){
                showDetailView.toggle()
            }
            .sheet(isPresented: $showDetailView){
                DetailView(showDetailView: $showDetailView, title: todo.title ?? "Error", deadline: todo.deadline ?? Date())
            }
        }
    }
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        ListView()
    }
}
