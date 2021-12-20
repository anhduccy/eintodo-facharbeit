//
//  AddView.swift
//  eintodo
//
//  Created by anh :) on 12.12.21.
//

import SwiftUI

struct AddView: View {
    @Environment(\.managedObjectContext) public var viewContext
    @Environment(\.colorScheme) public var colorScheme
    
    @Binding var showAddView: Bool
    @State var title: String = ""
    @State var notes: String = ""
    @State var deadline: Date = Date()
    @State var notification: Date = Date()
    @State var isMarked: Bool = false
    @State var showDeadline: Bool = true
    @State var showNotification: Bool = true
    
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
                                    withAnimation{
                                        showDeadline.toggle()
                                    }
                                }, label: {
                                    IconImage(image: "calendar.circle.fill", color: showDeadline ? Colors.primaryColor : .gray, size: 25)
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
                                    IconImage(image: "bell.circle.fill", color: showNotification ? Colors.primaryColor : .gray, size: 25)
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
                            IconImage(image: "star.circle.fill", color: isMarked ? Colors.primaryColor : .gray, size: 25)
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
                        .foregroundColor(Colors.secondaryColor)
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
                                    .foregroundColor(colorScheme == .dark ? Colors.secondaryColor : Colors.primaryColor)
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
        .frame(width: Sizes.defaultSheetWidth, height: Sizes.defaultSheetHeight)
    }
}

