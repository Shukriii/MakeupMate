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

