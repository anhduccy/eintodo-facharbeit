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
            Spacer()
        }
        .padding(7.5)
        .background(backgroundColor)
        .cornerRadius(5)
    }
}

struct ToDoListsView: View {
    @State var selectedDate = Date()
    @State var lastSelectedDate = Date()
    @Binding var showDoneToDos: Bool
    
    @State var listViewType: ListViewTypes = .dates
    @State var listViewIsActive: Bool = false

    var body: some View {
        NavigationView{
            ZStack{
                List{
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
