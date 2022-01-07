//
//  DetailView.swift
//  eintodo
//
//  Created by anh :) on 12.12.21.
//

import SwiftUI
import UserNotifications
import UniformTypeIdentifiers

struct DetailView: View {
    @Environment(\.managedObjectContext) public var viewContext
    @Environment(\.colorScheme) public var colorScheme
    @Environment(\.openURL) var openURL
    
    @EnvironmentObject private var userSelected: UserSelected
    @AppStorage("deadlineTime") private var AppStorageDeadlineTime: Date = Date()

    @FetchRequest(sortDescriptors: []) var lists: FetchedResults<ToDoList>

    let detailViewType: DetailViewTypes

    //Values for ToDo
    @State var todo: ToDo
    @State var title: String = ""
    @State var notes: String = ""
    @State var url: String = ""
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
            VStack{
                ScrollView{
                    VStack(spacing: 20){
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

                        //Group of Buttons - List, Deadline, Notifications, isMarked, Priorities, Images
                        VStack{
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
                                                .fill(getToDoListColor(with: list))
                                                .frame(width: 25, height: 25)
                                            Image(systemName: getToDoListSymbol(with: list))
                                                .foregroundColor(.white)
                                        }
                                    case .display:
                                        ZStack{
                                            Circle()
                                                .fill(getToDoListColor(with: list))
                                                .frame(width: 25, height: 25)
                                            Image(systemName: getToDoListSymbol(with: list))
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
                            
                            //Priorities
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
                        }
                        //Images
                        ImageView()
                    }
                }
                //Group - Control buttons
                HStack{
                    Button("Abbrechen"){dismissDetailView()}.buttonStyle(.plain).foregroundColor(Colors.secondaryColor)
                    switch(detailViewType){
                    case .display:
                        Spacer()
                        Button(action: {
                            deleteToDo()
                            dismissDetailView()
                        }, label: {
                            IconImage(image: "trash.circle.fill", color: overDeleteButton ? Colors.primaryColor : .red, size: 25, isActivated: true)
                        }).buttonStyle(.plain)
                            .onHover{ over in
                                withAnimation{overDeleteButton = over}
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
                        Button(action: {dismissDetailView()}, label: {
                            Text("Fertig")
                                .font(.body)
                                .fontWeight(.semibold)
                                .foregroundColor(.gray)
                        }).buttonStyle(.plain)
                    }
                }
            }
        }
        .padding()
        .frame(minWidth: Sizes.defaultSheetWidth, minHeight: Sizes.defaultSheetHeight, maxHeight: Sizes.defaultSheetHeight)
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
                } else {
                    list = userSelected.selectedToDoList
                }
            case .display: //Value assignment of CoreData storage, if type is display
                title = todo.title ?? "Error"
                notes = todo.notes ?? "Error"
                url = todo.url ?? "Error"
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
    func getToDoListColor(with: String) -> Color{
        var color: String = ""
        lists.nsPredicate = NSPredicate(format: "listTitle == %@", with as CVarArg)
        for list in lists{
            color = list.color!
        }
        return getColorFromString(string: color)
    }
    public func getToDoListSymbol(with: String) -> String{
        var symbol = ""
        lists.nsPredicate = NSPredicate(format: "listTitle == %@", with as CVarArg)
        for list in lists{
            symbol = list.symbol!
        }
        return symbol
    }
    
    //CORE-DATA - Add, update and delete ToDo
    public func addToDo() {
        withAnimation {
            let newToDo = ToDo(context: viewContext)
            newToDo.id = UUID()
            newToDo.title = title
            newToDo.notes = notes
            newToDo.url = url
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
            todo.url = url
            //Deadline
            if showDeadline{
                todo.deadline = deadline
                updateUserNotification(title: title, id: todo.id!, date: todo.deadline!, type: "deadline")
            }
            if !showDeadline{
                todo.deadline = Dates.defaultDate
            }
            //Notification
            if showNotification{
                todo.notification = notification
                updateUserNotification(title: title, id: todo.id!, date: todo.notification!, type: "notification")
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

//SUBVIEWS
//ImagePickerView - Button to pick image + Area to show the images
struct ImageView: View{
    @State var URLs: [URL] = []
    @State var showImageDetailView: Bool = false
    var body: some View{
        ZStack{
            VStack{
                HStack{
                    Text("Bilder").font(.headline)
                    Spacer()
                }
                HStack{
                    Button(action: selectImage){
                        ZStack{
                            Rectangle()
                                .frame(width: 40, height: 40)
                                .foregroundColor(Colors.primaryColor)
                                .cornerRadius(10)
                                .opacity(0.1)
                            Image(systemName: "plus")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20)
                                .foregroundColor(Colors.primaryColor)
                        }
                    }.buttonStyle(.plain)
                    //ImageArea
                    ScrollView(.horizontal){
                        HStack{
                            ForEach(URLs.indices, id: \.self){ index in
                                ImageButton(URLs: $URLs, selectedIndexOfURL: index, image: load(URL: URLs[index])!)
                            }
                        }
                    }
                    Spacer()
                }
            }
        }
    }
    private func selectImage(){
        let panel = NSOpenPanel()
        panel.prompt = "Bild auswählen"
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = false
        panel.canCreateDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [UTType("public.image")!]
        if panel.runModal() == NSApplication.ModalResponse.OK {
            let results = panel.urls
            for result in results{
                URLs.append(result.absoluteURL)
            }
        }
    }
    private func load(URL: URL) -> NSImage?{
        do {
            let imageData = try Data(contentsOf: URL)
            return NSImage(data: imageData)
        } catch {print("Error loading image in DetailView: \(error)")}
        return nil
    }
}
//ImageDetailView - Show the image in a fuller size
struct ImageDetailView: View{
    @Binding var isPresented: Bool
    @Binding var URLs: [URL]
    @Binding var selectedIndexOfURL: Int
    let image: NSImage
    
    var body: some View{
        VStack{
            Image(nsImage: image)
                .resizable()
                .scaledToFit()
            Spacer()
            HStack{
                Button(action: {
                    isPresented.toggle()
                    URLs.remove(at: selectedIndexOfURL)
                }, label: {
                    Text("Entfernen")
                        .foregroundColor(.red)
                        .font(.body)
                }).buttonStyle(.plain)
                Spacer()
                Button(action: {
                    isPresented.toggle()
                }, label: {
                    Text("Schließen")
                        .foregroundColor(Colors.primaryColor)
                        .font(.body.bold())
                }).buttonStyle(.plain)
            }
            .padding(.leading, 10)
            .padding(.trailing, 10)
            .padding(.bottom, 10)
            .padding(.top, 2.5)
        }
        .frame(height: 500)
    }
}
//ImageButton - For Each Image to open the ImageDetailView
struct ImageButton: View{
    @State var isPresented: Bool = false
    @Binding var URLs: [URL]
    @State var selectedIndexOfURL: Int
    let image: NSImage

    var body: some View{
        Button(action: {
            isPresented.toggle()
        },
        label: {
            Image(nsImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 40, height: 40)
                .cornerRadius(10)

        }).sheet(isPresented: $isPresented){
            ImageDetailView(isPresented: $isPresented, URLs: $URLs, selectedIndexOfURL: $selectedIndexOfURL, image: image)
        }.buttonStyle(.plain)
    }
}
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
//ListPicker to select lists
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
