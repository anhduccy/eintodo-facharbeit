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

public func missedDeadlineOfToDo(date: Date) -> Bool{
    if date != Date(timeIntervalSince1970: 0){
        if date < Date(){
            return true
        } else {
            return false
        }
    } else {
        return false
    }
}
