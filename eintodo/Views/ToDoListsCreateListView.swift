//
//  ToDoListsCreateListView.swift
//  eintodo
//
//  Created by anh :) on 29.12.21.
//

import SwiftUI

struct ToDoListsCreateListView: View{
    @Environment(\.managedObjectContext) public var viewContext

    @Binding var showCreateListSheet: Bool
    @State var title: String = "Liste"
    @State var description: String = ""
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
                        withAnimation{
                            showCreateListSheet.toggle()
                        }
                    }
                    .buttonStyle(.plain)
                    Spacer()
                    Button(action: {
                        if(title != ""){
                            addToDoList()
                        }
                        withAnimation{
                            showCreateListSheet.toggle()
                        }
                    }, label: {
                        Text("Fertig")
                    })
                        .buttonStyle(.plain)
                }
            }
            .padding()
        }
        .frame(width: Sizes.defaultSheetWidth, height: Sizes.defaultSheetHeight)
    }
}

extension ToDoListsCreateListView{
    public func addToDoList(){
        let newToDoList = ToDoList(context: viewContext)
        newToDoList.listID = UUID()
        newToDoList.listTitle = title
        newToDoList.listDescription = description
        do{
            try viewContext.save()
        }catch{
            let nsError = error as NSError
            fatalError("Could not add CoreData-Entity in ToDoListCreateList: \(nsError), \(nsError.userInfo)")
        }
    }
}
