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
    @State var deadline: Date
    @State var notification: Date
    
    @State var toggle_show_deadline = true
    @State var toggle_show_notification = true
    
    
    var body: some View {
        VStack{
            
            //Title
            TextField("Titel", text: $title)
                .textFieldStyle(.plain)
                .font(.title.bold())
            
            //Deadline
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
                    .datePickerStyle(.compact)
            }
            
            //Notification
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
                    .datePickerStyle(.compact)
            }
            Spacer()
        }
        .padding()
        .onAppear{
            if deadline == Date(timeIntervalSince1970: 0){
                toggle_show_deadline = false
                deadline = Date()
            }
            if notification == Date(timeIntervalSince1970: 0){
                toggle_show_notification = false
                notification = Date()
            }
        }
        .onDisappear(perform: updateToDo)
    }
    
    private func updateToDo() {
        withAnimation {
            todo.title = title
            if toggle_show_deadline{
                todo.deadline = deadline
            }
            if !toggle_show_deadline{
                todo.deadline = Date(timeIntervalSince1970: 0)
            }
            if toggle_show_deadline{
                todo.notification = notification
            }
            if !toggle_show_notification{
                todo.notification = Date(timeIntervalSince1970: 0)
            }
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Could not add CoreData-Entity in AddView \(nsError), \(nsError.userInfo)")
            }
        }
    }
}
