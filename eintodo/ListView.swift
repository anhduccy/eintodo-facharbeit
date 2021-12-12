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

    var body: some View {
        NavigationView{
            List(todos, id: \.self){ todo in
                NavigationLink(destination:
                {
                    DetailView()
                }, label: {
                    VStack{
                        Text(todo.title ?? "Error")
                            .fontWeight(.bold)
                    }
                })
            }
        }
    }
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        ListView()
    }
}
