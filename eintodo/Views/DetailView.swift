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
    
    let detailViewType: DetailViewTypes

    //Values for ToDo
    @State var todo: ToDo
    @State var title: String
    @State var notes: String
    @State var deadline: Date
    @State var notification: Date
    @State var isMarked: Bool
    
    //Toggles and Conditions for Animtaion
    @State var showDeadline = true
    @State var showNotification = true
    @State private var overDeleteButton = false

    //Coomunication between other views
    @Binding var isPresented: Bool
    @Binding var selectedDate: Date
    
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
                            dismissDetailView()
                        }
                        .foregroundColor(Colors.secondaryColor)
                        .buttonStyle(.plain)
                        switch(detailViewType){
                        case .display:
                            Spacer()
                            Button(action: {
                                deleteToDo()
                                dismissDetailView()
                            }, label: {
                                IconImage(image: "trash.circle.fill", color: overDeleteButton ? Colors.primaryColor : .red, size: 25)
                            })
                                .buttonStyle(.plain)
                                .onHover{ over in
                                    withAnimation{
                                        overDeleteButton = over
                                    }
                                }
                            
                            Spacer()
                        case .add:
                            Spacer()
                        }
                        if(title != ""){
                            Button(action: {
                                switch(detailViewType){
                                case .display:
                                    updateToDo()
                                case .add:
                                    addToDo()
                                }
                                dismissDetailView()
                            }, label: {
                                Text("Fertig")
                                    .font(.body)
                                    .fontWeight(.semibold)
                                    .foregroundColor(colorScheme == .dark ? Colors.secondaryColor : Colors.primaryColor)
                            })
                            .buttonStyle(.plain)
                        } else {
                            Button(action: {
                                dismissDetailView()
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
        .onAppear{
            switch(detailViewType){
            case .add:
                deadline = selectedDate
                notification = selectedDate
                
            case .display:
                if deadline == Dates.defaultDate{
                    showDeadline = false
                    deadline = Date()
                    if notification == Dates.defaultDate{
                        showNotification = false
                        notification = Date()
                    }
                }
            }
        }
        .onChange(of: title) { newValue in
            switch(detailViewType){
            case .display:
                updateToDo()
            case .add:
                break
            }
        }
        .onChange(of: notes) { newValue in
            switch(detailViewType){
            case .display:
                updateToDo()
            case .add:
                break
            }
        }
        .onChange(of: isMarked){ newValue in
            switch(detailViewType){
            case .display:
                updateToDo()
            case .add:
                break
            }
        }
    }
}
