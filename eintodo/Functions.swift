//
//  Functions.swift
//  eintodo
//
//  Created by anh :) on 16.12.21.
//
import Foundation
import SwiftUI
import UserNotifications

//CORE-DATA
//Erstelle ein ToDoList, wenn keine vorhanden sind
func createList(viewContext: NSManagedObjectContext){
    let newToDoList = ToDoList(context: viewContext)
    newToDoList.listID = UUID()
    newToDoList.listTitle = "Neue Liste"
    newToDoList.listDescription = "Eine Liste, wo man Erinnerungen hinzufügen kann"
    newToDoList.listColor = "standard"
    newToDoList.listSymbol = "list.bullet"
    saveContext(context: viewContext)
}
//CoreData - Sichern durch ViewContext
public func saveContext(context: NSManagedObjectContext){
    do{
        try context.save()
    }catch{
        let nsError = error as NSError
        fatalError("Could not save NSManagedObjectContext: \(nsError), \(nsError.userInfo)")
    }
}
//CoreData - Alle Erinnerungslisten-Filter
func filterToDo(us: UserSelected, filterType: ToDoListFilterType)->(sortDescriptors: [NSSortDescriptor], predicate: NSPredicate?){
    let calendar = Calendar.current
    let dateFrom = calendar.startOfDay(for: us.lastSelectedDate)
    let dateTo = calendar.date(byAdding: .minute, value: 1439, to: dateFrom)
    let defaultDate = Dates.defaultDate
    let currentDate = Date()
    
    var sortDescriptor: [NSSortDescriptor] = []
    var predicate: NSPredicate? = nil
    var predicateFormat: String = ""
    
    switch(filterType){
    case .dates: //To-Dos mit deadline und/oder notfication
        sortDescriptor =
            [NSSortDescriptor(keyPath: \ToDo.todoIsDone, ascending: true),
            NSSortDescriptor(keyPath: \ToDo.todoDeadline, ascending: true),
            NSSortDescriptor(keyPath: \ToDo.todoNotification, ascending: true)]
        predicateFormat = "(todoDeadline <= %@ && todoDeadline >= %@) || (todoNotification <= %@ && todoNotification >= %@)"
        predicate = NSPredicate(format: predicateFormat, dateTo! as CVarArg, dateFrom as CVarArg, dateTo! as CVarArg, dateFrom as CVarArg)
    case .noDates: //To-Dos ohne deadline und notification
        sortDescriptor =
            [NSSortDescriptor(keyPath: \ToDo.todoIsDone, ascending: true),
            NSSortDescriptor(keyPath: \ToDo.todoTitle, ascending: true)]
        predicateFormat = "todoDeadline == %@ && todoNotification == %@"
        predicate = NSPredicate(format: predicateFormat, defaultDate as CVarArg,  defaultDate as CVarArg)
    case .inPast: //Alle To-Dos in der Vergangenheit was noch nicht erledigt wurde
        sortDescriptor =
            [NSSortDescriptor(keyPath: \ToDo.todoIsDone, ascending: true),
            NSSortDescriptor(keyPath: \ToDo.todoDeadline, ascending: true),
            NSSortDescriptor(keyPath: \ToDo.todoNotification, ascending: true)]
        predicateFormat = "todoDeadline < %@ && todoDeadline != %@"
        predicate = NSPredicate(format: predicateFormat, currentDate as CVarArg, defaultDate as CVarArg)
    case .marked: //Alle markierten Erinnerungen
        sortDescriptor =
            [NSSortDescriptor(keyPath: \ToDo.todoIsDone, ascending: true),
            NSSortDescriptor(keyPath: \ToDo.todoDeadline, ascending: true),
            NSSortDescriptor(keyPath: \ToDo.todoNotification, ascending: true)]
        predicateFormat = "todoIsMarked == true"
        predicate = NSPredicate(format: predicateFormat)
    case .all: //Alle To-Dos
        sortDescriptor = [ NSSortDescriptor(keyPath: \ToDo.todoIsDone, ascending: true),
                           NSSortDescriptor(keyPath: \ToDo.todoDeadline, ascending: true),
                           NSSortDescriptor(keyPath: \ToDo.todoNotification, ascending: true)]
        predicate = nil
    case .list: //Filtern nach Liste
        sortDescriptor = [NSSortDescriptor(keyPath: \ToDo.todoIsDone, ascending: true),
                           NSSortDescriptor(keyPath: \ToDo.todoDeadline, ascending: true),
                           NSSortDescriptor(keyPath: \ToDo.todoNotification, ascending: true)]
        predicateFormat = "idOfToDoList == %@"
        predicate = NSPredicate(format: predicateFormat, us.selectedToDoListID as CVarArg)
    }
    return(sortDescriptor, predicate)
}

