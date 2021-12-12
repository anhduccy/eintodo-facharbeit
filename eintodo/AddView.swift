//
//  AddView.swift
//  eintodo
//
//  Created by anh :) on 12.12.21.
//

import SwiftUI

struct AddView: View {
    @Environment(\.managedObjectContext) public var viewContext
    
    @Binding var showAddView: Bool
    @State var title: String = ""
    @State var deadline: Date = Date()
    @State var toggle_show_deadline: Bool = true
    
    var body: some View {
        VStack{
            TextField("Titel", text: $title)
                .font(.title.bold())
                .textFieldStyle(.plain)
            
            HStack{
                Text("Fälligkeitsdatum")
                Spacer()
                Toggle("", isOn: $toggle_show_deadline)
                    .toggleStyle(.switch)
            }
            if toggle_show_deadline {
                DatePicker("",
                    selection: $deadline,
                    displayedComponents: [.date]
                )
            }
            
            Spacer()
            Button(title != "" ? "Fertig" : "Abbrechen"){
                showAddView.toggle()
                if title != ""{
                    addToDo()
                }
            }
            .buttonStyle(.plain)
            .foregroundColor(title != "" ? .blue : .red)
        }
        .padding()
        .frame(width: 400, height: 400)
    }
    
    private func addToDo() {
        withAnimation {
            let newToDo = ToDo(context: viewContext)
            newToDo.title = title
            newToDo.deadline = deadline

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Could not add CoreData-Entity in AddView \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

