//
//  DetailView.swift
//  eintodo
//
//  Created by anh :) on 12.12.21.
//

import SwiftUI

struct DetailView: View {
    @Environment(\.managedObjectContext) public var viewContext
    @Binding var showDetailView: Bool
    @State var title: String
    var body: some View {
        VStack{
            TextField("Titel", text: $title)
            Spacer()
            HStack{
                if(title != ""){
                    Button("Fertig"){
                        showDetailView.toggle()
                        saveToDo()
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.blue)
                }
                
                Spacer()
                
                Button("Abbrechen"){
                    showDetailView.toggle()
                }
                .buttonStyle(.plain)
                .foregroundColor(.red)

            }
        }
        .padding()
        .frame(width: 400, height: 400)
    }
    private func saveToDo() {
        withAnimation {
            let newToDo = ToDo(context: viewContext)
            newToDo.title = title
            //newToDo.deadline = deadline
            //newToDo.notification = notification
            newToDo.isDone = false

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Could not add CoreData-Entity in AddView \(nsError), \(nsError.userInfo)")
            }
        }
    }
}
