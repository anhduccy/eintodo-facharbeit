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
    @State var showDoneToDos: Bool = false
    @State var listViewIsActive: Bool = false
    
    @Binding var selectedDate: Date
    
    let day: Int = 3600*24
    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 7)
    let weekdays: [String] = ["Mo", "Di", "Mi", "Do", "Fr", "Sa", "So"]
    let currentDate: Date = Date()
    
    var body: some View {
        NavigationView{
            ZStack{
                VStack{
                    //Display of current month and year & navigation buttons
                    HStack{
                        VStack{
                            HStack{
                                Text(getYear())
                                Spacer()
                            }
                            HStack{
                                Text(getMonth())
                                    .font(.title2.bold())
                                Spacer()
                            }
                        }
                        HStack{
                            Spacer()
                            Button(action: {
                                currentMonth -= 1
                            }){
                                CalendarViewMonthButton(name: "chevron.backward", color: Colors.primaryColor)
                            }
                            .buttonStyle(.plain)
                            Button(action: {
                                currentMonth += 1
                            }){
                                CalendarViewMonthButton(name: "chevron.forward", color: Colors.primaryColor)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    
                    //Calendar
                    LazyVGrid(columns: columns){
                        ForEach(weekdays, id: \.self){ weekday in
                            Text(weekday)
                        }
                        
                        ForEach(extractDate(), id: \.self){ dayValue in
                            VStack{
                                if(dayValue.day >= 0){
                                    ZStack{
                                        if(isSameDay(date1: selectedDate, date2: dayValue.date)){
                                            Circle().fill(Color.blue)
                                        } else{
                                            if(isSameDay(date1: currentDate, date2: dayValue.date)){
                                                Circle().hidden()
                                            } else if(!isEmptyOnDate(date: dayValue.date) && !missedDeadlineOfToDo(date: dayValue.date)){
                                                Circle().fill(Colors.primaryColor)
                                            } else if(!isEmptyOnDate(date: dayValue.date) && missedDeadlineOfToDo(date: dayValue.date)){
                                                Circle().fill(Color.red)
                                            }
                                        }
                                        Button(action: {
                                            selectedDate = dayValue.date
                                            self.listViewIsActive = true
                                        }){
                                            ZStack{
                                                Circle()
                                                    .hidden()
                                                if(isSameDay(date1: currentDate, date2: dayValue.date) && !isSameDay(date1: selectedDate, date2: dayValue.date)){
                                                    Text("\(dayValue.day)")
                                                        .foregroundColor(Color.blue)
                                                } else {
                                                    Text("\(dayValue.day)")
                                                }
                                            }
                                            .frame(width: 30, height: 30, alignment: .center)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                } else {
                                    Text("")
                                }
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
                    Spacer()
                }.padding()
                
                //Hidden navigation link to navigate between dates
                VStack {
                    NavigationLink(destination: ListView(date: selectedDate, bool: $showDoneToDos, selectedDate: $selectedDate), isActive: $listViewIsActive){ EmptyView() }
                }.hidden()
            }
            .frame(minWidth: 400)
        }
        .navigationTitle(DateToStringFormatter(date: selectedDate))
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
