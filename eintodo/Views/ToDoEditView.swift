//
//  EditView.swift
//  eintodo
//
//  Created by anh :) on 12.12.21.
//

import SwiftUI
import UserNotifications

/**
 Detaillierte Sheet-Ansicht für eine Erinnerung: Hier werden die Inforamtionen einer Erinnerung angezeigt oder  definiert
 */

struct ToDoEditView: View {
    @Environment(\.managedObjectContext) public var viewContext
    @Environment(\.colorScheme) public var colorScheme
    @Environment(\.openURL) var openURL
    
    @EnvironmentObject private var userSelected: UserSelected
    @AppStorage("deadlineTime") private var AppStorageDeadlineTime: Date = Date()

    @FetchRequest(sortDescriptors: []) var lists: FetchedResults<ToDoList>
    @FetchRequest(sortDescriptors: []) var subToDos: FetchedResults<SubToDo>

    let editViewType: EditViewType

    //Standardwerte für ein ToDo
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
    
    //Toggles und Bedingungen für eine Animation
    @State var showDeadline = true
    @State var showNotification = true
    @State var showPriorityPopover = false
    @State private var overDeleteButton = false

    //Kommunikation mit anderen Views
    @Binding var isPresented: Bool
    @State var showListPicker: Bool = false
    
    var body: some View {
        ZStack{
            VStack{
                //List-Picker
                Button(action: {
                    showListPicker.toggle()
                }, label: {
                    HStack{
                        SystemCircleIcon(image: getToDoListSymbol(with: listID), size: 20, backgroundColor: getToDoListColor(with: listID))
                        Text(list)
                            .foregroundColor(getToDoListColor(with: listID))
                        Spacer()
                    }
                })
                .popover(isPresented: $showListPicker){
                    VStack{
                        Text("Liste auswählen").font(.title2.bold())
                        ToDoEditViewListPicker(listsValueString: $list, listsValueID: $listID)
                    }
                    .padding()
                }.buttonStyle(.plain)
                //Gruppe von Text - Titel, Notizen und URL
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
                
                ScrollView(showsIndicators: false){
                    VStack(spacing: 20){
                        //Gruppe von Buttons - Deadline, Notification, Markiert, Prioritäten, Bilder
                        VStack{
                            HStack{
                                Text("Allgemein").font(.headline)
                                Spacer()
                            }
                            
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
                            
                            //Notification
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
                            
                            //Ist markiert
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
                            
                            //Priorität
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
                        //Bilder
                        ImageView(images: $images)
                        //Teil-Erinnerung
                        SubToDoListView(id: id)
                    }
                }
                //"Abbrechen", "Löschen" und "Fertig" - Button
                SubmitButtonsWithCondition(condition: title != "" && list != "", isPresented: $isPresented, updateAction: {
                    switch(editViewType){
                    case .edit:
                        updateToDo(editViewType: editViewType, todo: todo)
                    case .add:
                        updateToDo(editViewType: editViewType)
                    }
                    userSelected.selectedDate = deadline
                }, deleteAction: {
                    deleteToDo()
                    userSelected.selectedDate = deadline
                }, cancelAction: {
                    userSelected.selectedDate = deadline
                }, editViewType: editViewType, buttonType: .todos)
            }
            .padding()
        }
        .background(.ultraThinMaterial)
        .frame(minWidth: Sizes.defaultSheetWidth, minHeight: Sizes.defaultSheetHeightEditView)
        .onAppear{
            //Weise die Werte hinzu, wenn die View als erstes Mal gezeigt wird
            switch(editViewType){
            case .add:
                //Fall des Hinzufügens
                deadline = userSelected.selectedDate
                if deadline == Dates.defaultDate{
                    showDeadline = false
                    deadline = combineDateAndTime(date: getDate(date: Date()), time: getTime(date: AppStorageDeadlineTime))
                } else {
                    deadline = combineDateAndTime(date: getDate(date: userSelected.selectedDate), time: getTime(date: AppStorageDeadlineTime))
                }
                notification =  combineDateAndTime(date: getDate(date: userSelected.selectedDate), time: getTime(date: Date()))
                list = userSelected.selectedToDoList
                listID = userSelected.selectedToDoListID
            case .edit:
                //Fall einer Datenübergabe -> Anzeige
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
                isMarked = todo.todoIsMarked
                list = todo.todoList!
                listID = todo.idOfToDoList!
                priority = Int(todo.todoPriority)
                images = CoreDataToNSImageArray(coreDataObject: todo.todoImages) ?? []
            }
            if notification == Dates.defaultDate{
                showNotification = false
                notification = Date()
            }
        }
    }
}

extension ToDoEditView{
    //Gib Listenfarbe der Erinnerungsliste für den To-Do
    func getToDoListColor(with: UUID) -> Color{
        var color: String = ""
        lists.nsPredicate = NSPredicate(format: "listID == %@", with as CVarArg)
        for list in lists{
            color = list.listColor!
        }
        return getColorFromString(string: color)
    }
    //Gib Listensymbol der Erinnerungsliste für den To-Do
    func getToDoListSymbol(with: UUID) -> String{
        var symbol = ""
        lists.nsPredicate = NSPredicate(format: "listID == %@", with as CVarArg)
        for list in lists{
            symbol = list.listSymbol!
        }
        return symbol
    }
    
    //Aktualisiere oder Füge To-Do hinzu
    func updateToDo(editViewType: EditViewType, todo: ToDo = ToDo()){
        var objToDo = todo
        if editViewType == .add{
            objToDo = ToDo(context: viewContext)
            objToDo.todoID = id
        }
        //Texte
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
        if showNotification{
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
        saveContext(context: viewContext)
    }
    //Lösche die Erinnerung und alle Teilerinnerungen mit sich
    func deleteToDo(){
        withAnimation {
            deleteUserNotification(identifier: todo.todoID!)
            viewContext.delete(todo)
            subToDos.nsPredicate = NSPredicate(format: "idOfMainToDo == %@", todo.todoID! as CVarArg)
            for subToDo in subToDos{
                viewContext.delete(subToDo)
            }
            saveContext(context: viewContext)
        }
    }
}