//GETTER
//Gib den Start des Monats
func getStartOfMonth() -> Date {
    return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: Date())))!
}
//Gib den Interval des Monats, die zwischen dem Input Datum und dem Aktuellen Datum liegen
func getMonthInterval(from date: Date) -> Int {
    var interval = Calendar.current.dateComponents([.second], from: Date(), to: date).second!
    if(interval > 0){
        interval = Calendar.current.dateComponents([.month], from: getStartOfMonth(), to: date).month!
    } else {
        interval = Calendar.current.dateComponents([.month], from: Date(), to: date).month!
    }
    return interval
}
//Gib den Interval in Sekunden an, die zwischen dem Input Datum und dem Aktuellen Datum liegen
func getInterval(from date: Date) -> Int {
    let interval = Calendar.current.dateComponents([.second], from: Date(), to: date).second!
    return interval
}
//Return Farbe von String
func getColorFromString(string: String)->Color{
    switch(string){
    case "standard": return Colors.primaryColor
        case "red": return Color.red
        case "pink": return Color.pink
        case "orange": return Color.orange
        case "yellow": return Color.yellow
        case "green": return Color.green
        case "blue": return Color.blue
        case "indigo": return Color.indigo
        case "purple": return Color.purple
        case "brown": return Color.brown
        case "gray": return Color.gray
        default: return Color.indigo
    }
}
//Konvertiere die Input-Zeit und gebe es als String zurück
func getTime(date: Date)->String{
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm"
    return formatter.string(from: date)
}
//Konvertiere das Datum und gebe es als String zurück
func getDate(date: Date)->String{
    let formatter = DateFormatter()
    formatter.dateFormat = "dd.MM.yyyy"
    return formatter.string(from: date)
}
//Kombiniere das Datum (String) und die Zeit (String) zu einem neuen Datum ung gebe es als Typ Datum zurück
func combineDateAndTime(date: String, time: String)->Date{
    let formatter = DateFormatter()
    formatter.dateFormat = "dd.MM.yyyy, HH:mm"
    let DATE = "\(date), \(time)"
    return formatter.date(from: DATE)!
}
 
//Formatters
//Formattiere Datum zum String
 func DateInString(date: Date, format: String = "dd.MM.yyyy", type: String) -> String{
    let timeFormatter = DateFormatter()
    timeFormatter.dateFormat = ", HH:mm"
    let formatter = DateFormatter()
    formatter.dateFormat = format
    var output = ""
    
    if(type == "deadline"){ // Typ ist deadline
        if(isTomorrow(date: date)){
            output = "Morgen fällig"
        } else if (isToday(date: date)){
            output = "Heute fällig"
        } else if (isYesterday(date: date)){
            output = "Gestern fällig"
        } else {
            output = "Fällig am " + formatter.string(from: date)
        }
    } else if(type == "notification"){ // Typ ist notification (bei ToDoEditRow)
        if(isTomorrow(date: date)){
            output = "Morgen" + timeFormatter.string(from: date)
        } else if (isToday(date: date)){
            output = "Heute" + timeFormatter.string(from: date)
        } else if (isYesterday(date: date)){
            output = "Gestern" + timeFormatter.string(from: date)
        } else {
            output = formatter.string(from: date) + timeFormatter.string(from: date)
        }
    } else if (type == "display"){ // Typ ist display
        if(isTomorrow(date: date)){
            output = "Morgen"
        } else if (isToday(date: date)){
            output = "Heute"
        } else if (isYesterday(date: date)){
            output = "Gestern"
        } else if(date == Dates.defaultDate){
            output = "Erinnerungen ohne Datum"
        }
        else {
            output = formatter.string(from: date)
        }
    } else {
        output = "Error"
    }
    return output
}

