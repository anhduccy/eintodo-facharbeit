//
//  Functions.swift
//  eintodo
//
//  Created by anh :) on 16.12.21.
//
import Foundation
import SwiftUI
import UserNotifications

//Create a ToDoList, if there are no lists available
func createList(viewContext: NSManagedObjectContext){
    let newToDoList = ToDoList(context: viewContext)
    newToDoList.listID = UUID()
    newToDoList.listTitle = "Neue Liste"
    newToDoList.listDescription = "Eine Liste, wo man Erinnerungen hinzufügen kann"
    newToDoList.listColor = "indigo"
    newToDoList.listSymbol = "list.bullet"
    saveContext(context: viewContext)
}

//CoreData - Save ViewContext
public func saveContext(context: NSManagedObjectContext){
    do{
        try context.save()
    }catch{
        let nsError = error as NSError
        fatalError("Could not save NSManagedObjectContext: \(nsError), \(nsError.userInfo)")
    }
}

//GETTER
//Get the start of month
func getStartOfMonth() -> Date {
    return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: Date())))!
}
//Get difference of month between input date and current date (not interval)
func getMonthInterval(from date: Date) -> Int {
    var interval = Calendar.current.dateComponents([.second], from: Date(), to: date).second!
    if(interval > 0){
        interval = Calendar.current.dateComponents([.month], from: getStartOfMonth(), to: date).month!
    } else {
        interval = Calendar.current.dateComponents([.month], from: Date(), to: date).month!
    }
    return interval
}
//Get interval in sconds between input date and current date
func getInterval(from date: Date) -> Int {
    let interval = Calendar.current.dateComponents([.second], from: Date(), to: date).second!
    return interval
}
//Return a color from a string
func getColorFromString(string: String)->Color{
    switch(string){
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
//Get time from date and return it as a String
func getTime(date: Date)->String{
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm"
    return formatter.string(from: date)
}
//Get day, month and year from date and return it as a String
func getDate(date: Date)->String{
    let formatter = DateFormatter()
    formatter.dateFormat = "dd.MM.yyyy"
    return formatter.string(from: date)
}
//Combine date (String) and time (String) to a new date and return it as the type Date
func combineDateAndTime(date: String, time: String)->Date{
    let formatter = DateFormatter()
    formatter.dateFormat = "dd.MM.yyyy, HH:mm"
    let DATE = "\(date), \(time)"
    return formatter.date(from: DATE)!
}
 
//Formatters
//Format Date into String -> A support function for ViewLibrary (ListRow)
 func DateInString(date: Date, format: String = "dd.MM.yyyy", type: String) -> String{
    let timeFormatter = DateFormatter()
    timeFormatter.dateFormat = ", HH:mm"
    let formatter = DateFormatter()
    formatter.dateFormat = format
    var output = ""
    
    if(type == "deadline"){ // Type is deadline
        if(isTomorrow(date: date)){
            output = "Morgen fällig"
        } else if (isToday(date: date)){
            output = "Heute fällig"
        } else if (isYesterday(date: date)){
            output = "Gestern fällig"
        } else {
            output = "Fällig am " + formatter.string(from: date)
        }
    } else if(type == "notification"){ // Type is notification
        if(isTomorrow(date: date)){
            output = "Morgen" + timeFormatter.string(from: date)
        } else if (isToday(date: date)){
            output = "Heute" + timeFormatter.string(from: date)
        } else if (isYesterday(date: date)){
            output = "Gestern" + timeFormatter.string(from: date)
        } else {
            output = formatter.string(from: date) + timeFormatter.string(from: date)
        }
    } else if (type == "display"){ // Type is display
        if(isTomorrow(date: date)){
            output = "Morgen"
        } else if (isToday(date: date)){
            output = "Heute"
        } else if (isYesterday(date: date)){
            output = "Gestern"
        } else {
            output = formatter.string(from: date)
        }
    } else {
        output = "Error"
    }
    return output
}

//Comparisons
//Compare two dates and return true if it is the same
 func isSameDay(date1: Date, date2: Date) -> Bool {
    return Calendar.current.isDate(date1, inSameDayAs: date2)
}
//If input date is equal as the yesterday's date, return true
 func isYesterday(date: Date)->Bool{
    return Calendar.current.isDate(date, inSameDayAs: Date().addingTimeInterval(-TimeInterval(SecondsCalculated.day)))
}
//If input date is current date, return true
 func isToday(date: Date)->Bool{
    return Calendar.current.isDate(date, inSameDayAs: Date())
}
//If input date is equal as the tomorrow date, return true
 func isTomorrow(date: Date)->Bool{
    return Calendar.current.isDate(date, inSameDayAs: Date().addingTimeInterval(TimeInterval(SecondsCalculated.day)))
}
//If input date is before the current date, return a color
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
//If input date is before the current date, return true
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

//USERNOTIFICATION - Ask for permisson, add and delete notification of ToDo.deadline and ToDo.notification
func askForUserNotificationPermission(){
    //Ask user for UserNotification permission
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]){ success, error in
        if success {
        } else if let error = error {
            print(error.localizedDescription)
        }
    }
}

func updateUserNotification(title: String, id: UUID, date: Date, type: String){
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
func deleteUserNotification(identifier: UUID){
    UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [identifier.uuidString])
    print("The notification is deleted for the id \(identifier) \n")
}

/* Convert [NSImage] to Data and backwards (Storing Images)
 * This will be disallowed in the future (Further information in the terminal, if you try to save an image)
 */
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
