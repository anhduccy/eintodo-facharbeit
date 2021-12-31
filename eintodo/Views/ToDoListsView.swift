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
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \ToDoList.listTitle, ascending: true)]) var lists: FetchedResults<ToDoList>
    
    @State var listViewType: ListViewTypes = .dates
    @State var listViewIsActive: Bool = false
    @State var showToDoListsDetailView: Bool = false

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
                                    Text("Meine Listen").font(.headline.bold())
                                    Spacer()
                                }
                                .padding(.leading, 5)
                                //ForEach, if its selected, do the styling of background blue and so on...
                                VStack(spacing: 0){
                                    ForEach(lists, id: \.self){ list in
                                        HStack{
                                            //ListRowItem
                                            Button(action: {
                                                withAnimation{
                                                    userSelected.selectedToDoList = list.listTitle!
                                                    self.listViewType = .list
                                                    self.listViewIsActive = true
                                                }
                                            }, label: {
                                                ZStack{
                                                    Circle().fill(getColorFromString(string: list.color ?? "indigo"))
                                                        .frame(width: 25, height: 25)
                                                    Image(systemName: list.symbol ?? "list.bullet")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 12.5, height: 12.5)
                                                        .foregroundColor(.white)
                                                }
                                                Text(list.listTitle!).font(.body)
                                                    .foregroundColor(userSelected.selectedToDoList == list.listTitle! ? .white : .primary)
                                                Spacer()
                                            }).buttonStyle(.plain)
                                            
                                            //Info button
                                            SheetButtonToDoList(list: list)
                                        }
                                        .padding(.top, 6.5)
                                        .padding(.bottom, 6.5)
                                        .padding(.leading, 5)
                                        .padding(.trailing, 5)
                                        .background(userSelected.selectedToDoList == list.listTitle! ? .blue : .clear)
                                        .cornerRadius(5)
                                    }
                                }
                            }
                        }
                    }
                    Spacer()
                    HStack{
                        Button(action: {
                            showToDoListsDetailView.toggle()
                        }, label: {
                            HStack{
                                Image(systemName: "plus.circle.fill")
                                    .resizable()
                                    .frame(width: 17.5, height: 17.5)
                                    .foregroundColor(Colors.primaryColor)
                                Text("Neue Liste hinzufügen").font(.headline)
                                Spacer()
                            }
                        })
                            .buttonStyle(.plain)
                            .sheet(isPresented: $showToDoListsDetailView){
                                ToDoListDetailView(type: .add, isPresented: $showToDoListsDetailView, toDoList: ToDoList())
                            }
                    }
                    .padding(.leading, 10)
                    .padding(.trailing, 10)
                    .padding(.bottom, 12.5)
                    .padding(.top, 5)
                }
                
                VStack{
                    NavigationLink(destination: ListView(type: listViewType, userSelected: userSelected), isActive: $listViewIsActive){ EmptyView() }
                }.hidden()
            }
            .frame(minWidth: 275)
            .onAppear{
                withAnimation{
                    userSelected.selectedToDoList = "Heute"
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
                    newToDoList.color = "indigo"
                    newToDoList.symbol = "list.bullet"
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
    public func deleteAllToDoList(){
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
