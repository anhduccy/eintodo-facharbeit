//
//  DetailView.swift
//  eintodo
//
//  Created by anh :) on 12.12.21.
//

import SwiftUI

struct DetailView: View {
    @Environment(\.managedObjectContext) public var viewContext
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @State var todo: ToDo
    @State var title: String
    var body: some View {
        VStack{
            TextField("Titel", text: $title)
                .textFieldStyle(.plain)
                .font(.title.bold())
            Spacer()
        }
        .padding()
        .frame(width: 400, height: 400)
        .onDisappear(perform: updateToDo)
    }
    
    private func updateToDo() {
        withAnimation {
            todo.title = title
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Could not add CoreData-Entity in AddView \(nsError), \(nsError.userInfo)")
            }
        }
    }
}
