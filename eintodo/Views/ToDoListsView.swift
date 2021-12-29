//
//  ToDoListsView.swift
//  eintodo
//
//  Created by anh :) on 28.12.21.
//

import SwiftUI

struct ToDoListsView: View {
    @Environment(\.managedObjectContext) public var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \ToDoList.listTitle, ascending: true)]) var lists: FetchedResults<ToDoList>
    
    @State var selectedDate = Date()
    @State var lastSelectedDate = Date()
    @Binding var showDoneToDos: Bool
    
    @State var listViewType: ListViewTypes = .dates
    @State var listViewIsActive: Bool = false
    @State var showCreateListSheet: Bool = false
    @State var selectedList: String = ""

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
                                            lastSelectedDate = Date()
                                            selectedDate = Date()
                                            listViewType = .dates
                                            self.listViewIsActive = true
                                        }
                                    }, label: {
                                        ToDoListsViewMainButtonIcon(title: "Heute", imageName: "calendar.circle.fill", backgroundColor: .indigo)
                                    }).buttonStyle(.plain)
                                    
                                    //In Past and not done
                                    Button(action: {
                                        withAnimation{
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
                                            lastSelectedDate = Date()
                                            selectedDate = Date()
                                            listViewType = .all
                                            self.listViewIsActive = true
                                        }
                                    }, label: {
                                        ToDoListsViewMainButtonIcon(title: "Alle", imageName: "tray.circle.fill", backgroundColor: .gray)
                                    }).buttonStyle(.plain)
                                    
                                    //All To-Dos
                                    Button(action: {
                                        withAnimation{
                                            lastSelectedDate = Date()
                                            selectedDate = Date()
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
                                            Image(systemName: "list.bullet.circle.fill")
                                                .resizable()
                                                .frame(width: 20, height: 20)
                                            Button(action: {
                                                selectedList = list.listTitle!
                                                self.listViewType = .list
                                                self.listViewIsActive = true
                                            }, label: {
                                                Text(list.listTitle!).font(.body)
                                            }).buttonStyle(.plain)
                                            Spacer()
                                            Button(action: {
                                                
                                            }, label: {
                                                Image(systemName: "info.circle")
                                                    .foregroundColor(selectedList == list.listTitle! ? .white : Colors.primaryColor)
                                            }).buttonStyle(.plain)
                                        }
                                        .padding(.top, 6.5)
                                        .padding(.bottom, 6.5)
                                        .padding(.leading, 5)
                                        .padding(.trailing, 5)
                                        .background(selectedList == list.listTitle! ? .indigo : .clear)
                                        .cornerRadius(5)
                                    }
                                }
                            }
                        }
                    }
                    Spacer()
                    HStack{
                        Button(action: {
                            showCreateListSheet.toggle()
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
                            .sheet(isPresented: $showCreateListSheet){
                                ToDoListsCreateListView(showCreateListSheet: $showCreateListSheet)
                            }
                    }
                    .padding(.leading, 10)
                    .padding(.trailing, 10)
                    .padding(.bottom, 12.5)
                    .padding(.top, 5)
                }
                
                VStack{
                    NavigationLink(destination: ListView(lastSelectedDate: lastSelectedDate, showDoneToDos: $showDoneToDos, selectedDate: $selectedDate, lastSelectedDateBinding: $lastSelectedDate, type: listViewType, list: selectedList), isActive: $listViewIsActive){ EmptyView() }
                }.hidden()
            }
            .frame(minWidth: 275)
        }
        .navigationTitle("Listen")
        .toolbar{
            ToolbarItem{
                Button(showDoneToDos ? "Erledigte ausblenden" : "Erledigte einblenden"){
                    showDoneToDos.toggle()
                }
            }
            
            ToolbarItem{
                Button("Alle löschen"){
                    deleteAllToDoList()
                    let newToDoList = ToDoList(context: viewContext)
                    newToDoList.listID = UUID()
                    newToDoList.listTitle = "Neue Liste"
                    newToDoList.listDescription = "Eine Liste, wo man Erinnerungen hinzufügen kann"
                    do{
                        try viewContext.save()
                    }catch{
                        let nsError = error as NSError
                        fatalError("Could not add a first List in ContentView: \(nsError), \(nsError.userInfo)")
                    }
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
