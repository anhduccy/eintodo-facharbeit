//
//  Functions.swift
//  eintodo
//
//  Created by anh :) on 16.12.21.
//

import Foundation
import SwiftUI

//Getter
func getMonthInterval(from date: Date) -> Int {
    let interval = Calendar.current.dateComponents([.month], from: Dates.currentDate, to: date).month!
    return interval
}

func getInterval(from date: Date) -> Int {
    let interval = Calendar.current.dateComponents([.second], from: Dates.currentDate, to: date).second!
    return interval
}

//Formatters
public func DateToStringFormatter(date: Date, format: String = "dd.MM.yyyy") -> String{
    let formatter = DateFormatter()
    formatter.dateFormat = format
    return formatter.string(from: date)
}

//Comparisons
public func isSameDay(date1: Date, date2: Date) -> Bool {
    return Calendar.current.isDate(date1, inSameDayAs: date2)
}
public func isCurrentDate(date: Date)->Bool{
    return Calendar.current.isDate(date, inSameDayAs: Dates.currentDate)
}

public func missedDeadlineOfToDo(date: Date, defaultColor: Color)->Color{
    let currentDate = Calendar.current.startOfDay(for: Dates.currentDate)
    if date != Dates.defaultDate{
        if date < currentDate{
            return .red
        } else {
            return defaultColor
        }
    } else {
        return defaultColor
    }
}
public func missedDeadlineOfToDo(date: Date) -> Bool{
    let currentDate = Calendar.current.startOfDay(for: Dates.currentDate)
    if date != Dates.defaultDate{
        if date < currentDate{
            return true
        } else {
            return false
        }
    } else {
        return false
    }
}
