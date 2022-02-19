//
//  Enumerations.swift
//  eintodo
//
//  Created by anh :) on 25.12.21.
//

import Foundation
import SwiftUI

class UserSelected: ObservableObject{
    @Published var selectedView: Int?
    @Published var selectedDate: Date
    @Published var lastSelectedDate: Date
    @Published var selectedToDoList: String
    @Published var selectedToDoListID: UUID
    @Published var showDoneToDos: Bool

    init(selectedView: Int?, selectedDate: Date, lastSelectedDate: Date, selectedToDoList: String, selectedToDoListID: UUID, showDoneToDos: Bool){
        self.selectedView = selectedView
        self.selectedDate = selectedDate
        self.lastSelectedDate = lastSelectedDate
        self.selectedToDoList = selectedToDoList
        self.selectedToDoListID = selectedToDoListID
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
    static let defaultSheetHeight: CGFloat = 500
    static let defaultSheetHeightEditView: CGFloat = 450
}
struct Colors {
    static let primaryColor: Color = .blue
    static let secondaryColor: Color = Color(red: 139/255, green: 136/255, blue: 248/255)
}

//Enums - View types
enum ToDoListFilterType {
    case dates
    case noDates
    case inPastAndNotDone
    case marked
    case list
    case all
}
enum EditViewTypes {
    case add, edit
}

//Enums - Filter types
enum CalendarViewFilterToDoType {
    case deadline
    case notification
    case isMarked
}

enum ToDoListRowType {
    case list, calendar
}
