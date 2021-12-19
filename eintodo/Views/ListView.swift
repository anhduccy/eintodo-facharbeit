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
        sortDescriptors: [NSSortDescriptor(keyPath: \ToDo.deadline, ascending: true)],
        animation: .default)
    public var todos: FetchedResults<ToDo>
    let SystemImageSize: CGFloat = 17.5
    
    var body: some View {
        List{
            ForEach(todos, id: \.self){ todo in
                //ListItem
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
                            SystemImage(image: "checkmark.square.fill", size: SystemImageSize, color: .white)
                        } else {
                            SystemImage(image: "checkmark.square", size: SystemImageSize, color: .white)
                        }
                    })
                        .frame(width: SystemImageSize, height: SystemImageSize)
                        .buttonStyle(.plain)
                        .padding(.leading, 5)
                    
                    //Labelling
                    SheetButton(todo)
                }
                .padding(5)
                .background(.blue)
                .cornerRadius(8.5)
            }
        }
        .listStyle(InsetListStyle())
    }
}

