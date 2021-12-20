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
    
    @State var showDeadline = true
    @State var showNotification = true
    
    @State private var overDeleteButton = false

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
                                    withAnimation{
                                        showDeadline.toggle()
                                    }
                                }, label: {
                                    IconImage(image: "calendar.circle.fill", color: showDeadline ? .indigo : .gray, size: 25)
                                })
                                    .buttonStyle(.plain)
                                
                                Text("Fällig am")
                                    .font(.body)
                                Spacer()
                            }
                            .frame(width: 125)
                            if showDeadline {
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
                                    withAnimation{
                                        showNotification.toggle()
                                    }
                                }, label: {
                                    IconImage(image: "bell.circle.fill", color: showNotification ? .indigo : .gray, size: 25)
                                })
                                    .buttonStyle(.plain)
                                
                                Text("Erinnerung")
                                    .font(.body)
                                Spacer()
                            }
                            .frame(width: 125)
                            if showNotification {
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
                            withAnimation{
                                isMarked.toggle()
                            }
                        }, label: {
                            IconImage(image: "star.circle.fill", color: isMarked ? .indigo : .gray, size: 25)
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
                        
                        Button(action: {
                            deleteToDo()
                        }, label: {
                            IconImage(image: "trash.circle.fill", color: overDeleteButton ? .indigo : .red, size: 25)
                        })
                            .buttonStyle(.plain)
                            .onHover{ over in
                                withAnimation{
                                    overDeleteButton = over
                                }
                            }
                        
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
                showDeadline = false
                deadline = Date()
            }
            if notification == Date(timeIntervalSince1970: 0){
                showNotification = false
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
            if showDeadline{
                todo.deadline = deadline
            }
            if !showDeadline{
                todo.deadline = Date(timeIntervalSince1970: 0)
            }
            if showNotification{
                todo.notification = notification
            }
            if !showNotification{
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
