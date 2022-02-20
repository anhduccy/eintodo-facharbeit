//
//  ToDoListCollectionRow.swift
//  eintodo
//
//  Created by anh :) on 28.12.21.
//

/**
 ToDoListCollectionDefaultRow ist eine Zeile für jede vom Programm gelieferte Liste im ContentView (Sidebar-Leiste)
 ToDoListCollectionRow ist eine Zeile für jede benutzerdefinierte Liste im ContentView (Sidebar-Leiste)
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
                //Counter of ToDos in List
                Text("\(countNotDoneToDos())")
                    .font(.body)
                    .fontWeight(.light)
            }
        }
    }
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
            //List icon
            SystemCircleIcon(image: list.listSymbol ?? "list.bullet", size: 20, backgroundColor: getColorFromString(string: list.listColor ?? "standard"))
            //List name
            Text(list.listTitle ?? "Error").font(.body)
            Spacer()
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
            //Counter of ToDos in List
            Text("\(todos.count)")
                .font(.body)
                .fontWeight(.light)
        }
        .onHover{ over in
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
