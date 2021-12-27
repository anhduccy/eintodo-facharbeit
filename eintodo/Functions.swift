//
//  Functions.swift
//  eintodo
//
//  Created by anh :) on 16.12.21.
//

import Foundation
import SwiftUI

//GETTER
//Get interval in month between input date and current date
func getMonthInterval(from date: Date) -> Int {
    let interval = Calendar.current.dateComponents([.month], from: Dates.currentDate, to: date).month!
    return interval
}

//Get interval in sconds between input date and current date
func getInterval(from date: Date) -> Int {
    let interval = Calendar.current.dateComponents([.second], from: Dates.currentDate, to: date).second!
    return interval
}

//Formatters
//Format Date into String
public func DateInString(date: Date, format: String = "dd.MM.yyyy", type: String) -> String{
    let timeFormatter = DateFormatter()
    let formatter = DateFormatter()
    formatter.dateFormat = format
    var output = ""
    
    if(type == "deadline"){ // Type is deadline
        if(isTomorrowDate(date: date)){
            output = "Morgen fällig"
        } else if (isYesterdayDate(date: date)){
            output = "Gestern fällig"
        } else {
            output = "Fällig am " + formatter.string(from: date)
        }
    } else if(type == "notification"){ // Type is notification
        timeFormatter.dateFormat = ", HH:mm"
        
        if(isTomorrowDate(date: date)){
            output = "Morgen" + timeFormatter.string(from: date)
        } else if (isYesterdayDate(date: date)){
            output = "Gestern" + timeFormatter.string(from: date)
        } else {
            output = formatter.string(from: date) + timeFormatter.string(from: date)
        }
    } else {
        output = "Error"
    }
    
    return output
}

//Comparisons
//Compare two dates and return true if it is the same
public func isSameDay(date1: Date, date2: Date) -> Bool {
    return Calendar.current.isDate(date1, inSameDayAs: date2)
}

//If input date is equal as the yesterday's date, return true
public func isYesterdayDate(date: Date)->Bool{
    return Calendar.current.isDate(date, inSameDayAs: Dates.currentDate.addingTimeInterval(-TimeInterval(SecondsCalculated.day)))
}

//If input date is current date, return true
public func isCurrentDate(date: Date)->Bool{
    return Calendar.current.isDate(date, inSameDayAs: Dates.currentDate)
}

//If input date is equal as the tomorrow date, return true
public func isTomorrowDate(date: Date)->Bool{
    return Calendar.current.isDate(date, inSameDayAs: Dates.currentDate.addingTimeInterval(TimeInterval(SecondsCalculated.day)))
}

//If input date is before the current date, return a color
public func isDateInPast(date: Date, defaultColor: Color)->Color{
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
//If input date is before the current date, return true
public func isDateInPast(date: Date) -> Bool{
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
