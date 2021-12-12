//
//  CoreDataActions.swift
//  eintodo
//
//  Created by anh :) on 12.12.21.
//

import Foundation
import SwiftUI

extension ContentView {
    public func addItem() {
        withAnimation {
            let newToDo = ToDo(context: viewContext)
            newToDo.title = "Hallo"

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    public func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}
