//
//  CalendarView.swift
//  eintodo
//
//  Created by anh :) on 12.12.21.
//

import SwiftUI

/**
 Kalenderansicht
 */
struct CalendarView: View {
    @Environment(\.managedObjectContext) public var viewContext
    //Darkmode oder Lightmode?
    @Environment(\.colorScheme) public var appearance
    @EnvironmentObject private var userSelected: UserSelected
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \ToDo.todoTitle, ascending: true)], animation: .default)
    public var todos: FetchedResults<ToDo>
    
    //Attribute für ToDoListView
    @State var listViewIsActive: Bool = true //Zeige ToDoListView (Listenansicht)
    @State var toDoListFilterType: ToDoListFilterType = .dates //Filtertyp der Listenansicht (hier nach Datum)
    
    //Datumeinstellungen
    @State var currentMonth: Int = 0 //Aktueller Monat
    @State var navigateDate: Date = Date() //Datum bei Eingabe von "Navigiere zu"
    
    @State var showFilterPopover = false //Zeige Filtereinstellungen
    @State var filter: CalendarViewFilterToDoType //Filtertyp der Kalenderansicht
    @State var showDateNavigatorPopover = false //Zeige "Navigiere zu"

    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 7)
    let day: Int = 3600*24 //Day in Seconds
    let weekdays: [String] = ["Mo", "Di", "Mi", "Do", "Fr", "Sa", "So"]
    
    var body: some View {
        NavigationView{
            ZStack{
                VStack{
                    //Aktueller Monat & Jahr mit Navigation-Button
                    HStack{
                        Text(getYear())
                            .font(.title2)
                            .fontWeight(.light)
                        Text(getMonth())
                            .font(.title2.bold())
                        Spacer()
                        HStack{
                            Button(action: {
                                currentMonth -= 1
                                userSelected.selectedDate = getCurrentMonth(date: userSelected.selectedDate)
                                userSelected.lastSelectedDate = getCurrentMonth(date: userSelected.lastSelectedDate)
                            }){
                                MonthNavigatorButton(name: "chevron.backward", color: Colors.primaryColor)
                            }
                            .buttonStyle(.plain)
                            Button(action: {
                                currentMonth += 1
                                userSelected.lastSelectedDate = getCurrentMonth(date: userSelected.lastSelectedDate)
                                userSelected.selectedDate = getCurrentMonth(date: userSelected.selectedDate)
                            }){
                                MonthNavigatorButton(name: "chevron.forward", color: Colors.primaryColor)
                            }
                            .buttonStyle(.plain)

                        }
                        //"Navigiere zu"
                        Button(action: {
                            showDateNavigatorPopover.toggle()
                        }, label: {
                            ZStack{
                                Circle().fill().foregroundColor(Colors.primaryColor).opacity(0.2)
                                    .frame(width: 24, height: 24, alignment: .center)
                                Image(systemName: "arrow.turn.up.right")
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
                    
                    //Kalender
                    LazyVGrid(columns: columns){
                        //Reihe: Wochentage
                        ForEach(weekdays, id: \.self){ weekday in
                            Text(weekday).bold()
                        }
                        
                        //Wochentage 1-31, 1-30, 1-28
                        ForEach(extractDate(), id: \.self){ dayValue in
                            if(dayValue.day >= 0){
                                Button(action: {
                                    userSelected.selectedDate = dayValue.date
                                    userSelected.lastSelectedDate = userSelected.selectedDate
                                    self.toDoListFilterType = .dates
                                }, label: {
                                    VStack{
                                        //Wenn Datum ist ausgewählt -> blauer Hintergrund
                                        if(isSameDay(date1: userSelected.lastSelectedDate, date2: dayValue.date)){
                                            ZStack{
                                                Circle().fill(Colors.primaryColor)
                                                    .opacity(0.2)
                                                Text("\(dayValue.day)")
                                                    .foregroundColor(Colors.primaryColor)
                                            }
                                        } else {
                                            //Nach Filter anderer Style
                                            switch(filter){
                                            case .deadline, .notification: //Bei "Fällig am" oder "Erinnerung"
                                                //Wenn To-Do vorhanden ist und nicht in der Vergangenheit liegend -> Blaue Schrift
                                                if(!isEmptyOnDate(date: dayValue.date) && !isDateInPast(date: dayValue.date)){
                                                    Text("\(dayValue.day)").foregroundColor(Colors.primaryColor).fontWeight(.light)
                                                
                                                //Wenn To-Do vorhanden ist und in der Vergangenheit liegt -> Rote Schrift
                                                } else if(!isEmptyOnDate(date: dayValue.date) && isDateInPast(date: dayValue.date)){
                                                    Text("\(dayValue.day)").foregroundColor(.red).fontWeight(.light)
                                                    
                                                //Wenn To-Do erledigt wurde und Erledigte anzeigen aktiviert ist -> Leicht blau
                                                } else if(isJustDoneToDos(date: dayValue.date) && userSelected.showDoneToDos){
                                                    Text("\(dayValue.day)").foregroundColor(Colors.primaryColor).fontWeight(.light).opacity(0.5)
                                                    
                                                //Sonst standard schwarz
                                                } else {
                                                    Text("\(dayValue.day)").fontWeight(.light)
                                                }
                                            case .isMarked: //Filter = markierte Erinnerung
                                                //Für Tag, hat Erinnerungen -> Gelb
                                                if(!isEmptyOnDate(date: dayValue.date)){
                                                    Text("\(dayValue.day)")
                                                        .foregroundColor(appearance == .dark ? .yellow : Color.init(red: 255/255, green: 170/255, blue: 29/255))
                                                        .fontWeight(.light)
                                                //Für Tag, hat erledigte Erinnerungen -> Leichtes Gelb
                                                } else if(isJustDoneToDos(date: dayValue.date)){
                                                    Text("\(dayValue.day)")
                                                        .foregroundColor(appearance == .dark ? .yellow : Color.init(red: 255/255, green: 170/255, blue: 29/255))
                                                        .fontWeight(.light)
                                                        .opacity(0.5)
                                                } else {
                                                    Text("\(dayValue.day)").fontWeight(.light)
                                                }
                                            }
                                        }
                                    }.frame(width: 29, height: 29, alignment: .center)
                                }).buttonStyle(.plain)
                            } else {
                                Text("")
                            }
                        }
                    }
                    //Initialisierung CalendarView - Ausgewählter Tag = aktuelles Datum
                    .onAppear{
                        userSelected.selectedDate = Date()
                        userSelected.lastSelectedDate = Date()
                    }
                    //Wenn "Navigiere zu" bestätigt wurde -> wird zu Ausgewählter Tag
                    .onChange(of: userSelected.lastSelectedDate){ newValue in
                        navigateDate = userSelected.lastSelectedDate
                    }
                    Spacer()
                    //Erinnerungen ohne Datum
                    HStack{
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
                //Versteckter Link zum Navigieren zwischen den ToDoListViews
                VStack {
                    NavigationLink(destination: ToDoListView(title: DateInString(date: userSelected.lastSelectedDate, type: "display"), rowType: .calendar, listFilterType: toDoListFilterType, userSelected: userSelected), isActive: $listViewIsActive){ EmptyView() }
                }.hidden()
            }
            .frame(minWidth: 300)
        }
        .navigationTitle("Kalender")
    }
}

//EXTENSIONS
//Modell für einen Tag
struct DateValue: Hashable{
    let id = UUID().uuidString
    var day: Int
    var date: Date
}
extension CalendarView{
    //Gib ausgewähltes Jahr
    func getYear() -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY"
        let year = formatter.string(from: userSelected.lastSelectedDate)
        return year
    }
    
    //Gib ausgewählter Monat
    func getMonth() -> String{
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "de_DE")
        formatter.dateFormat = "MMMM"
        let month = formatter.string(from: userSelected.lastSelectedDate)
        return month
    }
    
    //Gib aktueller Monat
    func getCurrentMonth(date: Date = Date()) -> Date {
        let calendar = Calendar.current //Kalendereinstellungen wiedergeben
        var resultDate = Date()
        
        let inputDay = calendar.dateComponents([.day], from: date).day
        let currentMonth = calendar.dateComponents([.month], from: date).month
        let currentYear = calendar.dateComponents([.year], from: date).year
        
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
    
    //Extrahiere alle Datum für ausgewählten Monat
    func extractDate() -> [DateValue] {
        let calendar = Calendar.current //Kalender
        
        // Alle Datum für den ausgewählten Monat
        let currentMonth = getCurrentMonth()
        var days = currentMonth.getAllDates().compactMap { date -> DateValue in
            let day = calendar.component(.day, from: date)
            let dateValue =  DateValue(day: day, date: date)
            return dateValue
        }
        
        // Offset für richtige Wochentage-Position
        let firstWeekday = calendar.component(.weekday, from: days.first?.date ?? Date())
            for _ in 0..<firstWeekday + 5 {
                days.insert(DateValue(day: -1, date: Date()), at: 0) //Wenn kein Tag vorhanden
            }
            return days
        }
    
    //Funktion: Wenn Ergenisse von todos leer sind -> true
    func isEmptyOnDate(date: Date)->Bool{
        let calendar = Calendar.current
        let dateFrom = calendar.startOfDay(for: date)
        let dateTo = calendar.date(byAdding: .minute, value: 1439, to: dateFrom)
        let format = returnFormatOfFilter()
        
        let predicate = NSPredicate(format: format + " && todoIsDone == false", dateTo! as CVarArg, dateFrom as CVarArg, dateTo! as CVarArg, dateFrom as CVarArg)
        todos.nsPredicate = predicate
        if todos.isEmpty{
            return true
        } else {
            return false
        }
    }
    
    //Funktion: Wenn todos für das Datum nur erledigte Erinnerungen haben -> true
    func isJustDoneToDos(date: Date)->Bool{
        let calendar = Calendar.current
        let dateFrom = calendar.startOfDay(for: date)
        let dateTo = calendar.date(byAdding: .minute, value: 1439, to: dateFrom)
        let format = returnFormatOfFilter()
        
        var predicate = NSPredicate(format: format + " && todoIsDone == false", dateTo! as CVarArg, dateFrom as CVarArg, dateTo! as CVarArg, dateFrom as CVarArg)
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
    
    //Funktion: Filter Liste mit Datum
    func predicateList(date: Date){
        let dateFrom = Calendar.current.startOfDay(for: date)
        let dateTo = Calendar.current.date(byAdding: .minute, value: 1439, to: dateFrom)
        
        //Filter nach Format returnFormatOfFilter()
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
    //Filterformat für CalendarView
    func returnFormatOfFilter()->String{
        var format = ""
        switch(filter){
        case.deadline:
            format = "todoDeadline <= %@ && todoDeadline >= %@"
        case.notification:
            format = "todoNotification <= %@ && todoNotification >= %@"
        case.isMarked:
            format = "((todoDeadline <= %@ && todoDeadline >= %@) || (todoNotification <= %@ && todoNotification >= %@)) && todoIsMarked == true"
        }
        return format
    }
}

//Subviews von CalendarView
//"Navigiere zu"
struct DateNavigatorPopover: View{
    @EnvironmentObject private var userSelected: UserSelected
    //"Erbt" Variablen von Haupt-View CalendarView
    @Binding var currentMonth: Int
    @Binding var navigateDate: Date
    var body: some View{
        VStack{
            LeftText(text: "Navigiere zu", font: .title2, fontWeight: .bold)
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
//UI: Filter auswählen
struct SelectFilterPopover: View{
    @Binding var filter: CalendarViewFilterToDoType
    var body: some View{
        VStack{
            LeftText(text: "Filter", font: .title2, fontWeight: .bold)
            HStack{
                Picker("", selection: $filter){
                    Text("Fällig am ").tag(CalendarViewFilterToDoType.deadline)
                    Text("Erinnerung").tag(CalendarViewFilterToDoType.notification)
                    Text("Markiert").tag(CalendarViewFilterToDoType.isMarked)
                }
                .pickerStyle(.inline)
                Spacer()
            }
        }
        .padding()
    }
}
//UI: Button zum Navigieren der Monate
struct MonthNavigatorButton: View {
    let name: String
    let color: Color
    let size: CGFloat = 22.5
    
    var body: some View{
        ZStack{
            Circle().fill(color).opacity(0.2)
            Image(systemName: name)
                .foregroundColor(color)
        }
        .padding(0)
        .frame(width: size, height: size)
    }
}

