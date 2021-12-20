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
            ScrollView{
                VStack(spacing: 20){
                    //Buttons
                    HStack{
                        Button("Abbrechen"){
                            isPresented.toggle()
                        }
                        .buttonStyle(.plain)
                        .foregroundColor(secondaryColor)
                        
                        Spacer()
                        
                        Button(action: {
                            updateToDo()
                            isPresented.toggle()
                        }, label: {
                            Text("Fertig")
                                .font(.body)
                                .fontWeight(.semibold)
                                .foregroundColor(colorScheme == .dark ? .white : primaryColor)

                        })
                        .buttonStyle(.plain)
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
                    
                    //Card - Deadline & Notification
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
                    
                    Button("Erinnerung löschen"){
                        deleteToDo()
                    }
                    .buttonStyle(DeleteButton())
                    
                }
                .padding()
            }
        }
        .background(colorScheme == .dark ? primaryColor : backgroundColor)
        .frame(width: 400, height: 450)
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
