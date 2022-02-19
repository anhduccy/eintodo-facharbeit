//
//  SubviewsOfEditView.swift
//  eintodo
//
//  Created by anh :) on 31.01.22.
//

import SwiftUI

//Popover to select priority
struct SelectPriorityPopover: View{
    @Binding var priority: Int
    var body: some View{
        VStack{
            LeftText(text: "Priorität", font: .title2, fontWeight: .bold)
            Picker("", selection: $priority){
                Text("Hoch").tag(3)
                Text("Mittel").tag(2)
                Text("Niedrig").tag(1)
                Text("Keine").tag(0)
            }
            .pickerStyle(.inline)
        }
        .padding()
    }
}
//ListPicker to select lists
struct ToDoEditViewListPicker: View{
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \ToDoList.listTitle, ascending: true)]) var lists: FetchedResults<ToDoList>
    @Binding var listsValueString: String
    @Binding var listsValueID: UUID
    @State private var listType: Int = 0
    var body: some View {
       let binding = Binding<Int>(
           get: { self.listType },
           set: {
               self.listType = $0
               self.listsValueID = self.lists[self.listType].listID!
               self.listsValueString = self.lists[self.listType].listTitle!
           })
       return Picker(selection: binding, label: Text("")) {
           ForEach(lists.indices) { list in
               Text(lists[list].listTitle!).tag(list)
           }
       }
       .pickerStyle(.menu)
       .onAppear{ //Check in which list, ToDo was before
            var counter = 0
            for list in lists{
                if(list.listID == listsValueID){
                    listType = counter
                }
                counter += 1
            }
        }
    }
}
