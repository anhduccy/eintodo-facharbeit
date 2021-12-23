//
//  CoreDataFunctions.swift
//  eintodo
//
//  Created by anh :) on 12.12.21.
//

import Foundation
import SwiftUI

//CalendarView
extension CalendarView{
    public func deleteAllItems() {
        withAnimation {
            for todo in todos{
                viewContext.delete(todo)
            }
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Could not delete all CoreData-Entites in CalendarView:  \(nsError), \(nsError.userInfo)")
            }
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

//DetailView
extension DetailView{
    public func updateToDo() {
        withAnimation {
            todo.title = title
            todo.notes = notes
            if showDeadline{
                todo.deadline = deadline
            }
            if !showDeadline{
                todo.deadline = Date(timeIntervalSince1970: 0)
            }
            if showNotification{
                todo.notification = notification
            }
            if !showNotification{
                todo.notification = Date(timeIntervalSince1970: 0)
            }
            
            todo.isMarked = isMarked
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Could not update CoreData-Entity in DetailView: \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    public func deleteToDo(){
        withAnimation {
            viewContext.delete(todo)
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Could not delete CoreData-Entity in DetailView: \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

extension AddView{
    public func addToDo() {
        withAnimation {
            let newToDo = ToDo(context: viewContext)
            newToDo.id = UUID()
            newToDo.title = title
            newToDo.notes = notes
            if showDeadline{
                newToDo.deadline = deadline
            } else {
                newToDo.deadline = Date(timeIntervalSince1970: 0)
            }
            if showNotification {
                newToDo.notification = notification
            } else {
                newToDo.notification = Date(timeIntervalSince1970: 0)
            }
            newToDo.isDone = false
            newToDo.isMarked = false

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Could not add CoreData-Entity in AddView: \(nsError), \(nsError.userInfo)")
            }
        }
    }
}
