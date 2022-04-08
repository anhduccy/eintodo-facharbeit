//
//  ListView.swift
//  eintodo
//
//  Created by anh :) on 12.12.21.
//

import SwiftUI
import Foundation

/**
 Die Ansicht, wo gefilterte Erinnerungen in einer Liste gezeigt werden. 
 */

struct ToDoListView: View {
    @Environment(\.managedObjectContext) public var viewContext
    @Environment(\.colorScheme) public var colorScheme
    @EnvironmentObject private var userSelected: UserSelected
    @FetchRequest var todos: FetchedResults<ToDo>
        
    init(title: String, rowType: ToDoListRowType, listFilterType: ToDoListFilterType = .dates, userSelected: UserSelected){
        let fetchAttributes = filterToDo(us: userSelected, filterType: listFilterType)
        _todos = FetchRequest(sortDescriptors: fetchAttributes.sortDescriptors, predicate: fetchAttributes.predicate, animation: .default)
        self.title = title
        self.rowType = rowType
    }
    let title: String //String für den Titel der Liste
    let rowType: ToDoListRowType //Listtyp oder Kalendertyp
    
    //Grafische Oberfläche
    var body: some View {
        VStack{
            VStack(spacing: 10){
                //Progress-Kreis (oben rechts)
                HStack{
                    LeftText(text: title, font: .largeTitle, fontWeight: .bold)
                    Spacer()
                    if(!todos.isEmpty){
                        ProgressCircle(todos: todos)
                    }
                }.padding(.leading, 7.5)
                //Listenansicht mit allen Erinnerungen
                List{
                    //Der Fall wenn keine Erinnerungen vorhanden sind
                    if(todos.isEmpty){
                        VStack{
                            LeftText(text: "Du hast noch nichts für den Tag geplant")
                                .foregroundColor(.gray)
                        }
                        
                    //Der Fall wenn alle Erinnerungen erledigt sind
                    } else if(isAllDone() && !userSelected.showDoneToDos){
                        VStack{
                            LeftText(text: "Du hast alle Erinnerungen bereits erledigt")
                                .foregroundColor(.gray)
                            HStack{
                                Button(action: {
                                    withAnimation{
                                        userSelected.showDoneToDos.toggle()
                                    }
                                }, label: {
                                    Text("Erledigte einblenden")
                                        .padding(10)
                                        .foregroundColor(.gray)
                                        .overlay(
                                        RoundedRectangle(cornerRadius: 5)
                                            .stroke(Color.gray, lineWidth: 1)
                                        )
                                }).buttonStyle(.plain)
                                    .padding(.leading, 1)
                                Button(action: {
                                    withAnimation{
                                        for todo in todos{
                                            if todo.todoIsDone{
                                                viewContext.delete(todo)
                                                saveContext(context: viewContext)
                                            }
                                        }
                                    }
                                }, label: {
                                    Text("Alle Erledigten löschen")
                                        .padding(10)
                                        .foregroundColor(.gray)
                                        .overlay(
                                        RoundedRectangle(cornerRadius: 5)
                                            .stroke(Color.gray, lineWidth: 1)
                                        )
                                }).buttonStyle(.plain)
                                    .padding(. leading, 1)
                                Spacer()
                            }
                        }
                    } else {
                        //Jede Erinnerung
                        ForEach(todos, id: \.self){ todo in
                            HStack{
                                ToDoListRow(rowType: rowType, todo: todo)
                            }
                        }
                        .padding(.top, 3)
                        .padding(.bottom, 3)
                        .padding(.trailing, 12.5)
                        .padding(.leading, 12.5)
                    }
                }
            }
            .listStyle(.plain)
        }
        .padding()
        .frame(minWidth: 450, minHeight: 400)
        .background(colorScheme == .dark ? .clear : .white)
    }
    //Funktion: Wenn alle Erinnerungen erledigt sind -> true
    public func isAllDone()->Bool{
        var item = 0
        for todo in todos{
            if todo.todoIsDone{
                item += 1
            }
        }
        if item == todos.count{
            return true
        } else {
            return false
        }
    }
}

//Sub-Views: Erinnerungsreihe
struct ToDoListRow: View {
    @Environment(\.managedObjectContext) public var viewContext
    @Environment(\.colorScheme) var appearance
    @EnvironmentObject private var userSelected: UserSelected
    @FetchRequest var lists: FetchedResults<ToDoList>
    @FetchRequest var subToDos: FetchedResults<SubToDo>
    
    @ObservedObject var todo: ToDo //ToDo von ForEach wird rübergenommen
    @State var isPresented: Bool = false
    
    //Standard-Einstellungen für die Views
    let rowType: ToDoListRowType
    let SystemImageSize: CGFloat = 25
    @State var color: Color

    init(rowType: ToDoListRowType, todo: ToDo) {
        self.todo = todo
        let id = todo.todoID ?? UUID()
        _subToDos = FetchRequest(sortDescriptors: [], predicate: NSPredicate(format: "idOfMainToDo == %@", id as CVarArg), animation: .default)
        let listID = todo.idOfToDoList ?? UUID()
        _lists = FetchRequest(sortDescriptors: [], predicate: NSPredicate(format: "listID == %@", listID as CVarArg), animation: .default)
        self.rowType = rowType
        _color = State(initialValue: Colors.primaryColor)
    }

