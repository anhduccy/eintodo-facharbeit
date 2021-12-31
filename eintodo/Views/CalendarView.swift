//
//  CalendarView.swift
//  eintodo
//
//  Created by anh :) on 12.12.21.
//

import SwiftUI

struct DateNavigatorPopover: View{
    @EnvironmentObject private var userSelected: UserSelected
    @Binding var currentMonth: Int
    @Binding var navigateDate: Date
    var body: some View{
        VStack{
            HStack{
                Text("Navigiere zu").font(.title2.bold())
                Spacer()
            }
            DatePicker("", selection: $navigateDate, displayedComponents: [.date])
                .datePickerStyle(.field)
                .onChange(of: navigateDate){ newValue in
                    userSelected.lastSelectedDate = navigateDate
                    userSelected.selectedDate = navigateDate
                    currentMonth = getMonthInterval(from: userSelected.selectedDate)
                }
        }
        .padding()
    }
}

struct SelectFilterPopover: View{
    @Binding var filter: FilterToDoType
    var body: some View{
        VStack{
            HStack{
                Text("Filter").font(.title2.bold())
                Spacer()
            }
            HStack{
                Picker("", selection: $filter){
                    Text("Fällig am ").tag(FilterToDoType.deadline)
                    Text("Erinnerung").tag(FilterToDoType.notification)
                    Text("Markiert").tag(FilterToDoType.isMarked)
                }
                .pickerStyle(.inline)
                Spacer()
            }
        }
        .padding()
    }
}

