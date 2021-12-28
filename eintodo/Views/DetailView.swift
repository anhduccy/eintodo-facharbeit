//
//  DetailView.swift
//  eintodo
//
//  Created by anh :) on 12.12.21.
//

import SwiftUI
import UserNotifications

struct SelectPriorityPopover: View{
    @Binding var priority: Int
    var body: some View{
        VStack{
            HStack{
                Text("Priorität").font(.title2.bold())
                Spacer()
            }
            Picker("", selection: $priority){
                Text("Hoch").tag(3)
                Text("Mittel").tag(2)
                Text("Niedrig").tag(1)
                Text("Keine").tag(0)
            }
            .pickerStyle(.inline)
        }
        .padding()
    }
}

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
    @State var priority: Int
    
    //Toggles and Conditions for Animtaion
    @State var showDeadline = true
    @State var showNotification = true
    @State var showPriorityPopover = false
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
                                    IconImage(image: "calendar.circle.fill", color: Colors.primaryColor, size: 25, isActivated: showDeadline)
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
                                    IconImage(image: "bell.circle.fill", color: Colors.primaryColor, size: 25, isActivated: showNotification)
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
                            IconImage(image: "star.circle.fill", color: Colors.primaryColor, size: 25, isActivated: isMarked)
                        })
                            .buttonStyle(.plain)
                        Text("Markiert")
                            .font(.body)
                        Spacer()
                    }
                    
                    //Priority
                    HStack{
                        Button(action: {
                            withAnimation{
                                showPriorityPopover.toggle()
                            }
                        }, label: {
                            switch(priority){
                            case 3:
                                IconImage(image: "exclamationmark.circle.fill", size: 25, isActivated: true)
                            case 2:
                                IconImage(image: "exclamationmark.circle.fill", size: 25, isActivated: true, opacity: 0.75)
                            case 1:
                                IconImage(image: "exclamationmark.circle.fill", size: 25, isActivated: true, opacity: 0.5)
                            default:
                                IconImage(image: "exclamationmark.circle.fill", size: 25, isActivated: false)
                            }
                        })
                            .buttonStyle(.plain)
                            .popover(isPresented: $showPriorityPopover){
                                SelectPriorityPopover(priority: $priority)
                            }
                        Text("Priorität")
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
                                IconImage(image: "trash.circle.fill", color: overDeleteButton ? Colors.primaryColor : .red, size: 25, isActivated: true)
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
                }
                if notification == Dates.defaultDate{
                    showNotification = false
                    notification = Date()
                }
            }
            askForUserNotificationPermission()
        }
    }
}

extension DetailView{
    public func addToDo() {
        withAnimation {
            let newToDo = ToDo(context: viewContext)
            newToDo.id = UUID()
            newToDo.title = title
            newToDo.notes = notes
            if showDeadline{
                newToDo.deadline = deadline
                addUserNotification(id: newToDo.id!, date: deadline, type: "deadline")

            } else {
                newToDo.deadline = Dates.defaultDate
            }
            if showNotification {
                newToDo.notification = notification
                addUserNotification(id: newToDo.id!, date: notification, type: "notification")
            } else {
                newToDo.notification = Dates.defaultDate
            }
            newToDo.isMarked = isMarked
            switch(priority){
            case 3:
                newToDo.priority = 3
            case 2:
                newToDo.priority = 2
            case 1:
                newToDo.priority = 1
            default:
                newToDo.priority = 0
            }
            newToDo.isDone = false
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Could not add CoreData-Entity in AddView: \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    public func updateToDo() {
        withAnimation {
            todo.title = title
            todo.notes = notes
            if showDeadline{
                todo.deadline = deadline
                deleteUserNotification(identifier: todo.id!)
                addUserNotification(id: todo.id!, date: todo.deadline!, type: "deadline")
            }
            if !showDeadline{
                todo.deadline = Dates.defaultDate
            }
            if showNotification{
                todo.notification = notification
                deleteUserNotification(identifier: todo.id!)
                addUserNotification(id: todo.id!, date: todo.notification!, type: "notification")
            }
            if !showNotification{
                todo.notification = Dates.defaultDate
            }
            todo.isMarked = isMarked
            switch(priority){
            case 3:
                todo.priority = 3
            case 2:
                todo.priority = 2
            case 1:
                todo.priority = 1
            default:
                todo.priority = 0
            }
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Could not update CoreData-Entity in DetailView: \(nsError), \(nsError.userInfo)")
            }
        }
    }
    public func deleteToDo(){
        withAnimation {
            deleteUserNotification(identifier: todo.id!)
            viewContext.delete(todo)
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Could not delete CoreData-Entity in DetailView: \(nsError), \(nsError.userInfo)")
            }
        }
    }
    public func dismissDetailView(){
        selectedDate = deadline
        isPresented.toggle()
    }
    
    public func askForUserNotificationPermission(){
        //Ask user for UserNotification permission
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]){ success, error in
            if success {
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    public func addUserNotification(id: UUID, date: Date, type: String){
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = DateInString(date: date, type: type)
        content.sound = UNNotificationSound.default
        
        if(getInterval(from: date) > 0){
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(getInterval(from: date)), repeats: false)
            let request = UNNotificationRequest(identifier: id.uuidString, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request)
            print("notification set for ", date, "\n")
        }
    }
    
    public func deleteUserNotification(identifier: UUID){
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [identifier.uuidString])
    }
}
