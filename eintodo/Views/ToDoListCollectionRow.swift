//
//  ToDoListCollectionRow.swift
//  eintodo
//
//  Created by anh :) on 28.12.21.
//

/**
 ToDoListCollectionDefaultRow ist eine Zeile für jede vom Programm gelieferte Liste (Sortierte Listen) im ContentView (Sidebar-Leiste)
 ToDoListCollectionRow ist eine Zeile für jede benutzerdefinierte Liste (Meine Liste) im ContentView (Sidebar-Leiste)
 */

import SwiftUI

struct ToDoListCollectionDefaultRow: View{
    @EnvironmentObject var userSelected: UserSelected
    @FetchRequest var todos: FetchedResults<ToDo>
    let title: String
    let systemName: String
    let tag: Int
    let filter: ToDoListFilterType
    init(us: UserSelected, title: String, systemName: String, tag: Int, filter: ToDoListFilterType){
        self.title = title
        self.systemName = systemName
        self.tag = tag
        self.filter = filter
        let fetchAttributes = filterToDo(us: us, filterType: filter)
        _todos = FetchRequest(sortDescriptors: fetchAttributes.sortDescriptors, predicate: fetchAttributes.predicate, animation: .default)
    }
    var body: some View{
        NavigationLink(destination: ToDoListView(title: title, rowType: .calendar, listFilterType: filter, userSelected: userSelected), tag: tag, selection: $userSelected.selectedView){
            HStack{
                Image(systemName: systemName)
                    .foregroundColor(userSelected.selectedView == tag ? .white : Colors.primaryColor)
                Text(title)
                Spacer()
                //Item-Counter für eine ToDoList
                Text("\(countNotDoneToDos())")
                    .font(.body)
                    .fontWeight(.light)
            }
        }
    }
    //Funktion: Zähle noch nicht erledigte Todos
    private func countNotDoneToDos()->Int{
        var counter = 0
        for todo in todos{
            if(!todo.todoIsDone){
                counter += 1
            }
        }
        return counter
    }
}

struct ToDoListCollectionRow: View{
    @Environment(\.colorScheme) var appearance
    @EnvironmentObject var userSelected: UserSelected
    @FetchRequest var todos: FetchedResults<ToDo>
    @ObservedObject var list: ToDoList
    
    @State var showToDoListsEditView: Bool = false
    @State var onHover: Bool = false

    init(list: ToDoList){
        let id = list.listID ?? UUID()
        _todos = FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \ToDo.todoTitle, ascending: true)], predicate: NSPredicate(format: "idOfToDoList == %@ && todoIsDone == false", id as CVarArg), animation: .default)
        _list = ObservedObject(wrappedValue: list)
    }
    var body: some View{
        HStack{
            //Icon-Liste
            SystemCircleIcon(image: list.listSymbol ?? "list.bullet", size: 20, backgroundColor: getColorFromString(string: list.listColor ?? "standard"))
            //Name der Liste
            Text(list.listTitle ?? "Error").font(.body)
            Spacer()
            //Information Button um Detail Sheet der To-Do-Liste anzuzeigen
            if(onHover){
                Button(action: {
                    withAnimation{
                        userSelected.selectedToDoListID = list.listID ?? UUID()
                        showToDoListsEditView.toggle()
                    }
                }, label: {
                    Image(systemName: "info.circle")
                }).buttonStyle(.plain)
                    .sheet(isPresented: $showToDoListsEditView){
                        ToDoListCollectionEditView(type: .edit, isPresented: $showToDoListsEditView, toDoList: list)
                    }
            }
            //Item-Counter von Liste
            Text("\(todos.count)")
                .font(.body)
                .fontWeight(.light)
        }
        .onHover{ over in //Wenn der Mauszeiger über einer der Listen sind Zeige Info-Button
            if !showToDoListsEditView{
                onHover = over
            }
        }
        .onChange(of: showToDoListsEditView){ _ in
            if !showToDoListsEditView{
                onHover = showToDoListsEditView
            }
        }
    }
}
