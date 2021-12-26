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
    @State var showDoneToDos: Bool = true
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
                                        //IF dayValue.date is the same day as selected date -> Circle blue
                                        if(isSameDay(date1: lastSelectedDate, date2: dayValue.date)){
                                            Circle().fill(Color.blue)
                                        } else{
                                            //IF (there are todos at dayValue.date) AND (there are none todos which overpass the deadline) -> Circle primary color
                                            if(!isEmptyOnDate(date: dayValue.date) && !missedDeadlineOfToDo(date: dayValue.date)){
                                                Circle().fill(Colors.primaryColor)
                                            
                                            //IF (there are todos at dayValue.date) AND (there are some which overpass the deadline) -> Circle red
                                            } else if(!isEmptyOnDate(date: dayValue.date) && missedDeadlineOfToDo(date: dayValue.date)){
                                                Circle().fill(Color.red)
                                            //IF (On dayValue.date are just Done-To-Dos) AND (showDoneToDos is activated) -> Circle primary color shadowed
                                            } else if(isJustDoneToDos(date: dayValue.date) && showDoneToDos){
                                                Circle().fill(Colors.primaryColor).opacity(0.2)
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
                                                //IF (dayValue.date is current date) AND (dayValue.date is not selected date) AND (there are none to-dos at dayValue.date), display the text blue
                                                if(isCurrentDate(date: dayValue.date) && !isSameDay(date1: selectedDate, date2: dayValue.date) && isEmptyOnDate(date: dayValue.date)){
                                                    Text("\(dayValue.day)")
                                                        .foregroundColor(Color.blue)
                                                // ELSE IF (dayValue.date is selected date) AND (there are todos at dayValue.date), display the text white, because Circle is supported
                                                } else if(isSameDay(date1: lastSelectedDate, date2: dayValue.date) || !isEmptyOnDate(date: dayValue.date)){
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
                        selectedDate = Dates.currentDate
                        lastSelectedDate = Dates.currentDate
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
                    NavigationLink(destination: ListView(date: lastSelectedDate, bool: $showDoneToDos, selectedDate: $selectedDate, lastSelectedDate: $lastSelectedDate, type: listViewType), isActive: $listViewIsActive){ EmptyView() }
                }.hidden()
            }
            .frame(minWidth: 400)
        }
        .navigationTitle("Kalender")
        .toolbar{
            ToolbarItem{
                Button(showDoneToDos ? "Erledigte ausblenden" : "Erledigte einblenden"){
                    showDoneToDos.toggle()
                }
            }
        }
    }
}
