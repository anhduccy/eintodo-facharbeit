//
//  DetailView.swift
//  eintodo
//
//  Created by anh :) on 12.12.21.
//

import SwiftUI
import UserNotifications

struct DetailView: View {
    @FetchRequest(sortDescriptors: []) var lists: FetchedResults<ToDoList>
    @Environment(\.managedObjectContext) public var viewContext
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Environment(\.colorScheme) public var colorScheme
    @EnvironmentObject private var userSelected: UserSelected
    
    @AppStorage("deadlineTime") private var AppStorageDeadlineTime: Date = Date()

    let detailViewType: DetailViewTypes

    //Values for ToDo
    @State var todo: ToDo
    @State var title: String = ""
    @State var notes: String = ""
    @State var deadline: Date = Date()
    @State var notification: Date = Date()
    @State var isMarked: Bool = false
    @State var priority: Int = 0
    @State var list: String
    
    //Toggles and Conditions for Animation
    @State var showDeadline = true
    @State var showNotification = true
    @State var showPriorityPopover = false
    @State private var overDeleteButton = false

    //Coomunication between other views
    @Binding var isPresented: Bool
    @State var showListPicker: Bool = false
    
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
                    
                    //List
                    Button(action: {
                        showListPicker.toggle()
                    }, label: {
                        HStack{
                            switch(detailViewType){
                            case .add:
                                ZStack{
                                    Circle()
                                        .fill(getColorFromString(string: getToDoList(with: list)[2]))
                                        .frame(width: 25, height: 25)
                                    Image(systemName: getToDoList(with: list)[3])
                                        .foregroundColor(.white)
                                }
                            case .display:
                                ZStack{
                                    Circle()
                                        .fill(getColorFromString(string: getToDoList(with: list)[2]))
                                        .frame(width: 25, height: 25)
                                    Image(systemName: getToDoList(with: list)[3])
                                        .foregroundColor(.white)
                                }
                            }
                            Text("Ausgewählte Liste - " + list)
                            Spacer()
                        }
                    })
                    .popover(isPresented: $showListPicker){
                        VStack{
                            Text("Liste auswählen").font(.title2.bold())
                            DetailViewListPicker(listsValueString: $list)
                        }
                        .padding()
                    }.buttonStyle(.plain)
                    Spacer()
                    
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
                        if(title != "" && list != ""){
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
                if deadline == Dates.defaultDate{
                    showDeadline = false
                    deadline = combineDateAndTime(date: getDate(date: Date()), time: getTime(date: AppStorageDeadlineTime))
                } else {
                    deadline = combineDateAndTime(date: getDate(date: userSelected.selectedDate), time: getTime(date: AppStorageDeadlineTime))
                }
                if notification == Dates.defaultDate{
                    showNotification = false
                    notification = Date()
                } else {
                    notification = userSelected.selectedDate
                }
                list = userSelected.selectedToDoList
            case .display: //Value assignment of CoreData storage, if type is display
                title = todo.title ?? "Error"
                notes = todo.notes ?? "Error"
                if deadline == Dates.defaultDate{
                    showDeadline = false
                    deadline = combineDateAndTime(date: getDate(date: Date()), time: getTime(date: AppStorageDeadlineTime))
                } else {
                    deadline = combineDateAndTime(date: getDate(date: todo.deadline ?? Dates.defaultDate), time: getTime(date: AppStorageDeadlineTime))
                }
                notification = todo.notification ?? Dates.defaultDate
                if notification == Dates.defaultDate{
                    showNotification = false
                    notification = Date()
                } else {
                    notification = todo.notification!
                }
                isMarked = todo.isMarked
                list = todo.list!
                priority = Int(todo.priority)
            }
            askForUserNotificationPermission()
        }
    }
}

extension DetailView{
    public func getToDoList(with: String) -> [String]{
        lists.nsPredicate = NSPredicate(format: "listTitle == %@", with as CVarArg)
        var array: [String] = []
        for list in lists{
            array.append(list.listTitle!) //0
            array.append(list.listDescription!) //1
            array.append(list.color!) //2
            array.append(list.symbol!) //3
        }
        return array
    }
    
    //CORE-DATA - Add, update and delete ToDo
    public func addToDo() {
        withAnimation {
            let newToDo = ToDo(context: viewContext)
            newToDo.id = UUID()
            newToDo.title = title
            newToDo.notes = notes
            if showDeadline{
                newToDo.deadline = deadline
                addUserNotification(title: title, id: newToDo.id!, date: deadline, type: "deadline")

            } else {
                newToDo.deadline = Dates.defaultDate
            }
            if showNotification {
                newToDo.notification = notification
                addUserNotification(title: title, id: newToDo.id!, date: notification, type: "notification")
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
            newToDo.list = list
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
            //Text
            todo.title = title
            todo.notes = notes
            //Deadline
            if showDeadline{
                todo.deadline = deadline
                deleteUserNotification(identifier: todo.id!)
                addUserNotification(title: title, id: todo.id!, date: todo.deadline!, type: "deadline")
            }
            if !showDeadline{
                todo.deadline = Dates.defaultDate
            }
            //Notification
            if showNotification{
                todo.notification = notification
                deleteUserNotification(identifier: todo.id!)
                addUserNotification(title: title, id: todo.id!, date: todo.notification!, type: "notification")
            }
            if !showNotification{
                todo.notification = Dates.defaultDate
            }
            //IsMarked
            todo.isMarked = isMarked
            //Priorities
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
            //Lists
            todo.list = list
            //Store in CoreData
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
    //DISMISSING DetailView
    public func dismissDetailView(){
        userSelected.selectedDate = deadline
        isPresented.toggle()
    }
}


//VIEWS
//Popover to select priority
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

//ListPicker
struct DetailViewListPicker: View{
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \ToDoList.listTitle, ascending: true)]) var lists: FetchedResults<ToDoList>
    @Binding var listsValueString: String
    @State private var listType: Int = 0
    var body: some View {
       let binding = Binding<Int>(
           get: { self.listType },
           set: {
               self.listType = $0
               self.listsValueString = self.lists[self.listType].listTitle!
           })
       return Picker(selection: binding, label: Text("")) {
           ForEach(lists.indices) { list in
               Text(lists[list].listTitle!).tag(list)
           }
       }
       .pickerStyle(.menu)
       .onAppear{ //Check in which list, ToDo was before
            var counter = 0
            for list in lists{
                if(list.listTitle == listsValueString){
                    listType = counter
                }
                counter += 1
            }
        }
    }
}
