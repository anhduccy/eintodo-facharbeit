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
            if(bool.wrappedValue == true){
                _todos = FetchRequest(
                    sortDescriptors: [
                        NSSortDescriptor(keyPath: \ToDo.isDone, ascending: true),
                        NSSortDescriptor(keyPath: \ToDo.deadline, ascending: true),
                        NSSortDescriptor(keyPath: \ToDo.notification, ascending: true)],
                        predicate: NSPredicate(format: "(deadline <= %@ && deadline >= %@) || (notification <= %@ && notification >= %@)", dateTo! as CVarArg, dateFrom as CVarArg, dateTo! as CVarArg, dateFrom as CVarArg),
                    animation: .default)
            } else {
                _todos = FetchRequest(
                    sortDescriptors: [
                        NSSortDescriptor(keyPath: \ToDo.isDone, ascending: true),
                        NSSortDescriptor(keyPath: \ToDo.deadline, ascending: true),
                        NSSortDescriptor(keyPath: \ToDo.notification, ascending: true)],
                        predicate: NSPredicate(format: "(deadline <= %@ && deadline >= %@) || (notification <= %@ && notification >= %@) && isDone == false", dateTo! as CVarArg, dateFrom as CVarArg, dateTo! as CVarArg, dateFrom as CVarArg),
                    animation: .default)
            }
        case .noDates:
            let defaultDate = Dates.defaultDate
            _todos = FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \ToDo.title, ascending: true)], predicate: NSPredicate(format: "deadline == %@", defaultDate as CVarArg), animation: .default)
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
            if(todos.isEmpty){
                VStack{
                    HStack{
                        Spacer()
                        Text("Keine Erinnerungen ausgewählt")
                        Spacer()
                    }
                }
            }
            //ListView
            ForEach(todos, id: \.self){ todo in
                //ListItem
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
                .background(isDateInPast(date: todo.deadline ?? Dates.defaultDate, defaultColor: Colors.primaryColor))
                .cornerRadius(8.5)
            }
            .listStyle(InsetListStyle())
            .frame(minWidth: 250)
        }
    }
}

//ListView
extension ListView {
    public func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { todos[$0] }.forEach(viewContext.delete)
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Could not delete ListItem as CoreData-Entity in ListView \(nsError), \(nsError.userInfo)")
            }
        }
    }
    public func updateToDo(){
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Could not update CoreData-Entity in ListView: \(nsError), \(nsError.userInfo)")
        }
    }
}

