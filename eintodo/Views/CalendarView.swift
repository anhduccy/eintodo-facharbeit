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
    
    //ListView attributes
    @State var listViewIsActive: Bool = true
    @State var listViewType: ListViewTypes = .dates
    
    //Calendar attributes
    @State var currentMonth: Int = 0
    @State var showDoneToDos: Bool = false
    @Binding var selectedDate: Date
    @Binding var lastSelectedDate: Date

    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 7)
    let day: Int = 3600*24 //Day in Seconds
    let weekdays: [String] = ["Mo", "Di", "Mi", "Do", "Fr", "Sa", "So"]
    
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
                                            if(isSameDay(date1: Dates.currentDate, date2: dayValue.date)){
                                                Circle().hidden()
                                            } else if(!isEmptyOnDate(date: dayValue.date) && !missedDeadlineOfToDo(date: dayValue.date)){
                                                Circle().fill(Colors.primaryColor)
                                            } else if(!isEmptyOnDate(date: dayValue.date) && missedDeadlineOfToDo(date: dayValue.date)){
                                                Circle().fill(Color.red)
                                            } else if(isJustDoneToDos(date: dayValue.date) && showDoneToDos){
                                                Circle().fill(Color.indigo).opacity(0.2)
                                            }
                                        }
                                        Button(action: {
                                            selectedDate = dayValue.date
                                            lastSelectedDate = selectedDate
                                            self.listViewType = .dates
                                        }){
                                            ZStack{
                                                Circle()
                                                    .hidden()
                                                if(isSameDay(date1: Dates.currentDate, date2: dayValue.date) && !isSameDay(date1: selectedDate, date2: dayValue.date)){
                                                    Text("\(dayValue.day)")
                                                        .foregroundColor(Color.blue)
                                                } else if(isSameDay(date1: selectedDate, date2: dayValue.date) || !isEmptyOnDate(date: dayValue.date)){
                                                    Text("\(dayValue.day)")
                                                        .foregroundColor(Color.white)
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
                    }
                    .onChange(of: currentMonth) { newValue in
                        selectedDate = getCurrentMonth()
                        lastSelectedDate = getCurrentMonth()
                    }
                    
                    Button("Erinnerungen ohne Datum"){
                        selectedDate = Dates.defaultDate
                        self.listViewType = .noDates
                    }
                    .padding()
                    .foregroundColor(.blue)
                    .buttonStyle(.plain)
                    Spacer()
                }.padding()
                
                //Hidden navigation link to navigate between dates
                VStack {
                    NavigationLink(destination: ListView(date: selectedDate, bool: $showDoneToDos, selectedDate: $selectedDate, lastSelectedDate: $lastSelectedDate, type: listViewType), isActive: $listViewIsActive){ EmptyView() }
                }.hidden()
            }
            .frame(minWidth: 400)
        }
        .navigationTitle(isSameDay(date1: selectedDate, date2: Dates.defaultDate) ? "Erinnerungen" : DateToStringFormatter(date: selectedDate))
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
