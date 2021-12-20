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
            ScrollView{
                VStack(spacing: 20){
                    //Buttons
                    HStack{
                        Button("Abbrechen"){
                            showAddView.toggle()
                        }
                        .buttonStyle(.plain)
                        .foregroundColor(secondaryColor)
                        
                        Spacer()
                        
                        if(title != ""){
                            Button(action: {
                                addToDo()
                                showAddView.toggle()
                            }, label: {
                                Text("Fertig")
                                    .font(.body)
                                    .fontWeight(.semibold)
                                    .foregroundColor(colorScheme == .dark ? .white : primaryColor)

                            })
                            .buttonStyle(.plain)
                        }
                    }
                    //Title & Notes
                    VStack(spacing: 2){
                        TextField("Titel", text: $title)
                            .textFieldStyle(.plain)
                            .font(.title.bold())
                            .foregroundColor(colorScheme == .dark ? .white : primaryColor)
                        
                        TextField("Notizen", text: $notes)
                            .font(.body)
                            .textFieldStyle(.plain)
                            .foregroundColor(colorScheme == .dark ? .white : primaryColor)
                    }
                    
                    //Card - Deadline & Notifications
                    VStack{
                        VStack{
                            HStack{
                                IconsImage(title: "Fälligkeitsdatum", image: "calendar.circle.fill", color: .red, size: 25)
                                Toggle("", isOn: $toggle_show_deadline)
                                    .toggleStyle(.switch)
                                    .tint(colorScheme == .dark ? .blue : .green)
                            }
                            if toggle_show_deadline {
                                DatePicker("",
                                    selection: $deadline,
                                    displayedComponents: [.date]
                                )
                                    .datePickerStyle(.compact)
                            }
                        }
                        .padding(.top, 5)
                        .padding(.bottom, 5)
                        .padding(.leading, 0)
                        .padding(.trailing, 0)
                        VStack{
                            HStack{
                                IconsImage(title: "Erinnerung", image: "bell.circle.fill", color: .orange, size: 25)
                                Toggle("", isOn: $toggle_show_notification)
                                    .toggleStyle(.switch)
                                    .tint(colorScheme == .dark ? .blue : .green)
                            }
                            if toggle_show_notification {
                                DatePicker("",
                                    selection: $notification,
                                           displayedComponents: [.date, .hourAndMinute]
                                )
                                    .datePickerStyle(.compact)
                            }
                        }
                        .padding(.top, 5)
                        .padding(.bottom, 5)
                        .padding(.leading, 0)
                        .padding(.trailing, 0)
                    }
                    .padding()
                    .background(colorScheme == .dark ? secondaryColor : primaryColor)
                    .cornerRadius(10)

                    //Card - Markiert
                    VStack{
                        HStack{
                            IconsImage(title: "Markiert", image: "star.circle.fill", color: .yellow, size: 25)
                            Toggle("", isOn: $isMarked)
                                .toggleStyle(.switch)
                                .tint(colorScheme == .dark ? .blue : .green)
                        }
                    }
                    .padding()
                    .background(colorScheme == .dark ? secondaryColor : primaryColor)
                    .cornerRadius(10)
                }
                .padding()
            }
        }
        .background(colorScheme == .dark ? primaryColor : backgroundColor)
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

