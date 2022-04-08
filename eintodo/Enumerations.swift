//
//  Enumerations.swift
//  eintodo
//
//  Created by anh :) on 25.12.21.
//

import Foundation
import SwiftUI


class UserSelected: ObservableObject{ //Attribute die global mitverfolgt werden und aktualisiert werden
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

//Structs - Global Variablen
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
}

//Enums - View Typen
enum ToDoListFilterType {
    case dates, noDates, inPast
    case marked
    case list
    case all
}
enum EditViewType {
    case add, edit
}
enum SubmitButtonType {
    case todos, todolists
}

//Enums - Filtertypen
enum CalendarViewFilterToDoType {
    case deadline
    case notification
    case isMarked
}

enum ToDoListRowType {
    case list, calendar
}
