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
    @Environment(\.colorScheme) public var colorScheme



    @State var todo: ToDo
    @State var title: String
    @State var notes: String
    @State var deadline: Date
    @State var notification: Date
    @State var isMarked: Bool
    
    @State var toggle_show_deadline = true
    @State var toggle_show_notification = true
    
    @Binding var isPresented: Bool
    
    let primaryColor: Color = .indigo
    let secondaryColor: Color = Color(red: 139/255, green: 136/255, blue: 248/255)
    let backgroundColor: Color = Color(red: 230/255, green: 230/255, blue: 250/255)
    
    var body: some View {
        ZStack{
            VStack(spacing: 20){

                //Group - Title & Notes
                VStack(spacing: 2){
                    TextField("Titel", text: $title)
                        .font(.title.bold())
                        .textFieldStyle(.plain)
                    TextField("Notizen", text: $notes)
                        .font(.body)
                        .textFieldStyle(.plain)
                        .foregroundColor(.gray)
                }
                
                Divider()
                
                //Group - Deadline, Notifications & isMarked
                VStack{
                    //Deadline
                    VStack{
                        HStack{
                            HStack{
                                Button(action: {
                                    toggle_show_deadline.toggle()
                                }, label: {
                                    if(toggle_show_deadline){
                                        IconsImage(title: "Fällig am", image: "calendar.circle.fill", color: .indigo, size: 25)
                                    } else {
                                        IconsImage(title: "Fällig am", image: "calendar.circle.fill", color: .gray, size: 25)
                                    }
                                })
                                    .buttonStyle(.plain)
                                
                                Text("Fällig am")
                                    .font(.body)
                                Spacer()
                            }
                            .frame(width: 125)
                            if toggle_show_deadline {
                                DatePicker("",
                                    selection: $deadline,
                                    displayedComponents: [.date]
                                )
                                    .datePickerStyle(.compact)
                            } else {
                                Spacer()
                            }
                        }
                    }
                    
                    //Notifications
                    VStack{
                        HStack{
                            HStack{
                                Button(action: {
                                    toggle_show_notification.toggle()
                                }, label: {
                                    if(toggle_show_notification){
                                        IconsImage(title: "Erinnerung", image: "bell.circle.fill", color: .indigo, size: 25)
                                    } else {
                                        IconsImage(title: "Erinnerung", image: "bell.circle.fill", color: .gray, size: 25)
                                    }
                                })
                                    .buttonStyle(.plain)
                                
                                Text("Erinnerung")
                                    .font(.body)
                                Spacer()
                            }
                            .frame(width: 125)
                            if toggle_show_notification {
                                DatePicker("",
                                    selection: $notification,
                                           displayedComponents: [.date, .hourAndMinute]
                                )
                                    .datePickerStyle(.compact)
                            } else{
                                Spacer()
                            }
                        }
                    }
                    
                    //IsMarked
                    HStack{
                        Button(action: {
                            isMarked.toggle()
                        }, label: {
                            if(isMarked){
                                IconsImage(title: "Markiert", image: "star.circle.fill", color: .indigo, size: 25)
                            } else {
                                IconsImage(title: "Markiert", image: "star.circle.fill", color: .gray, size: 25)
                            }
                        })
                            .buttonStyle(.plain)
                        Text("Markiert")
                            .font(.body)
                        Spacer()
                    }
                    Spacer()
                    
                    //Group - Submit button
                    HStack{
                        Button("Abbrechen"){
                            isPresented.toggle()
                        }
                        .foregroundColor(secondaryColor)
                        .buttonStyle(.plain)
                        Spacer()
                        if(title != ""){
                            Button(action: {
                                updateToDo()
                                isPresented.toggle()
                            }, label: {
                                Text("Fertig")
                                    .font(.body)
                                    .fontWeight(.semibold)
                                    .foregroundColor(colorScheme == .dark ? secondaryColor : .indigo)
                            })
                            .buttonStyle(.plain)
                        } else {
                            Button(action: {
                                isPresented.toggle()
                            }, label: {
                                Text("Fertig")
                                    .font(.body)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.gray)
                            })
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
        .padding()
        .frame(width: 400, height: 400)
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
        .onChange(of: title) { newValue in
            updateToDo()
        }
        .onChange(of: notes) { newValue in
            updateToDo()
        }
        .onChange(of: deadline) { newValue in
            updateToDo()
        }
        .onChange(of: notification) { newValue in
            updateToDo()
        }
        .onChange(of: isMarked){ newValue in
            updateToDo()
        }
    }
    
    private func updateToDo() {
        withAnimation {
            todo.title = title
            todo.notes = notes
            if toggle_show_deadline{
                todo.deadline = deadline
            }
            if !toggle_show_deadline{
                todo.deadline = Date(timeIntervalSince1970: 0)
            }
            if toggle_show_notification{
                todo.notification = notification
            }
            if !toggle_show_notification{
                todo.notification = Date(timeIntervalSince1970: 0)
            }
            
            todo.isMarked = isMarked
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Could not add CoreData-Entity in AddView \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func deleteToDo(){
        withAnimation {
            viewContext.delete(todo)
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}
