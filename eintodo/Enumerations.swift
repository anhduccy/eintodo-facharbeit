//
//  Enumerations.swift
//  eintodo
//
//  Created by anh :) on 25.12.21.
//

import Foundation
import SwiftUI

//Structs - Global variables
struct Dates {
    static let currentDate = Date()
    static let defaultDate = Date(timeIntervalSince1970: 0)
}
struct Sizes {
    static let defaultSheetWidth: CGFloat = 400
    static let defaultSheetHeight: CGFloat = 400
}
struct Colors {
    static let primaryColor: Color = .indigo
    static let secondaryColor: Color = Color(red: 139/255, green: 136/255, blue: 248/255)
}

//Enums - View tyoes
enum ListViewTypes {
    case dates
    case noDates
    case all
}

enum DetailViewTypes {
    case add
    case display
}
