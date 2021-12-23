//
//  Functions.swift
//  eintodo
//
//  Created by anh :) on 16.12.21.
//

import Foundation
import SwiftUI

//Formatters
public func DateToStringFormatter(date: Date) -> String{
    let formatter = DateFormatter()
    formatter.dateFormat = "dd.MM.yyyy"
    return formatter.string(from: date)
}

//Comparisons
public func isSameDay(date1: Date, date2: Date) -> Bool {
    return Calendar.current.isDate(date1, inSameDayAs: date2)
}
public func missedDeadlineOfToDo(date: Date, defaultColor: Color)->Color{
    if date != Date(timeIntervalSince1970: 0){
        if date < Date(){
            return .red
        } else {
            return defaultColor
        }
    } else {
        return defaultColor
    }

}

struct DateValue: Hashable{
    let id = UUID().uuidString
    var day: Int
    var date: Date
}

extension CalendarView{
    func getYear() -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY"
        let year = formatter.string(from: selectedDate)
        return year
    }
    
    func getMonth() -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        let month = formatter.string(from: selectedDate)
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
        
        let predicate = NSPredicate(format: "deadline <= %@ && deadline >= %@", dateTo! as CVarArg, dateFrom as CVarArg)
        todos.nsPredicate = predicate
        if todos.isEmpty{
            return true
        } else {
            return false
        }
    }
}
