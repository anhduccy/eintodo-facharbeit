//
//  DetailView.swift
//  eintodo
//
//  Created by anh :) on 12.12.21.
//

import SwiftUI
import UserNotifications

struct DetailView: View {
    @Environment(\.managedObjectContext) public var viewContext
    @Environment(\.colorScheme) public var colorScheme
    @Environment(\.openURL) var openURL
    
    @EnvironmentObject private var userSelected: UserSelected
    @AppStorage("deadlineTime") private var AppStorageDeadlineTime: Date = Date()

    @FetchRequest(sortDescriptors: []) var lists: FetchedResults<ToDoList>
    @FetchRequest(sortDescriptors: []) var subToDos: FetchedResults<SubToDo>

    let detailViewType: DetailViewTypes

    //Values for ToDo
    @State var todo: ToDo
    @State var id: UUID = UUID()
    @State var title: String = ""
    @State var notes: String = ""
    @State var url: String = ""
    @State var deadline: Date = Date()
    @State var notification: Date = Date()
    @State var isMarked: Bool = false
    @State var priority: Int = 0
    @State var list: String
    @State var listID: UUID
    @State var images: [NSImage] = []
    
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
            VStack{
                //Group of TextField - Title, Notes, URLs
                VStack(spacing: 2){
                    TextField("Titel", text: $title)
                        .font(.title.bold())
                        .textFieldStyle(.plain)
                    TextField("Notizen", text: $notes)
                        .font(.body)
                        .textFieldStyle(.plain)
                        .foregroundColor(.gray)
                    HStack{
                        TextField("URL", text: $url)
                            .font(.body)
                            .textFieldStyle(.plain)
                            .foregroundColor(.gray)
                        if(url != ""){
                            Button("Öffne URL"){
                                openURL(URL(string: url)!)
                            }.buttonStyle(.plain)
                                .foregroundColor(Colors.primaryColor)
                        }
                    }
                }
                
                Divider()
                
                ScrollView{
                    VStack(spacing: 20){
                        //Group of Buttons - List, Deadline, Notifications, isMarked, Priorities, Images
                        VStack{
                            HStack{
                                Text("Allgemein").font(.headline)
                                Spacer()
                            }
                            //List
                            Button(action: {
                                showListPicker.toggle()
                            },
                                   label: {
                                HStack{
                                    switch(detailViewType){
                                    case .add:
                                        ZStack{
                                            Circle()
                                                .fill(getToDoListColor(with: listID))
                                                .frame(width: 25, height: 25)
                                            Image(systemName: getToDoListSymbol(with: listID))
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 12.5, height: 12.5)
                                                .foregroundColor(.white)
                                        }
                                    case .display:
                                        ZStack{
                                            Circle()
                                                .fill(getToDoListColor(with: listID))
                                                .frame(width: 25, height: 25)
                                            Image(systemName: getToDoListSymbol(with: listID))
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 12.5, height: 12.5)
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
                                    DetailViewListPicker(listsValueString: $list, listsValueID: $listID)
                                }
                                .padding()
                            }.buttonStyle(.plain)
                            
                            //Deadline
                            VStack{
                                HStack{
                                    HStack{
                                        Button(action: {
                                            withAnimation{
                                                showDeadline.toggle()
                                            }
                                        }, label: {
                                            SystemIcon(image: "calendar.circle.fill", color: Colors.primaryColor, size: 25, isActivated: showDeadline)
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
                                            SystemIcon(image: "bell.circle.fill", color: Colors.primaryColor, size: 25, isActivated: showNotification)
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
                                    SystemIcon(image: "star.circle.fill", color: Colors.primaryColor, size: 25, isActivated: isMarked)
                                })
                                    .buttonStyle(.plain)
                                Text("Markiert")
                                    .font(.body)
                                Spacer()
                            }
                            
                            //Priorities
                            HStack{
                                Button(action: {
                                    withAnimation{
                                        showPriorityPopover.toggle()
                                    }
                                }, label: {
                                    switch(priority){
                                    case 3:
                                        SystemIcon(image: "exclamationmark.circle.fill", size: 25, isActivated: true)
                                    case 2:
                                        SystemIcon(image: "exclamationmark.circle.fill", size: 25, isActivated: true, opacity: 0.75)
                                    case 1:
                                        SystemIcon(image: "exclamationmark.circle.fill", size: 25, isActivated: true, opacity: 0.5)
                                    default:
                                        SystemIcon(image: "exclamationmark.circle.fill", size: 25, isActivated: false)
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
                        }
                        //Images
                        ImageView(images: $images)
                        //SubToDos
                        SubToDoList(id: id)
                    }
                }
                //Group - Control buttons
                HStack{
                    //Cancel
                    Button("Abbrechen"){dismissDetailView()}.buttonStyle(.plain).foregroundColor(Colors.secondaryColor)
                    switch(detailViewType){
                    case .display:
                        Spacer()
                        //Delete
                        Button(action: {
                            deleteToDo()
                            dismissDetailView()
                        }, label: {
                            SystemIcon(image: "trash.circle.fill", color: overDeleteButton ? Colors.primaryColor : .red, size: 25, isActivated: true)
                        }).buttonStyle(.plain)
                            .onHover{ over in
                                withAnimation{overDeleteButton = over}
                            }
                        Spacer()
                    case .add:
                        Spacer()
                    }
                    //Done
                    if(title != "" && list != ""){
                        Button(action: {
                            switch(detailViewType){
                            case .display:
                                updateToDo(editViewType: detailViewType, todo: todo)
                            case .add:
                                updateToDo(editViewType: detailViewType)
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
                        Button(action: {dismissDetailView()}, label: {
                            Text("Fertig")
                                .font(.body)
                                .fontWeight(.semibold)
                                .foregroundColor(.gray)
                        }).buttonStyle(.plain)
                    }
                }
            }
            .padding()
        }
        .frame(minWidth: Sizes.defaultSheetWidth, minHeight: Sizes.defaultSheetHeightDetailView)
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
                //If the UserSelected list is not a default-generated list (there are 4) then use the Observable attribute selectedToDoList, otherwise use the first possible list stored in ToDoList
                if(userSelected.selectedToDoList == "Heute" ||
                   userSelected.selectedToDoList == "Alle" ||
                   userSelected.selectedToDoList == "Fällig" ||
                   userSelected.selectedToDoList == "Markiert"){
                    list = lists[0].listTitle!
                    listID = lists[0].listID!
                } else {
                    list = userSelected.selectedToDoList
                    listID = userSelected.selectedToDoListID
                }
            case .display: //Value assignment of CoreData storage, if type is display
                id = todo.todoID!
                title = todo.todoTitle ?? "Error"
                notes = todo.todoNotes ?? "Error"
                url = todo.todoURL ?? "Error"
                deadline = todo.todoDeadline ?? Dates.defaultDate
                if deadline == Dates.defaultDate{
                    showDeadline = false
                    deadline = combineDateAndTime(date: getDate(date: Date()), time: getTime(date: AppStorageDeadlineTime))
                } else {
                    deadline = combineDateAndTime(date: getDate(date: todo.todoDeadline ?? Dates.defaultDate), time: getTime(date: AppStorageDeadlineTime))
                }
                notification = todo.todoNotification ?? Dates.defaultDate
                if notification == Dates.defaultDate{
                    showNotification = false
                    notification = Date()
                } else {
                    notification = todo.todoNotification!
                }
                isMarked = todo.todoIsMarked
                list = todo.todoList!
                listID = todo.idOfToDoList!
                priority = Int(todo.todoPriority)
                images = CoreDataToNSImageArray(coreDataObject: todo.todoImages) ?? []
            }
            askForUserNotificationPermission()
        }
    }
}

extension DetailView{
    //Get information of ToDoList for the specified ToDo
    func getToDoListColor(with: UUID) -> Color{
        var color: String = ""
        lists.nsPredicate = NSPredicate(format: "listID == %@", with as CVarArg)
        for list in lists{
            color = list.listColor!
        }
        return getColorFromString(string: color)
    }
    func getToDoListSymbol(with: UUID) -> String{
        var symbol = ""
        lists.nsPredicate = NSPredicate(format: "listID == %@", with as CVarArg)
        for list in lists{
            symbol = list.listSymbol!
        }
        return symbol
    }
    
    //CORE-DATA - Add, update and delete ToDo
    func updateToDo(editViewType: DetailViewTypes, todo: ToDo = ToDo()){
        var objToDo = ToDo(context: viewContext)
        switch(editViewType){
        case .add:
            objToDo.todoID = id
        case .display:
            objToDo = todo
        }
        //Texts
        objToDo.todoTitle = title
        objToDo.todoNotes = notes
        objToDo.todoURL = url
        //Dates
        if showDeadline{
            objToDo.todoDeadline = deadline
            updateUserNotification(title: title, id: objToDo.todoID!, date: deadline, type: "deadline")
        } else {
            objToDo.todoDeadline = Dates.defaultDate
        }
        if showNotification {
            objToDo.todoNotification = notification
            updateUserNotification(title: title, id: objToDo.todoID!, date: notification, type: "notification")
        } else {
            objToDo.todoNotification = Dates.defaultDate
        }
        //isMarked
        objToDo.todoIsMarked = isMarked
        //Priority
        objToDo.todoPriority = Int16(priority)
        //List
        objToDo.todoList = list
        objToDo.idOfToDoList = listID
        //Images
        objToDo.todoImages = NSImageArrayToCoreData(images: images)
        //Set the ToDo to undone
        objToDo.todoIsDone = false
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Could not add CoreData-Entity ToDo in DetailView: \(nsError), \(nsError.userInfo)")
        }
    }
    func deleteToDo(){
        withAnimation {
            deleteUserNotification(identifier: todo.todoID!)
            viewContext.delete(todo)
            subToDos.nsPredicate = NSPredicate(format: "idOfMainToDo == %@", todo.todoID! as CVarArg)
            for subToDo in subToDos{
                viewContext.delete(subToDo)
            }
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Could not delete CoreData-Entity in DetailView: \(nsError), \(nsError.userInfo)")
            }
        }
    }
    //DISMISSING DetailView
    func dismissDetailView(){
        userSelected.selectedDate = deadline
        isPresented.toggle()
    }
}
