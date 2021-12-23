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
    
    init(selectedDate: Date){
        let calendar = Calendar.current
        let dateFrom = calendar.startOfDay(for: selectedDate)
        let dateTo = calendar.date(byAdding: .day, value: 1, to: dateFrom)
        
        if(selectedDate != Date(timeIntervalSince1970: 0)){
            _todos = FetchRequest(
                sortDescriptors: [
                    NSSortDescriptor(keyPath: \ToDo.isDone, ascending: true),
                    NSSortDescriptor(keyPath: \ToDo.deadline, ascending: true),
                    NSSortDescriptor(keyPath: \ToDo.notification, ascending: true)],
                    predicate: NSPredicate(format: "deadline <= %@ && deadline >= %@", dateTo! as CVarArg, dateFrom as CVarArg),
                animation: .default)
        } else {
            _todos = FetchRequest(sortDescriptors: [
                NSSortDescriptor(keyPath: \ToDo.isDone, ascending: true),
                NSSortDescriptor(keyPath: \ToDo.deadline, ascending: true),
                NSSortDescriptor(keyPath: \ToDo.notification, ascending: true)], animation: .default)
        }
    }
    @FetchRequest var todos: FetchedResults<ToDo>
    
    @State var showDoneToDos: Bool = false
    
    let SystemImageSize: CGFloat = 17.5
    
    var body: some View {
        List{
            //ListView
            ForEach(todos, id: \.self){ todo in
                //ListItem
                if(showDoneToDos || !todo.isDone){
                    HStack{
                        //Checkmark button
                        Button(action: {
                            todo.isDone.toggle()
                            updateToDo()
                            }, label: {
                            if(todo.isDone){
                                SystemImage(image: "checkmark.square.fill", size: SystemImageSize, color: .white)
                            } else {
                                SystemImage(image: "square", size: SystemImageSize, color: .white)
                            }
                        })
                            .frame(width: SystemImageSize, height: SystemImageSize)
                            .buttonStyle(.plain)
                            .padding(.leading, 5)
                        
                        //Labelling
                        SheetButton(todo)
                        Spacer()
                        Button(action: {
                            todo.isMarked.toggle()
                            updateToDo()
                        }, label: {
                            if(todo.isMarked){
                                SystemImage(image: "star.fill", size: 15, color: .yellow)
                                    .padding(5)
                            } else {
                                SystemImage(image: "star", size: 15, color: .white)
                                    .padding(5)
                            }
                        })
                            .buttonStyle(.plain)
                    }
                    .padding(5)
                    .background(missedDeadlineOfToDo(date: todo.deadline ?? Date(timeIntervalSince1970: 0), defaultColor: Colors.primaryColor))
                    .cornerRadius(8.5)
                }
            }
        }
        .listStyle(InsetListStyle())
        .toolbar{
            ToolbarItem{
                Button(showDoneToDos ? "Erledigte ausblenden" : "Erledigte einblenden"){
                    showDoneToDos.toggle()
                }
                .buttonStyle(.plain)
                .foregroundColor(.blue)

            }
        }
    }
}
