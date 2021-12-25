//
//  Functions.swift
//  eintodo
//
//  Created by anh :) on 16.12.21.
//

import Foundation
import SwiftUI

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
    let currentDate = Calendar.current.startOfDay(for: Date())
    if date != Date(timeIntervalSince1970: 0){
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
    let currentDate = Calendar.current.startOfDay(for: Date())
    if date != Date(timeIntervalSince1970: 0){
        if date < currentDate{
            return true
        } else {
            return false
        }
    } else {
        return false
    }
}
