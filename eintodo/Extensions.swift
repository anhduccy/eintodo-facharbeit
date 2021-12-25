//
//  Extensions.swift
//  eintodo
//
//  Created by anh :) on 24.12.21.
//

import SwiftUI

//Date
extension Date {
    func getAllDates() -> [Date] {
        let calendar = Calendar.current
        // geting start date
        let startDate = calendar.date(from: Calendar.current.dateComponents([.year, .month], from: self))!
        let range = calendar.range(of: .day, in: .month, for: startDate)
        // getting date...
        return range!.compactMap{ day -> Date in
            return calendar.date(byAdding: .day, value: day - 1 , to: startDate)!
        }
    }
}

//CalendarView
struct DateValue: Hashable{
    let id = UUID().uuidString
    var day: Int
    var date: Date
}
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
    func getYear() -> String{
        let last = lastSelectedDate
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY"
        let year = formatter.string(from: isSameDay(date1: selectedDate, date2: Dates.defaultDate) ? last : selectedDate)
        return year
    }
    func getMonth() -> String{
        let last = lastSelectedDate
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        let month = formatter.string(from: isSameDay(date1: selectedDate, date2: Dates.defaultDate) ? last : selectedDate)
        return month
    }
    func getCurrentMonth() -> Date {
            let calendar = Calendar.current
            
            // Getting Current month date
            guard let currentMonth = calendar.date(byAdding: .month, value: self.currentMonth, to: Date()) else {
                return Date()
            }
            
            return currentMonth
        }
    func extractDate() -> [DateValue] {
            
            let calendar = Calendar.current
            
            // Getting Current month date
            let currentMonth = getCurrentMonth()
            
            var days = currentMonth.getAllDates().compactMap { date -> DateValue in
                let day = calendar.component(.day, from: date)
                let dateValue =  DateValue(day: day, date: date)
                return dateValue
            }
            
            // adding offset days to get exact week day...
            let firstWeekday = calendar.component(.weekday, from: days.first?.date ?? Date())
            
            for _ in 0..<firstWeekday - 1 {
                days.insert(DateValue(day: -1, date: Date()), at: 0)
            }
            
            return days
        }
    func isEmptyOnDate(date: Date)->Bool{
        let dateFrom = Calendar.current.startOfDay(for: date)
        let dateTo = Calendar.current.date(byAdding: .day, value: 1, to: dateFrom)
        
        let predicate = NSPredicate(format: "deadline <= %@ && deadline >= %@ && isDone == false", dateTo! as CVarArg, dateFrom as CVarArg)
        todos.nsPredicate = predicate
        if todos.isEmpty{
            return true
        } else {
            return false
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
                todo.deadline = Dates.defaultDate
            }
            if showNotification{
                todo.notification = notification
            }
            if !showNotification{
                todo.notification = Dates.defaultDate
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
    public func dismissDetailView(){
        selectedDate = deadline
        isPresented.toggle()
    }
}

//AddView
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
                newToDo.deadline = Dates.defaultDate
            }
            if showNotification {
                newToDo.notification = notification
            } else {
                newToDo.notification = Dates.defaultDate
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
    public func dismissAddView(){
        selectedDate = deadline
        showAddView.toggle()
    }
}

