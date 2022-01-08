//
//  Enumerations.swift
//  eintodo
//
//  Created by anh :) on 25.12.21.
//

import Foundation
import SwiftUI

class UserSelected: ObservableObject{
    @Published var selectedDate: Date
    @Published var lastSelectedDate: Date
    @Published var selectedToDoList: String
    @Published var showDoneToDos: Bool

    init(selectedDate: Date, lastSelectedDate: Date, selectedToDoList: String, showDoneToDos: Bool){
        self.selectedDate = selectedDate
        self.lastSelectedDate = lastSelectedDate
        self.selectedToDoList = selectedToDoList
        self.showDoneToDos = showDoneToDos
    }
}

//Structs - Global variables
struct Dates {
    static let defaultDate = Date(timeIntervalSince1970: 0)
}
struct SecondsCalculated {
    static let minute: Int = 60
    static let hour: Int = minute*60
    static let day: Int = hour*24
    static let week: Int = day*7
}
struct Sizes {
    static let defaultSheetWidth: CGFloat = 400
    static let defaultSheetHeight: CGFloat = 400
    static let defaultSheetHeightDetailView: CGFloat = 500
}
struct Colors {
    static let primaryColor: Color = .indigo
    static let secondaryColor: Color = Color(red: 139/255, green: 136/255, blue: 248/255)
}

//Enums - View types
enum ListViewTypes {
    case dates
    case noDates
    case inPastAndNotDone
    case marked
    case list
    case all
}
enum DetailViewTypes {
    case add
    case display
}

//Enums - Filter types
enum FilterToDoType {
    case deadline
    case notification
    case isMarked
}
