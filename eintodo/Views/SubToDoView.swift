//
//  SubToDoView.swift
//  eintodo
//
//  Created by anh :) on 31.01.22.
//

import SwiftUI

//SubToDoList - View to add a SubToDo + Area to show the list
struct SubToDoListView: View{
    @Environment(\.managedObjectContext) public var viewContext
    @FetchRequest var subToDos: FetchedResults<SubToDo>
    @State var sub_title: String = ""
    let id: UUID
    
    init(id: UUID){
        _subToDos = FetchRequest(sortDescriptors: [
            NSSortDescriptor(keyPath: \SubToDo.subtodoIsDone, ascending: true),
            NSSortDescriptor(keyPath: \SubToDo.subtodoSortIndex, ascending: true)
        ], predicate: NSPredicate(format: "idOfMainToDo == %@", id as CVarArg), animation: .default)
        self.id = id
    }
    
    var body: some View{
        //SubToDos
        VStack{
            LeftText(text: "Erinnerungen", font: .headline)
            ForEach(subToDos, id: \.self){ subToDo in
                SubToDoListRow(subToDo: subToDo, sub_title: subToDo.subtodoTitle!)
            }
            HStack{
                Button(action: {
                    if sub_title != ""{
                        SubToDoFunctions().addSubToDo(subToDos: subToDos, title: sub_title, idOfMainToDo: id)
                        sub_title = ""
                    }
                }, label: {
                    SystemIcon(image: "plus.circle.fill", size: 20, isActivated: true)
                }).buttonStyle(.plain)
                TextField("Neue Erinnerung", text: $sub_title).textFieldStyle(.plain)
            }
        }
        .onDisappear{
            if sub_title != ""{
                SubToDoFunctions().addSubToDo(subToDos: subToDos, title: sub_title, idOfMainToDo: id)
            }
        }
    }
}
//SubToDoListTextField - Row to update the SubToDo
struct SubToDoListRow: View{
    @Environment(\.managedObjectContext) public var viewContext
    @ObservedObject var subToDo: SubToDo
    @State var sub_title: String = ""
    @State var overDeleteButton: Bool = false
    @State var overCheckmarkBox: Bool = false
    
    var body: some View{
        HStack{
            //Checkmark box
            Button(action: {
                subToDo.subtodoIsDone.toggle()
            }, label: {
                ZStack{
                    if(subToDo.subtodoIsDone){
                        Circle()
                            .fill(.white)
                            .frame(width: 15, height: 15)
                    }
                    Image(systemName: subToDo.subtodoIsDone ? "checkmark.circle.fill" : "circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundColor(overCheckmarkBox ? Colors.primaryColor : subToDo.subtodoIsDone ? Colors.primaryColor : .gray)
                        .opacity(overCheckmarkBox ? 1 : subToDo.subtodoIsDone ? 1 : 0.5)
                        .onHover{ over in
                            withAnimation{
                                overCheckmarkBox = over
                            }
                        }
                }
            }).buttonStyle(.plain)
            //TextField
            TextField("", text: $sub_title).textFieldStyle(.plain)
                .onDisappear{
                    if sub_title != ""{
                        SubToDoFunctions().updateSubToDo(subToDo: subToDo, title: sub_title)
                    } else {
                        SubToDoFunctions().deleteSubToDo(subToDo: subToDo)
                    }
                }
            Spacer()
            //Delete-Button
            Button(action: {
                SubToDoFunctions().deleteSubToDo(subToDo: subToDo)
            }, label: {
                SystemIcon(image: "trash.circle.fill", color: overDeleteButton ? Colors.primaryColor : .red, size: 20, isActivated: true)
            }).buttonStyle(.plain)
                .onHover{ over in
                    withAnimation{
                        overDeleteButton = over
                    }
                }
        }
    }
    
}

class SubToDoFunctions {
    let viewContext = PersistenceController.shared.container.viewContext
    func deleteSubToDo(subToDo: SubToDo){
        viewContext.delete(subToDo)
        saveContext(context: viewContext)
    }
    func updateSubToDo(subToDo: SubToDo, title: String){
        subToDo.subtodoTitle = title
        saveContext(context: viewContext)
    }
    func addSubToDo(subToDos: FetchedResults<SubToDo>, title: String, idOfMainToDo: UUID){
        let newSubToDo = SubToDo(context: viewContext)
        newSubToDo.subtodoTitle = title
        newSubToDo.subtodoID = UUID()
        newSubToDo.subtodoIsDone = false
        var itemsInSubToDos = subToDos.count
        itemsInSubToDos += 1
        newSubToDo.subtodoSortIndex = Int16(itemsInSubToDos)
        newSubToDo.idOfMainToDo = idOfMainToDo
        saveContext(context: viewContext)
    }
}


