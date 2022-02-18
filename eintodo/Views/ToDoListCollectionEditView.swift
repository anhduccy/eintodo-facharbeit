//
//  ToDoListCollectionEditView.swift
//  eintodo
//
//  Created by anh :) on 29.12.21.
//

import SwiftUI

struct ToDoListCollectionEditView: View{
    @Environment(\.managedObjectContext) public var viewContext
    @Environment(\.colorScheme) public var colorScheme
    @EnvironmentObject var userSelected: UserSelected
    @FetchRequest(sortDescriptors: [], animation: .default) var todos: FetchedResults<ToDo>
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \ToDoList.listTitle, ascending: true)]) var lists: FetchedResults<ToDoList>

    let type: DetailViewTypes

    //Show DetailView
    @Binding var isPresented: Bool
    
    //Values for ToDoList
    @State var toDoList: ToDoList
    @State var title: String = "Liste"
    @State var description: String = ""
    @State var selectedColor: String = "indigo"
    @State var selectedSymbol: String = "list.bullet"
    
    //Constants
    let colors: [String] = ["pink", "red", "orange", "yellow", "green", "blue", "indigo", "purple", "brown", "gray"]
    let symbols: [String] = ["list.bullet", "bookmark.fill", "mappin", "gift.fill", "graduationcap.fill", "doc.fill", "book.fill", "banknote", "creditcard.fill", "figure.walk", "fork.knife", "house.fill", "tv.fill", "music.note", "pc", "gamecontroller.fill", "headphones", "beats.headphones", "leaf.fill", "person.fill", "person.2.fill", "person.3.fill", "pawprint.fill", "cart.fill", "bag.fill", "shippingbox.fill", "tram.fill", "airplane", "car.fill", "sun.max.fill", "moon.fill", "drop.fill", "snowflake", "flame.fill", "screwdriver.fill", "scissors", "curlybraces", "chevron.left.forwardslash.chevron.right", "lightbulb.fill", "bubble.left.fill", "staroflife.fill", "square.fill", "circle.fill", "triangle.fill", "heart.fill", "star.fill"]
    let buttonSize: CGFloat = 30
    let buttonSymbolSize: CGFloat = 15
    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 10)
        
    var body: some View{
        ZStack{
            VStack{
                TextField("Titel", text: $title)
                    .font(.title.bold())
                    .textFieldStyle(.plain)
                    .foregroundColor(getColorFromString(string: selectedColor))
                TextField("Beschreibung", text: $description)
                    .font(.body)
                    .textFieldStyle(.plain)
                    .foregroundColor(.gray)
                ZStack{
                    Circle().fill(getColorFromString(string: selectedColor)).frame(width: 50, height: 50)
                    Image(systemName: selectedSymbol)
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.white)
                        .frame(width: 25, height: 25, alignment: .center)
                }
                ScrollView{
                    //Colors
                    VStack(spacing: 0){
                        HStack{
                            Text("Farbe").font(.headline)
                            Spacer()
                        }
                        HStack{
                            ForEach(colors, id: \.self){ color in
                                Button(action: {
                                    withAnimation{
                                        selectedColor = color
                                    }
                                }, label: {
                                    if(selectedColor == color){
                                        Circle().fill(getColorFromString(string: color)).frame(width: 35, height: 35)
                                    } else {
                                        Circle().fill(getColorFromString(string: color))
                                            .frame(width: buttonSize, height: buttonSize, alignment: .center)
                                    }
                                }).buttonStyle(.plain)
                            }
                        }
                    }
                    //Symbols
                    VStack{
                        HStack{
                            Text("Symbole").font(.headline)
                            Spacer()
                        }
                        LazyVGrid(columns: columns){
                            ForEach(symbols, id: \.self){ symbol in
                                Button(action: {
                                    withAnimation{
                                        selectedSymbol = symbol
                                    }
                                }, label: {
                                    if(selectedSymbol == symbol){
                                        ZStack{
                                            Circle().foregroundColor(getColorFromString(string: selectedColor))
                                                .frame(width: buttonSize, height: buttonSize, alignment: .center)
                                            Image(systemName: symbol)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: buttonSymbolSize, height: buttonSymbolSize, alignment: .center)
                                                .foregroundColor(.white)
                                        }
                                    } else {
                                        ZStack{
                                            Circle().foregroundColor(.gray)
                                                .frame(width: buttonSize, height: buttonSize, alignment: .center)
                                            Image(systemName: symbol)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: buttonSymbolSize, height: buttonSymbolSize, alignment: .center)
                                                .foregroundColor(.white)
                                        }
                                    }
                                }).buttonStyle(.plain)
                            }
                        }
                    }
                }
                Spacer()
                SubmitButtonsWithCondition(condition: title != "", isPresented: $isPresented, updateAction: {
                    switch(type){
                    case .edit: updateToDoList(editViewType: .edit, todoList: toDoList)
                    case .add: updateToDoList(editViewType: .add)
                    }
                }, deleteAction: deleteToDoList, cancelAction: {}, type: type)
            }
            .padding()
        }
        .frame(width: Sizes.defaultSheetWidth, height: Sizes.defaultSheetHeight)
        .onAppear{
            switch(type){
            case .edit:
                title = toDoList.listTitle!
                description = toDoList.listDescription!
                selectedColor = toDoList.listColor!
                selectedSymbol = toDoList.listSymbol!
            case .add:
                break
            }
        }
    }
}

extension ToDoListCollectionEditView{
    private func updateToDoList(editViewType: DetailViewTypes, todoList: ToDoList = ToDoList()){
        var objToDoList = ToDoList(context: viewContext)
        switch(editViewType){
        case .add:
            objToDoList.listID = UUID()
        case .edit:
            objToDoList = todoList
            todos.nsPredicate = NSPredicate(format: "todoList == %@", toDoList.listTitle! as CVarArg)
            for todo in todos{
                todo.todoList = title
            }
            userSelected.selectedView = 1
        }
        objToDoList.listTitle = title
        objToDoList.listDescription = description
        objToDoList.listColor = selectedColor
        objToDoList.listSymbol = selectedSymbol
        
        userSelected.selectedToDoList = title
        userSelected.selectedToDoListID = objToDoList.listID!
        saveContext(context: viewContext)
    }
    private func deleteToDoList(){
        viewContext.delete(toDoList)
        saveContext(context: viewContext)
    }
}

