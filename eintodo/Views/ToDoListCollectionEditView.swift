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
    
    //Animation
    @State var overDeleteButton = false
    
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
                
                HStack{
                    Button("Abbrechen"){
                        isPresented.toggle()
                    }
                    .foregroundColor(Colors.secondaryColor)
                    .buttonStyle(.plain)
                    switch(type){
                    case .display:
                        Spacer()
                        Button(action: {
                            deleteToDoList()
                            isPresented.toggle()
                        }, label: {
                            SystemIcon(image: "trash.circle.fill", color: overDeleteButton ? Colors.primaryColor : .red, size: 25, isActivated: true)
                        })
                            .buttonStyle(.plain)
                            .onHover{ over in
                                withAnimation{
                                    overDeleteButton = over
                                }
                            }
                        Spacer()
                    case .add:
                        Spacer()
                    }
                    if(title != ""){
                        Button(action: {
                            switch(type){
                            case .display:
                                updateToDoList()
                            case .add:
                                addToDoList()
                            }
                            isPresented.toggle()
                        }, label: {
                            Text("Fertig")
                                .font(.body)
                                .fontWeight(.semibold)
                                .foregroundColor(colorScheme == .dark ? Colors.secondaryColor : Colors.primaryColor)
                        })
                        .buttonStyle(.plain)
                    } else {
                        Button(action: {
                            isPresented.toggle()
                        }, label: {
                            Text("Fertig")
                                .font(.body)
                                .fontWeight(.semibold)
                                .foregroundColor(.gray)
                        })
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding()
        }
        .frame(width: Sizes.defaultSheetWidth, height: Sizes.defaultSheetHeight)
        .onAppear{
            switch(type){
            case .display:
                title = toDoList.listTitle!
                description = toDoList.listDescription!
                selectedColor = toDoList.listColor!
                selectedSymbol = toDoList.listSymbol!
            case .add:
                break
            }
            
        }
    }
    public func addToDoList(){
        //Initialize the ToDoList
        let newToDoList = ToDoList(context: viewContext)
        newToDoList.listID = UUID()
        newToDoList.listTitle = title
        newToDoList.listDescription = description
        newToDoList.listColor = selectedColor
        newToDoList.listSymbol = selectedSymbol
        //Set selected to do list to the edited one
        userSelected.selectedToDoList = title
        userSelected.selectedToDoListID = newToDoList.listID!
        userSelected.selectedView = 1

        do{
            try viewContext.save()
        }catch{
            let nsError = error as NSError
            fatalError("Could not add CoreData-Entity in ToDoListDetailView: \(nsError), \(nsError.userInfo)")
        }
    }
    public func updateToDoList(){
        todos.nsPredicate = NSPredicate(format: "todoList == %@", toDoList.listTitle! as CVarArg)
        //Update ToDoList
        toDoList.listTitle = title
        toDoList.listDescription = description
        toDoList.listColor = selectedColor
        toDoList.listSymbol = selectedSymbol
        //Update the titles of all todos in the list
        for todo in todos{
            todo.todoList = title
        }
        //Set selected to do list to the edited one
        userSelected.selectedToDoList = title
        userSelected.selectedToDoListID = toDoList.listID!
        do{
            try viewContext.save()
        }catch{
            let nsError = error as NSError
            fatalError("Could not update CoreData-Entity in ToDoListDetailView: \(nsError), \(nsError.userInfo)")
        }
    }
    public func deleteToDoList(){
        viewContext.delete(toDoList)
        do{
            try viewContext.save()
        }catch{
            let nsError = error as NSError
            fatalError("Could not delete CoreData-Entity in ToDoListDetailView: \(nsError), \(nsError.userInfo)")
        }
    }
}