struct CalendarView: View {
    @Environment(\.managedObjectContext) public var viewContext
    @EnvironmentObject public var userSelected: UserSelected
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \ToDo.title, ascending: true)], animation: .default)
    public var todos: FetchedResults<ToDo>
    
    //ListView attributes
    @State var listViewIsActive: Bool = true
    @State var listViewType: ListViewTypes = .dates
    
    //Date attributes
    @State var currentMonth: Int = 0
    @State var navigateDate: Date = Date()
    
    @Binding var showDoneToDos: Bool
    @State var showFilterPopover = false
    @State var filter: FilterToDoType
    @State var showDateNavigatorPopover = false

    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 7)
    let day: Int = 3600*24 //Day in Seconds
    let weekdays: [String] = ["Mo", "Di", "Mi", "Do", "Fr", "Sa", "So"]
    
    var body: some View {
        NavigationView{
            ZStack{
                VStack{
                    //Display of current month and year & navigation buttons
                    HStack{
                        Text(getYear())
                            .font(.title2)
                        Text(getMonth())
                            .font(.title2.bold())
                        Spacer()
                        HStack{
                            Button(action: {
                                currentMonth -= 1
                                userSelected.selectedDate = getCurrentMonth(date: userSelected.selectedDate)
                                userSelected.lastSelectedDate = getCurrentMonth(date: userSelected.lastSelectedDate)
                            }){
                                CalendarViewMonthButton(name: "chevron.backward", color: Colors.primaryColor)
                            }
                            .buttonStyle(.plain)
                            Button(action: {
                                currentMonth += 1
                                userSelected.lastSelectedDate = getCurrentMonth(date: userSelected.lastSelectedDate)
                                userSelected.selectedDate = getCurrentMonth(date: userSelected.selectedDate)
                            }){
                                CalendarViewMonthButton(name: "chevron.forward", color: Colors.primaryColor)
                            }
                            .buttonStyle(.plain)

                        }
                        Button(action: {
                            showDateNavigatorPopover.toggle()
                        }, label: {
                            ZStack{
                                Circle().fill().foregroundColor(Colors.primaryColor).opacity(0.2)
                                    .frame(width: 24, height: 24, alignment: .center)
                                Image(systemName: "cursorarrow.rays")
                                    .foregroundColor(Colors.primaryColor)
                            }
                        })
                            .buttonStyle(.plain)
                            .popover(isPresented: $showDateNavigatorPopover){
                                DateNavigatorPopover(currentMonth: $currentMonth, navigateDate: $navigateDate)
                            }
                        Button(action: {
                            showFilterPopover.toggle()
                        }, label: {
                            ZStack{
                                Circle().fill().foregroundColor(Colors.primaryColor).opacity(0.2)
                                    .frame(width: 24, height: 24, alignment: .center)
                                Image(systemName: showFilterPopover ? "line.3.horizontal.decrease.circle.fill" :  "line.3.horizontal.decrease.circle")
                                    .resizable()
                                    .frame(width: 15, height: 15, alignment: .center)
                                    .foregroundColor(Colors.primaryColor)
                            }
                        })
                            .buttonStyle(.plain)
                            .popover(isPresented: $showFilterPopover){
                                SelectFilterPopover(filter: $filter)
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
                                        if(isSameDay(date1: userSelected.lastSelectedDate, date2: dayValue.date)){
                                            Circle().fill(Color.blue)
                                        } else {
                                            switch(filter){
                                            case .deadline, .notification:
                                                    //IF (there are todos at dayValue.date) AND (there are none todos which overpass the deadline) -> Circle primary color
                                                    if(!isEmptyOnDate(date: dayValue.date) && !isDateInPast(date: dayValue.date)){
                                                        Circle().fill(Colors.primaryColor)
                                                    
                                                    //IF (there are todos at dayValue.date) AND (there are some which overpass the deadline) -> Circle red
                                                    } else if(!isEmptyOnDate(date: dayValue.date) && isDateInPast(date: dayValue.date)){
                                                        Circle().fill(Color.red)
                                                        
                                                    //IF (On dayValue.date are just Done-To-Dos) AND (showDoneToDos is activated) -> Circle primary color shadowed
                                                    } else if(isJustDoneToDos(date: dayValue.date) && showDoneToDos){
                                                        Circle().fill(Colors.primaryColor).opacity(0.2)
                                                    }
                                            case .isMarked:
                                                if(!isEmptyOnDate(date: dayValue.date)){
                                                    Circle().fill(Color.yellow)
                                                } else if(isJustDoneToDos(date: dayValue.date)){
                                                    Circle().fill(Color.yellow).opacity(0.2)
                                                }
                                            }
                                        }
                                        Button(action: {
                                            userSelected.selectedDate = dayValue.date
                                            userSelected.lastSelectedDate = userSelected.selectedDate
                                            self.listViewType = .dates
                                        }){
                                            ZStack{
                                                //IF (dayValue.date is current date) AND (dayValue.date is not selected date) AND (there are none to-dos at dayValue.date), display the text blue
                                                if(isToday(date: dayValue.date) && !isSameDay(date1: userSelected.selectedDate, date2: dayValue.date) && isEmptyOnDate(date: dayValue.date)){
                                                    Text("\(dayValue.day)")
                                                        .foregroundColor(Color.blue)
                                                } else {
                                                    switch(filter){
                                                    case .deadline, .notification:
                                                        // ELSE IF (dayValue.date is selected date) AND (there are todos at dayValue.date), display the text white, because Circle is supported
                                                        if(isSameDay(date1: userSelected.lastSelectedDate, date2: dayValue.date) || !isEmptyOnDate(date: dayValue.date)){
                                                            Text("\(dayValue.day)")
                                                                .foregroundColor(Color.white)
                                                        } else {
                                                            Text("\(dayValue.day)")
                                                        }
                                                    case .isMarked:
                                                        if(isSameDay(date1: userSelected.lastSelectedDate, date2: dayValue.date)){
                                                            Text("\(dayValue.day)")
                                                            .foregroundColor(Color.white)
                                                        } else if(!isEmptyOnDate(date: dayValue.date)){
                                                            Text("\(dayValue.day)")
                                                            .foregroundColor(Color.black)
                                                        } else {
                                                            Text("\(dayValue.day)")
                                                        }
                                                    }
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
                            .onChange(of: filter){ newValue in
                                predicateList(date: dayValue.date)
                            }
                        }
                    }
                    .onAppear{
                        userSelected.selectedDate = Date()
                        userSelected.lastSelectedDate = Date()
                    }
                    .onChange(of: userSelected.lastSelectedDate){ newValue in
                        navigateDate = userSelected.lastSelectedDate
                    }
                    Spacer()
                    HStack{
                        Button("Erinnerungen ohne Datum"){
                            userSelected.selectedDate = Dates.defaultDate
                            self.listViewType = .noDates
                        }
                        .foregroundColor(Colors.primaryColor)
                        .buttonStyle(.plain)
                        Spacer()
                        Button("Heute"){
                            navigateDate = Date()
                            userSelected.lastSelectedDate = Date()
                            userSelected.selectedDate = userSelected.lastSelectedDate
                            currentMonth = 0
                        }
                            .buttonStyle(.plain)
                            .foregroundColor(Colors.primaryColor)
                    }
                }.padding()
                //Hidden navigation link to navigate between dates
                VStack {
                    NavigationLink(destination: ListView(type: listViewType, showDoneToDos: $showDoneToDos, userSelected: userSelected), isActive: $listViewIsActive){ EmptyView() }
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

//EXTENSIONS
struct DateValue: Hashable{
    let id = UUID().uuidString
    var day: Int
    var date: Date
}
extension CalendarView{
    //Display the selected year
    func getYear() -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY"
        let year = formatter.string(from: userSelected.lastSelectedDate)
        return year
    }
    
    //Display the selected month
    func getMonth() -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        let month = formatter.string(from: userSelected.lastSelectedDate)
        return month
    }
    
    //Get the selected month
    func getCurrentMonth(date: Date = Date()) -> Date {
        let calendar = Calendar.current
        var resultDate = Date()
        
        let inputDay = calendar.dateComponents([.day], from: date).day
        let currentMonth = calendar.dateComponents([.month], from: Date()).month
        let currentYear = calendar.dateComponents([.year], from: Date()).year
        
        let dateComponents = DateComponents(calendar: .current, timeZone: calendar.timeZone, year: currentYear, month: currentMonth, day: inputDay)
        if dateComponents.isValidDate{
            resultDate = dateComponents.date!
        }
            
        // Getting Current month date
        guard let currentMonth = calendar.date(byAdding: .month, value: self.currentMonth, to: resultDate) else {
            return Date()
        }
        return currentMonth
    }
    
    //Extract date for selected month from getAllDates()
    func extractDate() -> [DateValue] {
        let calendar = Calendar.current
        
        // Getting Current month date
        let currentMonth = getCurrentMonth()
        var days = currentMonth.getAllDates().compactMap { date -> DateValue in
            let day = calendar.component(.day, from: date)
            let dateValue =  DateValue(day: day, date: date)
            return dateValue
        }
        
        // adding offset days to get exact week day...
        let firstWeekday = calendar.component(.weekday, from: days.first?.date ?? Date())
            for _ in 0..<firstWeekday + 5 {
                days.insert(DateValue(day: -1, date: Date()), at: 0)
            }
            return days
        }
    
    func returnFormatOfFilter()->String{
        var format = ""
        switch(filter){
        case.deadline:
            format = "deadline <= %@ && deadline >= %@"
        case.notification:
            format = "notification <= %@ && notification >= %@"
        case.isMarked:
            format = "((deadline <= %@ && deadline >= %@) || (notification <= %@ && notification >= %@)) && isMarked == true"
        }
        return format
    }
    
    //If storage is empty on date at input date, return true
    func isEmptyOnDate(date: Date)->Bool{
        let calendar = Calendar.current
        let dateFrom = calendar.startOfDay(for: date)
        let dateTo = calendar.date(byAdding: .minute, value: 1439, to: dateFrom)
        let format = returnFormatOfFilter()
        
        let predicate = NSPredicate(format: format + " && isDone == false", dateTo! as CVarArg, dateFrom as CVarArg, dateTo! as CVarArg, dateFrom as CVarArg)
        todos.nsPredicate = predicate
        if todos.isEmpty{
            return true
        } else {
            return false
        }
    }
    
    //If storage just has done to-dos at input date, return true
    func isJustDoneToDos(date: Date)->Bool{
        let calendar = Calendar.current
        let dateFrom = calendar.startOfDay(for: date)
        let dateTo = calendar.date(byAdding: .minute, value: 1439, to: dateFrom)
        let format = returnFormatOfFilter()
        
        var predicate = NSPredicate(format: format + " && isDone == false", dateTo! as CVarArg, dateFrom as CVarArg, dateTo! as CVarArg, dateFrom as CVarArg)
        todos.nsPredicate = predicate
        if todos.isEmpty {
            predicate = NSPredicate(format: format, dateTo! as CVarArg, dateFrom as CVarArg, dateTo! as CVarArg, dateFrom as CVarArg)
            todos.nsPredicate = predicate
            if todos.isEmpty {
                return false
            } else {
                return true
            }
        } else {
            return false
        }
    }
    
    func predicateList(date: Date){
        let dateFrom = Calendar.current.startOfDay(for: date)
        let dateTo = Calendar.current.date(byAdding: .minute, value: 1439, to: dateFrom)
        
        switch(filter){
        case .deadline:
            let predicate = NSPredicate(format: returnFormatOfFilter(), dateTo! as CVarArg, dateFrom as CVarArg)
            todos.nsPredicate = predicate
        case .notification:
            let predicate = NSPredicate(format: returnFormatOfFilter(), dateTo! as CVarArg, dateFrom as CVarArg)
            todos.nsPredicate = predicate
        case .isMarked:
            let predicate = NSPredicate(format: returnFormatOfFilter(), dateTo! as CVarArg, dateFrom as CVarArg, dateTo! as CVarArg, dateFrom as CVarArg)
            todos.nsPredicate = predicate
        }
    }
}

