//
//  CalendarView.swift
//  eintodo
//
//  Created by anh :) on 12.12.21.
//

import SwiftUI

struct CalendarView: View {
    @Environment(\.managedObjectContext) public var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \ToDo.title, ascending: true)], animation: .default)
    public var todos: FetchedResults<ToDo>
    
    @State var currentMonth: Int = 0
    @State var selectedDate: Date = Date()
    @State var isSelected: Bool = true
    @State var showDoneToDos: Bool = false
    @State var listViewIsActive: Bool = false
    
    let day: Int = 3600*24
    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 7)
    let weekdays: [String] = ["Mo", "Di", "Mi", "Do", "Fr", "Sa", "So"]
    
    var body: some View {
        NavigationView{
            VStack{
                VStack{
                    HStack{
                        Spacer()
                        Button("<"){
                            currentMonth -= 1
                        }
                        
                        Button(">"){
                            currentMonth += 1
                        }
                    }
                    HStack{
                        Text(getYear())
                        Spacer()
                    }
                    HStack{
                        Text(getMonth())
                            .font(.title2.bold())
                        Spacer()
                    }
                    
                    LazyVGrid(columns: columns){
                        ForEach(weekdays, id: \.self){ weekday in
                            Text(weekday)
                        }
                        
                        ForEach(extractDate(), id: \.self){ dayValue in
                            if(dayValue.day >= 0){
                                Button(action: {
                                    selectedDate = dayValue.date
                                    self.listViewIsActive = true
                                    self.isSelected = true
                                }){
                                    ZStack{
                                        if(!isEmptyOnDate(date: dayValue.date)){
                                            Circle()
                                                .foregroundColor(dayValue.date == selectedDate ? .blue : .indigo)
                                            Text("\(dayValue.day)")
                                                .frame(width: 30, height: 30, alignment: .center)
                                        } else if dayValue.date == selectedDate{
                                                Circle()
                                                .foregroundColor(.blue)
                                                Text("\(dayValue.day)")
                                                    .frame(width: 30, height: 30, alignment: .center)
                                        } else {
                                            Text("\(dayValue.day)")
                                                .frame(width: 30, height: 30, alignment: .center)
                                        }
                                    }
                                }
                                .buttonStyle(.plain)
                            } else {
                                Text("")
                            }
                        }
                    }
                    .onAppear{
                        selectedDate = Date()
                        self.listViewIsActive = true
                    }
                    .onChange(of: currentMonth) { newValue in
                        selectedDate = getCurrentMonth()
                    }
                }.padding()
                
                VStack {
                    NavigationLink(destination: ListView(selectedDate: selectedDate, bool: $showDoneToDos), isActive: $listViewIsActive){ EmptyView() }
                }.hidden()
            }
            .frame(minWidth: 400)
        }
        .navigationTitle("Kalender")
        .toolbar{
            ToolbarItem{
                Button("Alles löschen"){
                    deleteAllItems()
                }
            }
            ToolbarItem{
                Button(showDoneToDos ? "Erledigte ausblenden" : "Erledigte einblenden"){
                    showDoneToDos.toggle()
                }
            }
        }
    }
}

extension Date {
    func getAllDates() -> [Date] {
        let calendar = Calendar.current
        // geting start date
        let startDate = calendar.date(from: Calendar.current.dateComponents([.year, .month], from: self))!
        let range = calendar.range(of: .day, in: .month, for: startDate)
        // getting date...
        return range!.compactMap{ day -> Date in
            return calendar.date(byAdding: .day, value: day - 1 , to: startDate)!
        }
    }
}
