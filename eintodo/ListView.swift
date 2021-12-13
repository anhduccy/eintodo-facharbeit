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
    
    var body: some View {
        NavigationView{
            List (todos, id: \.self){ todo in
                 NavigationLink(destination:
                                    DetailView(todo: todo, title: todo.title ?? "Error", deadline: todo.deadline ?? Date(timeIntervalSince1970: 0), notification: todo.notification ?? Date(timeIntervalSince1970: 0))) {
                         Text(todo.title ?? "Error")
                             .buttonStyle(.plain)
                 }
             }
        }
    }
}