    //View
    var body: some View {
        ZStack{
            //Hintergrund
            Button(action: {
                isPresented.toggle()
            }, label: {
                RoundedRectangle(cornerRadius: 8.5)
                    .fill(.ultraThinMaterial)
                    .shadow(color: color, radius: 3)
            }).buttonStyle(.plain)
            HStack{
                //Button zum Erledigen
                Button(action: {
                    todo.todoIsDone.toggle()
                    if(todo.todoIsDone == true){
                        deleteUserNotification(identifier: todo.todoID!)
                    }
                    saveContext(context: viewContext)
                    }, label: {
                    if(todo.todoIsDone){
                        ZStack{
                            RoundedRectangle(cornerRadius: 5).fill(.white)
                            SystemImage(image: "checkmark.square.fill", color: color, size: SystemImageSize/5*4, isActivated: true)
                        }
                    } else {
                        SystemImage(image: "square", color: .gray, size: SystemImageSize, isActivated: true)
                    }
                })
                    .frame(width: SystemImageSize/5*4, height: SystemImageSize/5*4)
                    .buttonStyle(.plain)
                
                Button(action: {
                    isPresented.toggle()
                }, label: {
                    //Texte - Titel, Fälligkeitsdatum, und Erinnerung
                    VStack(spacing: 1){
                        LeftText(text: todo.todoTitle ?? "Error", font: .headline, fontWeight: .semibold)
                        if todo.todoDeadline != Dates.defaultDate{
                            LeftText(text: DateInString(date: todo.todoDeadline ?? Dates.defaultDate, type: "deadline"), fontWeight: .light)
                                .foregroundColor(isDateInPast(date: todo.todoDeadline ?? Dates.defaultDate, defaultColor: .gray))
                        }
                        if todo.todoNotification != Dates.defaultDate{
                            LeftText(text: DateInString(date: todo.todoNotification ?? Dates.defaultDate, type: "notification"),  fontWeight: .light)
                                .foregroundColor(.gray)
                        }
                    }
                    HStack(spacing: 4.5){
                        //Anzeige von vorhandenen Informationen
                        if(todo.todoPriority != 0){
                            ZStack{
                                Image(systemName: getPriority())
                                    .foregroundColor(Colors.primaryColor)
                            }.frame(width: SystemImageSize, height: SystemImageSize)
                        }
                        if(todo.todoNotes != ""){ //Wenn Notizen vorhanden
                            SystemCircleIcon(image: "note.text", size: SystemImageSize, backgroundColor: color)
                        }
                        if(hasImage()){ //Wenn Foto vorhanden
                            SystemCircleIcon(image: "photo.fill", size: SystemImageSize, backgroundColor: color)
                        }
                        if(!subToDos.isEmpty){ //Wenn Unter-To-Dos vorhanden
                            SystemCircleIcon(image: getNumberIcon(), size: SystemImageSize, backgroundColor: color)
                        }
                        //Zeige List-Icon, in welcher Liste das ist
                        if(rowType == .calendar){
                            SystemCircleIcon(image: lists.first?.listSymbol ?? "list.bullet", size: SystemImageSize, backgroundColor: getColorFromString(string: lists.first?.listColor ?? "standard"))
                        }
                    }
                }).buttonStyle(.plain)
                
                //IsMarked Button
                Button(action: {
                    withAnimation{
                        todo.todoIsMarked.toggle()
                        saveContext(context: viewContext)
                    }
                }, label: {
                    SystemCircleIcon(image: todo.todoIsMarked ? "star.fill" : "star", size: SystemImageSize, backgroundColor: todo.todoIsMarked ? .init(red: 250/255, green: 187/255, blue: 2/255) : .gray, isActivated: todo.todoIsMarked)
                }).buttonStyle(.plain)
            }.padding(12.5)
            .sheet(isPresented: $isPresented) {
                ToDoEditView(editViewType: .edit, todo: todo, list: todo.todoList ?? "Error", listID: todo.idOfToDoList ?? UUID(), isPresented: $isPresented)
            }
        }
    }
    //Funktion: Gib Icon-Name für die Anzahl von Teil-Erinnerungen
    private func getNumberIcon()->String{
        let int = subToDos.count
        let iconName = "\(int).circle.fill"
        return iconName
    }
    //Funktion: Wenn Erinnerungen Bilder haben -> true
    private func hasImage()->Bool{
        if CoreDataToNSImageArray(coreDataObject: todo.todoImages)?.isEmpty ?? [].isEmpty{
            return false
        } else {
            return true
        }
    }
    //Funktion: Gib Priorität der Erinnerungen wieder
    private func getPriority()->String{
        switch todo.todoPriority{
        case 1:
            return "exclamationmark"
        case 2:
            return "exclamationmark.2"
        case 3:
            return "exclamationmark.3"
        default:
            return ""
        }
    }
}


 
