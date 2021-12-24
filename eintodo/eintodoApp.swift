//
//  eintodoApp.swift
//  eintodo
//
//  Created by anh :) on 12.12.21.
//

import SwiftUI

@main
struct eintodoApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
                ContentView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .environment(\.locale, Locale(identifier: "fr"))
        }
    }
}
