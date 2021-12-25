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
    @FetchRequest var todos: FetchedResults<ToDo>
    
    @Binding var selectedDate: Date
    @Binding var lastSelectedDate: Date
    @Binding var showDoneToDos: Bool
    
    init(date: Date, bool: Binding<Bool>, selectedDate: Binding<Date>, lastSelectedDate: Binding<Date>, type: ListViewTypes = ListViewTypes.dates){
        let calendar = Calendar.current
        let dateFrom = calendar.startOfDay(for: date)
        let dateTo = calendar.date(byAdding: .day, value: 1, to: dateFrom)
        
        switch(type){
        case .dates:
            _todos = FetchRequest(
                sortDescriptors: [
                    NSSortDescriptor(keyPath: \ToDo.isDone, ascending: true),
                    NSSortDescriptor(keyPath: \ToDo.deadline, ascending: true),
                    NSSortDescriptor(keyPath: \ToDo.notification, ascending: true)],
                    predicate: NSPredicate(format: "deadline <= %@ && deadline >= %@", dateTo! as CVarArg, dateFrom as CVarArg),
                animation: .default)
        case .noDates:
            let defaultDate = Dates.defaultDate
            _todos = FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \ToDo.title, ascending: true)], predicate: NSPredicate(format: "deadline == %@", defaultDate as CVarArg), animation: .default)
            print("2", _todos, "\n")
        
        case .all:
            _todos = FetchRequest(sortDescriptors: [
                NSSortDescriptor(keyPath: \ToDo.isDone, ascending: true),
                NSSortDescriptor(keyPath: \ToDo.deadline, ascending: true),
                NSSortDescriptor(keyPath: \ToDo.notification, ascending: true)], animation: .default)
        }
        _showDoneToDos = bool
        _selectedDate = selectedDate
        _lastSelectedDate = lastSelectedDate
    }
    
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
                            SheetButton(todo, selectedDate: $selectedDate)
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
                        .background(missedDeadlineOfToDo(date: todo.deadline ?? Dates.defaultDate, defaultColor: Colors.primaryColor))
                        .cornerRadius(8.5)
                    }
                }
                if(todos.isEmpty){
                    VStack{
                        Spacer()
                        HStack{
                            Spacer()
                            Text("Keine Erinnerungen vorhanden")
                            Spacer()
                        }
                    }
                }
            }
        .listStyle(InsetListStyle())
        .frame(minWidth: 250)
    }
}
