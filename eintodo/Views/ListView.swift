//
//  ListView.swift
//  eintodo
//
//  Created by anh :) on 12.12.21.
//

import SwiftUI
import Foundation

struct ListView: View {
    @Environment(\.managedObjectContext) public var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ToDo.title, ascending: true)],
        animation: .default)
    public var todos: FetchedResults<ToDo>
    
    var body: some View {
        NavigationView{
            List{
                ForEach(todos, id: \.self){ todo in
                    HStack{
                        //Checkmark button
                        Button(action: {
                            todo.isDone.toggle()
                            do {
                                try viewContext.save()
                            } catch {
                                let nsError = error as NSError
                                fatalError("Could not add CoreData-Entity in AddView \(nsError), \(nsError.userInfo)")
                            }
                            }, label: {
                            if(todo.isDone){
                                SystemImage(image: "checkmark.square.fill", size: 15)
                            } else {
                                SystemImage(image: "checkmark.square", size: 15)
                                    
                            }
                        })
                            .frame(width: 20, height: 20)
                            .buttonStyle(.plain)
                            .padding(1)
                        
                        SheetButton(todo)
                    }
                }
            }
            .listStyle(InsetListStyle())
        }
    }
}

