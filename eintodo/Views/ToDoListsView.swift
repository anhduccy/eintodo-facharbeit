//
//  ToDoListsView.swift
//  eintodo
//
//  Created by anh :) on 28.12.21.
//

import SwiftUI

struct ToDoListsViewMainButtonIcon: View{
    let title: String
    let imageName: String
    let size: CGFloat
    let foregroundColor: Color
    let backgroundColor: Color
    
    init(title: String, imageName: String, size: CGFloat = 25, foregroundColor: Color = .white, backgroundColor: Color){
        self.title = title
        self.imageName = imageName
        self.size = size
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
    }
    
    var body: some View{
        HStack{
            Image(systemName: imageName)
                .resizable()
                .frame(width: size, height: size)
                .foregroundColor(foregroundColor)
            Text(title).font(.headline)
                .foregroundColor(foregroundColor)
            Spacer()
        }
        .padding(7.5)
        .background(backgroundColor)
        .cornerRadius(5)
    }
}

struct ToDoListsCreateListView: View{
    @Binding var showCreateListSheet: Bool
    @State var title: String = "Liste"
    @State var selectedColor: Color = .indigo
    
    let colors: [Color] = [.red, .pink, .yellow, .green, .blue, .indigo, .purple, .brown, .gray]
    var body: some View{
        ZStack{
            VStack{
                TextField("Titel", text: $title)
                    .font(.title.bold())
                    .textFieldStyle(.plain)
                    .foregroundColor(selectedColor)
                HStack{
                    ForEach(colors, id: \.self){ color in
                        Button(action: {
                            withAnimation{
                                selectedColor = color
                            }
                        }, label: {
                            if(selectedColor == color){
                                Circle().fill(color)
                                    .frame(width: 45, height: 45)
                            } else {
                                Circle().fill(color)
                            }

                        })
                            .buttonStyle(.plain)
                    }
                }
                Spacer()
                HStack{
                    Button("Abbrechen"){
                        
                    }
                    .buttonStyle(.plain)
                    Spacer()
                    Button(action: {
                        withAnimation{
                            showCreateListSheet.toggle()
                        }
                    }, label: {
                        Text("Schließen")
                    })
                        .buttonStyle(.plain)
                }
            }
            .padding()
        }
        .frame(width: Sizes.defaultSheetWidth, height: Sizes.defaultSheetHeight)
    }
}

struct ToDoListsView: View {
    @State var selectedDate = Date()
    @State var lastSelectedDate = Date()
    @Binding var showDoneToDos: Bool
    
    @State var listViewType: ListViewTypes = .dates
    @State var listViewIsActive: Bool = false
    @State var showCreateListSheet: Bool = false

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
                            HStack{
                                Text("Meine Listen").font(.headline.bold())
                                Spacer()
                            }
                            VStack{
                                //ForEach Lists
                            }
                            VStack{
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
                        }
                    }
                }
                
                VStack{
                    NavigationLink(destination: ListView(lastSelectedDate: lastSelectedDate, showDoneToDos: $showDoneToDos, selectedDate: $selectedDate, lastSelectedDateBinding: $lastSelectedDate, type: listViewType), isActive: $listViewIsActive){ EmptyView() }
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
        }
    }
}
