//
//  ContentView.swift
//  eintodo
//
//  Created by anh :) on 12.12.21.
//

import SwiftUI
import CoreData

/**
 ContentView definiert Sidebar-Sektionen, führt Initialisierungsschritte durch, strukturiert die App beim erstmaligen Starten
 */
struct ContentView: View {
    //Attribute
    
    //Verknüpfung der Datenbank durch den Kontext
    @Environment(\.managedObjectContext) public var viewContext
    
    //Verknüpfung eines anderen Speichers (Systemeinstellungen)
    @AppStorage("deadlineTime") private var deadlineTime: Date = Date()
    
    //Abrufen verschiedener Ergebnisse von verschiedenen Instanzen: ToDo, ToDoList und SubToDo
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \ToDoList.listTitle, ascending: true)]) var lists: FetchedResults<ToDoList>
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \ToDo.todoTitle, ascending: true)]) var todos: FetchedResults<ToDo>
    @FetchRequest(sortDescriptors: []) var subtodos: FetchedResults<SubToDo>

    //Variablen zur Anzeige der Sheet-Views
    @State var showAddView: Bool = false
    @State var showToDoListCollectionEditView: Bool = false

    //Verknüpfung mit einer Klasse UserSelected, die Attribute enthalten, die oft in vielen Views vorkommen
    @EnvironmentObject private var userSelected: UserSelected

    //Grafische Oberfläche
    var body: some View {
        NavigationView {
            List{
                //Kalender-Link
                NavigationLink(destination: CalendarView(filter: .deadline), tag: 1, selection: $userSelected.selectedView){
                    HStack{
                        Image(systemName: "calendar")
                            .foregroundColor(userSelected.selectedView == 1 ? .white : Colors.primaryColor)
                        Text("Kalender")
                    }
                }
                
                //Link zu den Listen, die nach Attributen gefiltert sind
                Section("Sortierte Listen"){
                    ToDoListCollectionDefaultRow(us: userSelected, title: "Alle", systemName: "tray.2", tag: 2, filter: .all)
                    ToDoListCollectionDefaultRow(us: userSelected, title: "Fällig", systemName: "clock", tag: 3, filter: .inPast)
                    ToDoListCollectionDefaultRow(us: userSelected, title: "Markiert", systemName: "star", tag: 4, filter: .marked)
                }
                
                //Link zu den benutzerdefinierten Listen
                Section(header: Text("Meine Listen")){
                    ForEach(Array(zip(lists.indices, lists)), id: \.1){ index, list in
                        NavigationLink(
                            destination: ToDoListView(title: userSelected.selectedToDoList, rowType: .list, listFilterType: .list, userSelected: userSelected)
                                .onAppear{
                                    userSelected.selectedToDoList = list.listTitle ?? "Error"
                                    userSelected.selectedToDoListID = list.listID ?? UUID()
                                },
                            tag: index + 5,
                            selection: $userSelected.selectedView
                        ){
                            HStack{
                                ToDoListCollectionRow(list: list)
                            }
                        }
                    }
                }
            }
            .listStyle(.sidebar)
            .frame(minWidth: 175)
            .toolbar{
                //Toolbar in der Frame-Leiste
                ToolbarItemGroup(placement: .automatic){
                    Menu(content: {
                        Button(action:{
                            showAddView.toggle()
                        }, label: {
                            Label("Erinnerung hinzufügen", systemImage: "checkmark.circle.fill")
                        })
                        Button(action: {
                            showToDoListCollectionEditView.toggle()
                        }, label: {
                            Label("Liste hinzufügen", systemImage: "list.bullet")
                        })
                    }, label: {
                        Image(systemName: "plus.circle")
                    })
                }
                ToolbarItem(placement: .primaryAction){
                    Button(userSelected.showDoneToDos ? "Erledigte ausblenden" : "Erledigte einblenden"){
                        userSelected.showDoneToDos.toggle()
                    }
                }
            }
        }
        .sheet(isPresented: $showAddView){
            ToDoEditView(editViewType: .add, todo: ToDo(), list: lists.first!.listTitle! , listID: lists.first!.listID!, isPresented: $showAddView)
        }
        .sheet(isPresented: $showToDoListCollectionEditView){
            ToDoListCollectionEditView(type: .add, isPresented: $showToDoListCollectionEditView, toDoList: ToDoList())
        }
        //Initialisierung beim ersten Starten der App
        .onAppear{
            //Eine Liste erstellen, wenn keine vorhanden ist -> Fehlervermeidung
            if(lists.isEmpty){createList(viewContext: viewContext)}
            
            //UserSeleczted Attribute Erstzuweisung, damit die Spaltenansicht direkt einen Wert bekommt
            userSelected.selectedToDoList = lists.first?.listTitle ?? ""
            userSelected.selectedToDoListID = lists.first?.listID ?? UUID()
            
            //Fragt, ob der Nutzer Mitteilung haben möchte
            askForUserNotificationPermission()
            
            //Lösche alle Instanzen, die keinen Primärschlüssel beinhalten
            for todo in todos{
                if todo.todoID == nil {
                    viewContext.delete(todo)
                    saveContext(context: viewContext)
                }
            }
        }
        .onChange(of: deadlineTime){ newValue in
            //Wenn die Systemeinstellung für eine Erinnerung (Fälligkeitsdatum) verändert wird, für jede Erinnerung aktualisieren
            for todo in todos{
                let formattedDate = combineDateAndTime(date: getDate(date: todo.todoDeadline!), time: getTime(date: deadlineTime))
                if todo.todoDeadline != Dates.defaultDate{
                    todo.todoDeadline = formattedDate
                    updateUserNotification(title: todo.todoTitle!, id: todo.todoID!, date: formattedDate, type: "deadline")
                }
                saveContext(context: viewContext)
            }
        }
    }
}
