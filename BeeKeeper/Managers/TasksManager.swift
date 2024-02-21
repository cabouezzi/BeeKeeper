//
//  TasksManager.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 2/20/24.
//

import Foundation

class TasksManager {
    static let shared = TasksManager()
    
    // TODO: TaskData struct and change array
    let tasks: [String] = [
        "Task 1",
        "Task 2",
        "Task 3",
    ]
    
    private init() {
        
    }
}
