//
//  Functions.swift
//  eintodo
//
//  Created by anh :) on 16.12.21.
//

import Foundation
import SwiftUI

public func DateToStringFormatter(date: Date) -> String{
    let formatter = DateFormatter()
    formatter.dateFormat = "dd.MM.yyyy"
    
    return formatter.string(from: date)
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
