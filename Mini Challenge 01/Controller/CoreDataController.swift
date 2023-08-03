//
//  CoreDataController.swift
//  Mini Challenge 01
//
//  Created by Thiago Liporace on 03/08/23.
//

import Foundation
import CoreData

class CoreDataController: ObservableObject {
    let container = NSPersistentContainer(name: "Model")
    
    init() {
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Could not receive data: \(error.localizedDescription)")
            }
        }
    }
}
