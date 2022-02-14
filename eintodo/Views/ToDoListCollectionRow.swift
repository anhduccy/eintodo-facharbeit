//
//  ToDoListCollectionRow.swift
//  eintodo
//
//  Created by anh :) on 28.12.21.
//

/**
 ToDoListCollectionRow ist eine Zeile für jede benutzerdefinierte Liste im ContentView (Sidebar-Leiste)
 */

import SwiftUI

//Subviews of ToDoListCollection
struct ToDoListCollectionRow: View{
    @EnvironmentObject var userSelected: UserSelected
    @FetchRequest var todos: FetchedResults<ToDo>
    @ObservedObject var list: ToDoList
    
    @State var showToDoListsDetailView: Bool = false

    init(list: ToDoList){
        _todos = FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \ToDo.todoTitle, ascending: true)], predicate: NSPredicate(format: "idOfToDoList == %@ && todoIsDone == false", list.listID! as CVarArg), animation: .default)
        _list = ObservedObject(wrappedValue: list)
    }
    
    var body: some View{
        HStack{
            //List icon
            SystemCircleIcon(image: list.listSymbol ?? "list.bullet", size: 20, backgroundColor: getColorFromString(string: list.listColor ?? "indigo"))
            //List name
            Text(list.listTitle ?? "Error").font(.body)
            Spacer()
            //Counter of ToDos in List
            Text("\(todos.count)")
                .font(.body)
                .fontWeight(.light)
            //Info button for List
            Button(action: {
                withAnimation{
                    userSelected.selectedToDoListID = list.listID ?? UUID()
                    showToDoListsDetailView.toggle()
                }
            }, label: {
                Image(systemName: "info.circle")
            })
                .buttonStyle(.plain)
                .sheet(isPresented: $showToDoListsDetailView){
                    ToDoListCollectionEditView(type: .display, isPresented: $showToDoListsDetailView, toDoList: list)
                }
        }
    }
}
