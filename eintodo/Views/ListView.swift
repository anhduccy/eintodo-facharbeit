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
    @EnvironmentObject private var userSelected: UserSelected
    @FetchRequest var todos: FetchedResults<ToDo>
    
    //Communication between views
    @Binding var showDoneToDos: Bool
    
    init(type: ListViewTypes = ListViewTypes.dates, showDoneToDos: Binding<Bool>, userSelected: UserSelected){
        

        let calendar = Calendar.current
        let dateFrom = calendar.startOfDay(for: userSelected.lastSelectedDate)
        let dateTo = calendar.date(byAdding: .minute, value: 1439, to: dateFrom)
        let defaultDate = Dates.defaultDate
        let currentDate = Date()
        
        switch(type){
        case .dates: //To-Dos with deadline and/or notfication
            if(showDoneToDos.wrappedValue == true){
                _todos = FetchRequest(
                    sortDescriptors: [
                        NSSortDescriptor(keyPath: \ToDo.isDone, ascending: true),
                        NSSortDescriptor(keyPath: \ToDo.deadline, ascending: true),
                        NSSortDescriptor(keyPath: \ToDo.notification, ascending: true)],
                    predicate: NSPredicate(format: "(deadline <= %@ && deadline >= %@) || (notification <= %@ && notification >= %@)", dateTo! as CVarArg, dateFrom as CVarArg, dateTo! as CVarArg, dateFrom as CVarArg),
                    animation: .default)
            } else { //To-Dos with deadline and/or notfication and show done to-dos is false
                _todos = FetchRequest(
                    sortDescriptors: [
                        NSSortDescriptor(keyPath: \ToDo.isDone, ascending: true),
                        NSSortDescriptor(keyPath: \ToDo.deadline, ascending: true),
                        NSSortDescriptor(keyPath: \ToDo.notification, ascending: true)],
                    predicate: NSPredicate(format: "(deadline <= %@ && deadline >= %@) || (notification <= %@ && notification >= %@) && isDone == false", dateTo! as CVarArg, dateFrom as CVarArg, dateTo! as CVarArg, dateFrom as CVarArg),
                    animation: .default)
            }
        
        case .noDates: //To-Dos without deadline and notification
            if(showDoneToDos.wrappedValue == true){
                _todos = FetchRequest(
                    sortDescriptors: [
                        NSSortDescriptor(keyPath: \ToDo.isDone, ascending: true),
                        NSSortDescriptor(keyPath: \ToDo.title, ascending: true)],
                    predicate: NSPredicate(format: "deadline == %@ && notification == %@",
                                           defaultDate as CVarArg,  defaultDate as CVarArg),
                    animation: .default)
            } else { //To-Dos without deadline and notfication and show done to-dos is false
                _todos = FetchRequest(
                    sortDescriptors: [
                        NSSortDescriptor(keyPath: \ToDo.title, ascending: true)],
                    predicate: NSPredicate(format: "deadline == %@ && notification == %@ && isDone == false",
                                           defaultDate as CVarArg, defaultDate as CVarArg),
                    animation: .default)
            }
        case .inPastAndNotDone: //All To-Dos in the past and which has not been done yet
            if(showDoneToDos.wrappedValue == true){
                _todos = FetchRequest(
                    sortDescriptors: [
                        NSSortDescriptor(keyPath: \ToDo.isDone, ascending: true),
                        NSSortDescriptor(keyPath: \ToDo.deadline, ascending: true),
                        NSSortDescriptor(keyPath: \ToDo.notification, ascending: true)],
                    predicate: NSPredicate(format: "deadline < %@ && deadline != %@", currentDate as CVarArg, defaultDate as CVarArg),
                    animation: .default)
            } else {
                _todos = FetchRequest(
                    sortDescriptors: [
                        NSSortDescriptor(keyPath: \ToDo.isDone, ascending: true),
                        NSSortDescriptor(keyPath: \ToDo.deadline, ascending: true),
                        NSSortDescriptor(keyPath: \ToDo.notification, ascending: true)],
                    predicate: NSPredicate(format: "deadline < %@ && deadline != %@ && isDone == false", currentDate as CVarArg, defaultDate as CVarArg),
                    animation: .default)
            }
        case .marked:
            if(showDoneToDos.wrappedValue == true){
                _todos = FetchRequest(
                    sortDescriptors: [
                        NSSortDescriptor(keyPath: \ToDo.isDone, ascending: true),
                        NSSortDescriptor(keyPath: \ToDo.deadline, ascending: true),
                        NSSortDescriptor(keyPath: \ToDo.notification, ascending: true)],
                    predicate: NSPredicate(format: "isMarked == true"),
                    animation: .default)
            } else {
                _todos = FetchRequest(
                    sortDescriptors: [
                        NSSortDescriptor(keyPath: \ToDo.isDone, ascending: true),
                        NSSortDescriptor(keyPath: \ToDo.deadline, ascending: true),
                        NSSortDescriptor(keyPath: \ToDo.notification, ascending: true)],
                    predicate: NSPredicate(format: "isMarked == true && isDone == false"),
                    animation: .default)
            }
        case .all: //All To-Dos
            if(showDoneToDos.wrappedValue == true){
                _todos = FetchRequest(sortDescriptors: [
                    NSSortDescriptor(keyPath: \ToDo.isDone, ascending: true),
                    NSSortDescriptor(keyPath: \ToDo.deadline, ascending: true),
                    NSSortDescriptor(keyPath: \ToDo.notification, ascending: true)], animation: .default)
            } else { //All To-Dos which has not been done yet
                _todos = FetchRequest(sortDescriptors: [
                    NSSortDescriptor(keyPath: \ToDo.isDone, ascending: true),
                    NSSortDescriptor(keyPath: \ToDo.deadline, ascending: true),
                    NSSortDescriptor(keyPath: \ToDo.notification, ascending: true)],
                                      predicate: NSPredicate(format: "isDone == false"), animation: .default)
            }
        case .list:
            if(showDoneToDos.wrappedValue == true){
                _todos = FetchRequest(sortDescriptors: [
                    NSSortDescriptor(keyPath: \ToDo.isDone, ascending: true),
                    NSSortDescriptor(keyPath: \ToDo.deadline, ascending: true),
                    NSSortDescriptor(keyPath: \ToDo.notification, ascending: true)], predicate: NSPredicate(format: "list == %@", userSelected.selectedToDoList), animation: .default)
            } else { //All To-Dos which has not been done yet
                _todos = FetchRequest(sortDescriptors: [
                    NSSortDescriptor(keyPath: \ToDo.isDone, ascending: true),
                    NSSortDescriptor(keyPath: \ToDo.deadline, ascending: true),
                    NSSortDescriptor(keyPath: \ToDo.notification, ascending: true)],
                                      predicate: NSPredicate(format: "list == %@ && isDone == false", userSelected.selectedToDoList), animation: .default)
            }
        }
        _showDoneToDos = showDoneToDos
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
                            SystemImage(image: "checkmark.square.fill", color: .white, size: SystemImageSize, isActivated: true)
                        } else {
                            SystemImage(image: "square", color: .white, size: SystemImageSize, isActivated: true)
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
                            SystemImage(image: "star.fill", color: .yellow, size: 15, isActivated: true)
                                .padding(5)
                        } else {
                            SystemImage(image: "star", color: .white, size: 15, isActivated: true)
                                .padding(5)
                        }
                    })
                        .buttonStyle(.plain)
                }
                .padding(5)
                .background(isDateInPast(date: todo.deadline ?? Dates.defaultDate, defaultColor: Colors.primaryColor))
                .cornerRadius(8.5)
            }
        }
        .listStyle(InsetListStyle())
        .frame(minWidth: 375)
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

