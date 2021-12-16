//
//  Functions.swift
//  eintodo
//
//  Created by anh :) on 16.12.21.
//

import Foundation

public func DateToStringFormatter(date: Date) -> String{
    let formatter = DateFormatter()
    formatter.dateFormat = "dd.MM.yyyy"
    
    return formatter.string(from: date)
}
