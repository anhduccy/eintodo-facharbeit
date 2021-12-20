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
    @State var notes: String = ""
    @State var deadline: Date = Date()
    @State var notification: Date = Date()
    @State var isMarked: Bool = false
    @State var toggle_show_deadline: Bool = true
    @State var toggle_show_notification: Bool = true
    
    @Environment(\.colorScheme) public var colorScheme
    let primaryColor: Color = .indigo
    let secondaryColor: Color = Color(red: 139/255, green: 136/255, blue: 248/255)
    let backgroundColor: Color = Color(red: 230/255, green: 230/255, blue: 250/255)

    
    var body: some View {
        ZStack{
            VStack(spacing: 20){

                //Group - Title, Notes & Cancel-Button
                VStack(spacing: 2){
                    TextField("Titel", text: $title)
                        .textFieldStyle(.plain)
                        .font(.title.bold())
                    
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
                            showAddView.toggle()
                        }
                        .foregroundColor(secondaryColor)
                        .buttonStyle(.plain)
                        Spacer()
                        if(title != ""){
                            Button(action: {
                                addToDo()
                                showAddView.toggle()
                            }, label: {
                                Text("Fertig")
                                    .font(.body)
                                    .fontWeight(.semibold)
                                    .foregroundColor(colorScheme == .dark ? secondaryColor : .indigo)
                            })
                            .buttonStyle(.plain)
                        } else {
                            Button(action: {
                                showAddView.toggle()
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
    }
    
    private func addToDo() {
        withAnimation {
            let newToDo = ToDo(context: viewContext)
            newToDo.id = UUID()
            newToDo.title = title
            newToDo.notes = notes
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
            newToDo.isMarked = false

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Could not add CoreData-Entity in AddView \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

