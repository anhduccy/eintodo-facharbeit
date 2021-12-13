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
        sortDescriptors: [NSSortDescriptor(keyPath: \ToDo.title, ascending: true)],
        animation: .default)
    public var todos: FetchedResults<ToDo>
    
    @State var showDetailView: Bool = false

    var body: some View {
        List{
            ForEach(todos, id: \.self){ todo in
                Button(todo.title ?? "Error"){
                    showDetailView.toggle()
                }
                .buttonStyle(.plain)
                .sheet(isPresented: $showDetailView){
                    DetailView(showDetailView: $showDetailView, title: todo.title ?? "Error")
                }
            }
        }
    }
}
