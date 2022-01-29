//
//  ToDoListsView.swift
//  eintodo
//
//  Created by anh :) on 28.12.21.
//

import SwiftUI

struct ToDoListsView: View {
    @Environment(\.managedObjectContext) public var viewContext
    @EnvironmentObject private var userSelected: UserSelected
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \ToDo.todoTitle, ascending: true)]) var todos: FetchedResults<ToDo>
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \ToDoList.listTitle, ascending: true)]) var lists: FetchedResults<ToDoList>
    
    @State var listViewType: ListViewTypes = .dates
    @State var listViewIsActive: Bool = false
    
    @State var showToDoListsDetailView: Bool = false
    
    //Hover effects
    @State var userListPushed = false

    var body: some View {
        NavigationView{
            ZStack{
                VStack{
                    List{
                        VStack(spacing: 20){
                            VStack{
                                HStack{
                                    //Today
                                    Button(action: {
                                        withAnimation{
                                            userSelected.selectedToDoList = "Heute"
                                            userSelected.selectedToDoListID = UUID()
                                            userSelected.lastSelectedDate = Date()
                                            userSelected.selectedDate = Date()
                                            listViewType = .dates
                                            self.listViewIsActive = true
                                        }
                                    }, label: {
                                        ToDoListsViewMainButtonIcon(title: "Heute", imageName: "calendar.circle.fill", backgroundColor: .indigo)
                                    }).buttonStyle(.plain)
                                    
                                    //In Past and not done
                                    Button(action: {
                                        withAnimation{
                                            userSelected.selectedToDoList = "Fällig"
                                            userSelected.selectedToDoListID = UUID()
                                            listViewType = .inPastAndNotDone
                                            self.listViewIsActive = true
                                        }
                                    }, label: {
                                        ToDoListsViewMainButtonIcon(title: "Fällig", imageName: "clock.circle.fill", backgroundColor: .red)
                                    }).buttonStyle(.plain)
                                }
                                
                                HStack{
                                    //All To-Dos
                                    Button(action: {
                                        withAnimation{
                                            userSelected.selectedToDoList = "Alle"
                                            userSelected.selectedToDoListID = UUID()
                                            userSelected.lastSelectedDate = Date()
                                            userSelected.selectedDate = Date()
                                            listViewType = .all
                                            self.listViewIsActive = true
                                        }
                                    }, label: {
                                        ToDoListsViewMainButtonIcon(title: "Alle", imageName: "tray.circle.fill", backgroundColor: .gray)
                                    }).buttonStyle(.plain)
                                    
                                    //Marked
                                    Button(action: {
                                        withAnimation{
                                            userSelected.selectedToDoList = "Markiert"
                                            userSelected.selectedToDoListID = UUID()
                                            userSelected.lastSelectedDate = Date()
                                            userSelected.selectedDate = Date()
                                            listViewType = .marked
                                            self.listViewIsActive = true
                                        }
                                    }, label: {
                                        ToDoListsViewMainButtonIcon(title: "Markiert", imageName: "star.circle.fill", backgroundColor: .orange)
                                    }).buttonStyle(.plain)
                                }
                            }
                            
                            //User Lists
                            VStack(spacing: 10){
                                HStack{
                                    Text("Meine Listen").font(.title2.bold())
                                    Spacer()
                                    HStack{
                                        Button(action: {
                                            showToDoListsDetailView.toggle()
                                        }, label: {
                                            Text("Neue Liste")
                                                .foregroundColor(Colors.primaryColor)
                                        })
                                            .buttonStyle(.plain)
                                            .sheet(isPresented: $showToDoListsDetailView){
                                                ToDoListDetailView(type: .add, isPresented: $showToDoListsDetailView, toDoList: ToDoList())
                                            }
                                    }
                                }
                                //ForEach, if its selected, do the styling of background blue and so on...
                                VStack(spacing: 0){
                                    ForEach(lists, id: \.self){ list in
                                        HStack{
                                            if(userSelected.selectedToDoListID == list.listID!){
                                                Rectangle()
                                                    .fill(getColorFromString(string: list.listColor ?? "indigo"))
                                                    .frame(width: 5)
                                                    .cornerRadius(10)
                                            }
                                            //ListRowItem
                                            Button(action: {
                                                withAnimation{
                                                    userSelected.selectedToDoList = list.listTitle!
                                                    userSelected.selectedToDoListID = list.listID!
                                                    self.listViewType = .list
                                                    self.listViewIsActive = true
                                                    userListPushed = true
                                                }
                                            }, label: {
                                                ZStack{
                                                    Circle().fill(getColorFromString(string: list.listColor ?? "indigo"))
                                                        .frame(width: 25, height: 25)
                                                    Image(systemName: list.listSymbol ?? "list.bullet")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 12.5, height: 12.5)
                                                        .foregroundColor(.white)
                                                }
                                                Text(list.listTitle!).font(.body)
                                                Spacer()
                                            }).buttonStyle(.plain)
                                            
                                            //Counter
                                            Text("\(todos.count)")
                                                .font(.body)
                                                .fontWeight(.light)
                                                .foregroundColor(userSelected.selectedToDoListID == list.listID! ? getColorFromString(string: list.listColor ?? "indigo") : .gray)
                                            
                                            //Info button
                                            SheetButtonToDoList(list: list)
                                        }
                                        .padding(.top, 6.5)
                                        .padding(.bottom, 6.5)
                                    }
                                }
                            }
                        }
                    }
                    Spacer()
                }
                
                VStack{
                    NavigationLink(destination: ListView(type: listViewType, userSelected: userSelected), isActive: $listViewIsActive){ EmptyView() }
                }.hidden()
            }
            .frame(minWidth: 300)
            .onAppear{
                withAnimation{
                    userSelected.selectedToDoList = "Heute"
                    userSelected.selectedToDoListID = UUID()
                    userSelected.lastSelectedDate = Date()
                    userSelected.selectedDate = Date()
                    listViewType = .dates
                    self.listViewIsActive = true
                }
            }
        }
        .navigationTitle(userSelected.selectedToDoList)
        .toolbar{
            ToolbarItem{
                Button("Alle löschen"){
                    deleteAllToDoList()
                    let newToDoList = ToDoList(context: viewContext)
                    newToDoList.listID = UUID()
                    newToDoList.listTitle = "Neue Liste"
                    newToDoList.listDescription = "Eine Liste, wo man Erinnerungen hinzufügen kann"
                    newToDoList.listColor = "indigo"
                    newToDoList.listSymbol = "list.bullet"
                    do{
                        try viewContext.save()
                    }catch{
                        let nsError = error as NSError
                        fatalError("Could not add a first List in ContentView: \(nsError), \(nsError.userInfo)")
                    }
                }
            }
            ToolbarItem{
                Button(userSelected.showDoneToDos ? "Erledigte ausblenden" : "Erledigte einblenden"){
                    userSelected.showDoneToDos.toggle()
                }
            }
        }
    }
}

extension ToDoListsView{
    func deleteAllToDoList(){
        for list in lists{
            viewContext.delete(list)
        }
        do{
            try viewContext.save()
        }catch{
            let nsError = error as NSError
            fatalError("Could not delete all CoreData-Entities in ToDoListsView: \(nsError), \(nsError.userInfo)")
        }
    }
}

struct SheetButtonToDoList: View{
    @ObservedObject var list: ToDoList
    @EnvironmentObject private var userSelected: UserSelected
    @State var showToDoListsDetailView: Bool = false
    
    var body: some View{
        Button(action: {
            showToDoListsDetailView.toggle()
        }, label: {
            Image(systemName: "info.circle")
                .foregroundColor(userSelected.selectedToDoListID == list.listID ?? UUID() ? getColorFromString(string: list.listColor ?? "indigo") : .gray)
        }).buttonStyle(.plain)
            .sheet(isPresented: $showToDoListsDetailView){
                ToDoListDetailView(type: .display, isPresented: $showToDoListsDetailView, toDoList: list)
            }
    }
}
