//
//  Functions.swift
//  eintodo
//
//  Created by anh :) on 16.12.21.
//

import Foundation
import SwiftUI

//GETTER
//Get the start of month
func getStartOfMonth() -> Date {
    return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: Date())))!
}
//Get difference of month between input date and current date (not interval)
func getMonthInterval(from date: Date) -> Int {
    var interval = Calendar.current.dateComponents([.second], from: Date(), to: date).second!
    if(interval > 0){
        interval = Calendar.current.dateComponents([.month], from: getStartOfMonth(), to: date).month!
    } else {
        interval = Calendar.current.dateComponents([.month], from: Date(), to: date).month!
    }
    return interval
}

//Get interval in sconds between input date and current date
func getInterval(from date: Date) -> Int {
    let interval = Calendar.current.dateComponents([.second], from: Date(), to: date).second!
    return interval
}

//Return a color from a string
public func getColorFromString(string: String)->Color{
    switch(string){
        case "red": return Color.red
        case "pink": return Color.pink
        case "yellow": return Color.yellow
        case "green": return Color.green
        case "blue": return Color.blue
        case "indigo": return Color.indigo
        case "purple": return Color.purple
        case "brown": return Color.brown
        case "gray": return Color.gray
        default: return Color.indigo
    }
}
 
//Formatters
//Format Date into String
public func DateInString(date: Date, format: String = "dd.MM.yyyy", type: String) -> String{
    let timeFormatter = DateFormatter()
    timeFormatter.dateFormat = ", HH:mm"
    let formatter = DateFormatter()
    formatter.dateFormat = format
    var output = ""
    
    if(type == "deadline"){ // Type is deadline
        if(isTomorrow(date: date)){
            output = "Morgen fällig"
        } else if (isToday(date: date)){
            output = "Heute fällig"
        } else if (isYesterday(date: date)){
            output = "Gestern fällig"
        } else {
            output = "Fällig am " + formatter.string(from: date)
        }
    } else if(type == "notification"){ // Type is notification
        if(isTomorrow(date: date)){
            output = "Morgen" + timeFormatter.string(from: date)
        } else if (isToday(date: date)){
            output = "Heute" + timeFormatter.string(from: date)
        } else if (isYesterday(date: date)){
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
public func isYesterday(date: Date)->Bool{
    return Calendar.current.isDate(date, inSameDayAs: Date().addingTimeInterval(-TimeInterval(SecondsCalculated.day)))
}

//If input date is current date, return true
public func isToday(date: Date)->Bool{
    return Calendar.current.isDate(date, inSameDayAs: Date())
}

//If input date is equal as the tomorrow date, return true
public func isTomorrow(date: Date)->Bool{
    return Calendar.current.isDate(date, inSameDayAs: Date().addingTimeInterval(TimeInterval(SecondsCalculated.day)))
}

//If input date is before the current date, return a color
public func isDateInPast(date: Date, defaultColor: Color)->Color{
    let currentDate = Calendar.current.startOfDay(for: Date())
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
    let currentDate = Calendar.current.startOfDay(for: Date())
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
