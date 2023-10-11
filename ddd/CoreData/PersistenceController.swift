//
//  PersistenceController.swift
//  ddd
//
//  Created by Finny Jakey on 2023/10/07.
//

import Foundation
import CoreData

class PersistenceController {
    static let shared = PersistenceController()
    let container: NSPersistentContainer

    init(inMemory: Bool = false) { // TODO: Bool = false
        container = NSPersistentContainer(name: "DDay")
        let url = URL.storeURL(for: "group.com.finnyjakey.ddd", databaseName: "DDay")
        let storeDescription = NSPersistentStoreDescription(url: url)
        container.persistentStoreDescriptions = [storeDescription]

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { description, error in
            if let error {
                print("Could not load Core Data persistence stores.", error.localizedDescription)
                fatalError()
            }
        }
    }
    
    func saveChanges() {
        let context = container.viewContext

        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Could not save changes to Core Data.", error.localizedDescription)
            }
        }
    }
    
    func create(id: String, title: String, date: Date, startWithOne: Bool, order: Int64) {
        let entity = DDay(context: container.viewContext)
        
        entity.id = id
        entity.title = title
        entity.date = date
        entity.startWithOne = startWithOne
        entity.order = order
        
        saveChanges()
    }
    
    func read(predicateFormat: String? = nil, fetchLimit: Int? = nil) -> [DDay] {
        // create a temp array to save fetched notes
        var results: [DDay] = []
        // initialize the fetch request
        let request = NSFetchRequest<DDay>(entityName: "DDay")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \DDay.order, ascending: true)]

        // define filter and/or limit if needed
        if predicateFormat != nil {
            request.predicate = NSPredicate(format: predicateFormat!)
        }
        if fetchLimit != nil {
            request.fetchLimit = fetchLimit!
        }

        // fetch with the request
        do {
            results = try container.viewContext.fetch(request)
        } catch {
            print("Could not fetch from Core Data.")
        }

        return results
    }
    
    func delete(_ entity: DDay) {
        container.viewContext.delete(entity)
        
        saveChanges()
    }
    
    func move(from source: IndexSet, to destination: Int, entities items: [DDay]) {
        let revisedItems: [DDay] = items.map{ $0 }
        
        for reverseIndex in stride(from: revisedItems.count - 1, through: 0, by: -1) {
            revisedItems[reverseIndex].order = Int64(reverseIndex)
        }
        
        saveChanges()
    }
    
    func update(id: String, title: String, date: Date, startWithOne: Bool, order: Int64) {
        var results: [DDay] = []

        let request = NSFetchRequest<DDay>(entityName: "DDay")
        request.predicate = NSPredicate(format: "id = %@", id)
        
        do {
            results = try container.viewContext.fetch(request)
        } catch {
            print("Could not fetch from Core Data.")
        }
        
        guard let itemDDay = results.first else {
            return
        }
        
        itemDDay.title = title
        itemDDay.date = date
        itemDDay.startWithOne = startWithOne
        itemDDay.order = order
        
        saveChanges()
    }
}

public extension URL {
    static func storeURL(for appGroup: String, databaseName: String) -> URL {
        guard let fileContainer = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup) else {
            fatalError("Unable to create URL for \(appGroup)")
        }
        
        return fileContainer.appendingPathComponent("\(databaseName).sqlite")
    }
}