//Vergleiche
//Vergleiche zwei Datum, wenn gleicher Tag -> true
 func isSameDay(date1: Date, date2: Date) -> Bool {
    return Calendar.current.isDate(date1, inSameDayAs: date2)
}
//Wenn Datum ist gestern -> true
 func isYesterday(date: Date)->Bool{
    return Calendar.current.isDate(date, inSameDayAs: Date().addingTimeInterval(-TimeInterval(SecondsCalculated.day)))
}
//Wenn Datum ist heute -> true
 func isToday(date: Date)->Bool{
    return Calendar.current.isDate(date, inSameDayAs: Date())
}
//Wenn Datum ist morgen -> true
 func isTomorrow(date: Date)->Bool{
    return Calendar.current.isDate(date, inSameDayAs: Date().addingTimeInterval(TimeInterval(SecondsCalculated.day)))
}
//Wenn Datum in der Vergangenheit liegt -> rote Farbe (ToDoListRow)
 func isDateInPast(date: Date, defaultColor: Color)->Color{
    let currentDate = Calendar.current.startOfDay(for: Date())
    if date != Dates.defaultDate{
        if date < currentDate{
            return .red
        } else {
            return defaultColor
        }
    } else {
        return defaultColor
    }
}
//Wenn Datum in der Vergangenheit liegt -> true
 func isDateInPast(date: Date) -> Bool{
    let currentDate = Calendar.current.startOfDay(for: Date())
    if date != Dates.defaultDate{
        if date < currentDate{
            return true
        } else {
            return false
        }
    } else {
        return false
    }
}

//USERNOTIFICATION
//Erbittet die Erlaubnis Mitteilungen zu senden
func askForUserNotificationPermission(){
    //Ask user for UserNotification permission
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]){ success, error in
        if success {
        } else if let error = error {
            print(error.localizedDescription)
        }
    }
}
//Füge Mitteilung hinzu
func updateUserNotification(title: String, id: UUID, date: Date, type: String){
    if date != Dates.defaultDate{
        deleteUserNotification(identifier: id)
        //Add UserNotification
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = DateInString(date: date, type: type)
        content.sound = UNNotificationSound.default
        
        if(getInterval(from: date) > 0){
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(getInterval(from: date)), repeats: false)
            let request = UNNotificationRequest(identifier: id.uuidString, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request)
            print("The notification is set for \(date) \n title: \(title) \n subtitle: \(DateInString(date: date, type: type)) \n id: \(id)")
        }
    }
}
//Lösche Mitteilung
func deleteUserNotification(identifier: UUID){
    UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [identifier.uuidString])
    print("The notification is deleted for the id \(identifier) \n")
}

//Konvertiere [NSImage] to Data und zurück zur Speicherung von Bildern
func NSImageArrayToCoreData(images: [NSImage])->Data? {
    let imageArray = NSMutableArray()
    for img in images{
        let data = img.tiffRepresentation
        imageArray.add(data!)
    }
    return try? NSKeyedArchiver.archivedData(withRootObject: imageArray, requiringSecureCoding: true)
}
func CoreDataToNSImageArray(coreDataObject: Data?)->[NSImage]?{
    var images = [NSImage]()
    guard let object = coreDataObject else { return nil }
    if let imageArray = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSArray.self, from: object) {
        for img in imageArray {
            if let img = img as? Data, let image = NSImage(data: img) {
                images.append(image)
            }
        }
    }
    return images
}
