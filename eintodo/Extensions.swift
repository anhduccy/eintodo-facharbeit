//
//  Extensions.swift
//  eintodo
//
//  Created by anh :) on 24.12.21.
//

import SwiftUI

/* DELETE ALL TO-DOS
public func deleteAllItems() {
    withAnimation {
        for todo in todos{
            viewContext.delete(todo)
        }
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Could not delete all CoreData-Entites in CalendarView:  \(nsError), \(nsError.userInfo)")
        }
    }
}
 */

//Date
extension Date {
    func getAllDates() -> [Date] {
        let calendar = Calendar.current
        // geting start date
        let startDate = calendar.date(from: Calendar.current.dateComponents([.year, .month], from: self))!
        let range = calendar.range(of: .day, in: .month, for: startDate)
        // getting date...
        return range!.compactMap{ day -> Date in
            return calendar.date(byAdding: .day, value: day - 1 , to: startDate)!
        }
    }
}
