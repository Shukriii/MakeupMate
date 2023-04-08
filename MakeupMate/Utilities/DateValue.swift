//
//  DateValue.swift
//  MakeupMate
//
//  Created by Shukri  Ahmed on 07/04/2023.
//

import SwiftUI


struct DateValue: Identifiable{
    var id = UUID().uuidString
    var day: Int
    var date: Date
}

//Array of Tasks
struct Task: Identifiable{
    var id = UUID().uuidString //product id?
    var title: String //product.name
    var time : Date = Date()
    
}

struct TaskMetaData: Identifiable {
    var id = UUID().uuidString
    var task: [Task]
    var taskDate: Date
}

func getSampleDate(offset: Int)->Date{
    let calendar = Calendar.current
    let date = calendar.date(byAdding: .day, value: offset, to: Date())
    
    return date ?? Date()
}

var tasks: [TaskMetaData] = [
    TaskMetaData(task: [
        Task(title: "Task 1"),
        Task(title: "Task 2"),
        Task(title: "Task 3"),
    ], taskDate: getSampleDate(offset: 1)),
    
    TaskMetaData(task: [
        Task(title: "Task 4"),
    ], taskDate: getSampleDate(offset: -3)),
    
    TaskMetaData(task: [
        Task(title: "Task 5"),
    ], taskDate: getSampleDate(offset: -8)),
    
    TaskMetaData(task: [
        Task(title: "Task 6"),
    ], taskDate: getSampleDate(offset: 10)),
]

// A expiry product has an Id, name and date
struct ExpiryProduct: Identifiable{
    var id = UUID().uuidString
    var name: String
    var time : Date = Date()
}

struct ExpiryProductMetaData: Identifiable {
    var id = UUID().uuidString
    var expiryProduct: [ExpiryProduct]
    var expireDate: Date
}

var expiredProducts: [ExpiryProductMetaData] = [
    ExpiryProductMetaData(expiryProduct: [
        ExpiryProduct(name: "Product 1"),
        ExpiryProduct(name: "Product 2"),
        ExpiryProduct(name: "Product 3"),
    ], expireDate: getSampleDateFromDateString(dateString: "28 Apr 2023 at 14:47:00 GMT+1")),

    ExpiryProductMetaData(expiryProduct: [
        ExpiryProduct(name: "Product 4"),
    ], expireDate: getSampleDateFromDateString(dateString: "9 Apr 2023 at 14:47:00 GMT+1")),

    ExpiryProductMetaData(expiryProduct: [
        ExpiryProduct(name: "Product 5"),
    ], expireDate: getSampleDateFromDateString(dateString: "1 Apr 2023 at 14:47:00 GMT+1")),
]

func getSampleDateFromDateString(dateString: String) -> Date {
    // Takes the date "28 Apr 2023 at 14:47:00 GMT+1" and make into "28 Apr 2023"
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd MMM yyyy"
    guard let date = dateString.components(separatedBy: " at ").first.flatMap({ dateFormatter.date(from: $0) }) else {
        return Date() // Provide a default value in case date calculation fails
    }
    
    // Figures out offset
    let calendar = Calendar.current
    let today = calendar.startOfDay(for: Date())
    let otherDate = calendar.startOfDay(for: date)
    let components = calendar.dateComponents([.day], from: today, to: otherDate)

    // Calculates sample date using the offset
    let calendarNow = Calendar.current
    
    let sampleDate = calendarNow.date(byAdding: .day, value: components.day!, to: Date()) //components.day ?? 0

    return sampleDate ?? Date() // Provide a default value in case sample date calculation fails
}

//func getOffsetFromDateString(dateString: String) -> Int? {
//    let dateFormatter = DateFormatter()
//    dateFormatter.dateFormat = "dd MMM yyyy"
//    guard let date = dateString.components(separatedBy: " at ").first.flatMap({ dateFormatter.date(from: $0) }) else {
//        return nil
//    }
//
//    let calendar = Calendar.current
//    let today = calendar.startOfDay(for: Date())
//    let otherDate = calendar.startOfDay(for: date)
//    let components = calendar.dateComponents([.day], from: today, to: otherDate)
//
//    return components.day
//}

//func getOffsetFromDateString(dateString: String) -> Int? {
//    let dateFormatter = DateFormatter()
//    dateFormatter.dateFormat = "dd MMM yyyy"
//    guard let date = dateString.components(separatedBy: " at ").first.flatMap({ dateFormatter.date(from: $0) }) else {
//        return nil
//    }
//
//    let calendar = Calendar.current
//    let today = calendar.startOfDay(for: Date())
//    let otherDate = calendar.startOfDay(for: date)
//    let components = calendar.dateComponents([.day], from: today, to: otherDate)
//
//    return components.day
//}

//func getDateFromDateString(dateString: String) -> Date? {
//    let dateFormatter = DateFormatter()
//    dateFormatter.dateFormat = "dd MMM yyyy"
//    guard let date = dateString.components(separatedBy: " at ").first.flatMap({ dateFormatter.date(from: $0) }) else {
//        return nil
//    }
//
//    return date
//}
