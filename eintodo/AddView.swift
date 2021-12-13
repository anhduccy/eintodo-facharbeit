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
    @State var notification: Date = Date()
    @State var toggle_show_deadline: Bool = true
    @State var toggle_show_notification: Bool = true

    
    var body: some View {
        VStack{
            TextField("Titel", text: $title)
                .font(.title.bold())
                .textFieldStyle(.plain)
            List{
                HStack{
                    Image(systemName: "calendar.circle.fill")
                        .foregroundColor(.red)
                    Text("Fälligkeitsdatum")
                        .font(.title3)
                    Spacer()
                    Toggle("", isOn: $toggle_show_deadline)
                        .toggleStyle(.switch)
                }
                if toggle_show_deadline {
                    DatePicker("",
                        selection: $deadline,
                        displayedComponents: [.date]
                    )
                        .datePickerStyle(.field)
                }
                
                HStack{
                    Image(systemName: "bell.circle.fill")
                        .foregroundColor(.orange)
                    Text("Erinnerung")
                        .font(.title3)
                    Spacer()
                    Toggle("", isOn: $toggle_show_notification)
                        .toggleStyle(.switch)
                }
                if toggle_show_notification {
                    DatePicker("",
                        selection: $notification,
                               displayedComponents: [.date, .hourAndMinute]
                    )
                        .datePickerStyle(.field)
                }
            }
            Spacer()
            HStack{
                if(title != ""){
                    Button("Fertig"){
                        showAddView.toggle()
                        addToDo()
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.blue)
                }
                
                Spacer()
                
                Button("Abbrechen"){
                    showAddView.toggle()
                }
                .buttonStyle(.plain)
                .foregroundColor(.red)

            }
        }
        .padding()
        .frame(width: 400, height: 400)
    }
    
    private func addToDo() {
        withAnimation {
            let newToDo = ToDo(context: viewContext)
            newToDo.id = UUID()
            newToDo.title = title
            newToDo.deadline = deadline
            newToDo.notification = notification
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

