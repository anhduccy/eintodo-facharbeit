//
//  ToDoListsDetailView.swift
//  eintodo
//
//  Created by anh :) on 29.12.21.
//

import SwiftUI

struct ToDoListDetailView: View{
    @Environment(\.managedObjectContext) public var viewContext
    @Environment(\.colorScheme) public var colorScheme

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
    let colors: [String] = ["pink", "red", "yellow", "green", "blue", "indigo", "purple", "brown", "gray"]
    let symbols: [String] = ["list.bullet", "bookmark.fill", "mappin"]
    let buttonSize: CGFloat = 30
    let buttonSymbolSize: CGFloat = 15
        
    var body: some View{
        ZStack{
            VStack{
                TextField("Titel", text: $title)
                    .font(.title.bold())
                    .textFieldStyle(.plain)
                    .foregroundColor(getColorFromString(string: selectedColor))
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
                            Text("Farbe").font(.headline.bold())
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
                            Text("Symbole").font(.headline.bold())
                            Spacer()
                        }
                        HStack{
                            ForEach(symbols, id: \.self){ symbol in
                                Button(action: {
                                    withAnimation{
                                        selectedSymbol = symbol
                                    }
                                }, label: {
                                    if(selectedSymbol == symbol){
                                        ZStack{
                                            Circle().foregroundColor(Colors.primaryColor)
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
                            IconImage(image: "trash.circle.fill", color: overDeleteButton ? Colors.primaryColor : .red, size: 25, isActivated: true)
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
                selectedColor = toDoList.color!
                selectedSymbol = toDoList.symbol!
            case .add:
                break
            }
            
        }
    }
}

extension ToDoListDetailView{
    public func addToDoList(){
        let newToDoList = ToDoList(context: viewContext)
        newToDoList.listID = UUID()
        newToDoList.listTitle = title
        newToDoList.listDescription = description
        newToDoList.color = selectedColor
        newToDoList.symbol = selectedSymbol
        do{
            try viewContext.save()
        }catch{
            let nsError = error as NSError
            fatalError("Could not add CoreData-Entity in ToDoListDetailView: \(nsError), \(nsError.userInfo)")
        }
    }
    public func updateToDoList(){
        toDoList.listTitle = title
        toDoList.listDescription = description
        toDoList.color = selectedColor
        toDoList.symbol = selectedSymbol
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
