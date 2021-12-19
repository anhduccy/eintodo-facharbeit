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
            
            //Titel
            TextField("Titel", text: $title)
                .font(.title.bold())
                .textFieldStyle(.plain)
            
            //Deadline
            HStack{
                IconsImage(title: "Fälligkeitsdatum", image: "calendar.circle.fill", color: .red, size: 25)
                Toggle("", isOn: $toggle_show_deadline)
                    .toggleStyle(.switch)
            }
            if toggle_show_deadline {
                DatePicker("",
                           selection: $deadline,
                    displayedComponents: [.date]
                )
                    .datePickerStyle(.compact)
            }
            
            //Notification
            HStack{
                IconsImage(title: "Erinnerung", image: "bell.circle.fill", color: .orange, size: 25)
                Toggle("", isOn: $toggle_show_notification)
                    .toggleStyle(.switch)
            }
            if toggle_show_notification {
                DatePicker("",
                    selection: $notification,
                           displayedComponents: [.date, .hourAndMinute]
                )
                    .datePickerStyle(.compact)
            }
            Spacer()
            
            //Button Done / Button Cancel
            HStack{
                Button("Abbrechen"){
                    showAddView.toggle()
                }
                .buttonStyle(.plain)
                .foregroundColor(.red)
                
                Spacer()
                
                if(title != ""){
                    Button(action: {
                        showAddView.toggle()
                        addToDo()
                    }, label: {
                       Text("Hinzufügen")
                            .foregroundColor(.blue)
                            .fontWeight(.semibold)
                    })
                    .buttonStyle(.plain)
                }

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
            if toggle_show_deadline{
                newToDo.deadline = deadline
            } else {
                newToDo.deadline = Date(timeIntervalSince1970: 0)
            }
            if toggle_show_notification {
                newToDo.notification = notification
            } else {
                newToDo.notification = Date(timeIntervalSince1970: 0)
            }
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

