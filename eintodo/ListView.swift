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
            List{
                ForEach(todos, id: \.self){ todo in
                //List item
                    NavigationLink(destination:
                                        DetailView(todo: todo, title: todo.title ?? "Error", deadline: todo.deadline ?? Date(timeIntervalSince1970: 0), notification: todo.notification ?? Date(timeIntervalSince1970: 0))) {
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
                                    Image(systemName: "checkmark.circle.fill")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                } else {
                                    Image(systemName: "circle")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                }
                            })
                                .frame(width: 20, height: 20)
                                .buttonStyle(.plain)
                                .padding(1)
                            
                            //Labelling
                            VStack{
                                HStack{
                                    Text(todo.title ?? "Error")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                    Spacer()
                                }
                                HStack{
                                    if todo.deadline != Date(timeIntervalSince1970: 0){
                                            Text("Fällig am " + DateToStringFormatter(date: todo.deadline ?? Date(timeIntervalSince1970: 0)))
                                            .foregroundColor(.gray)
                                    }
                                    Spacer()
                                }
                                HStack{
                                    if todo.notification != Date(timeIntervalSince1970: 0){
                                        Text(DateToStringFormatter(date: todo.notification ?? Date(timeIntervalSince1970: 0)))
                                            .foregroundColor(.gray)
                                        
                                    }
                                    Spacer()
                                }
                            }
                        }
                        .padding(.top, 2)
                        .padding(.bottom, 2)
                    }
                }
            }
            .listStyle(InsetListStyle())
            
        }
    }
}

