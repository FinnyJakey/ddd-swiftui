//
//  DDaysViewModel.swift
//  ddd
//
//  Created by Finny Jakey on 2023/10/07.
//

import Foundation

class DDaysViewModel: ObservableObject {
    @Published var DDays: [DDay] = []
    
    let dataService = PersistenceController.shared
    
    init() {
        getAllDDays()
    }

    func getAllDDays() {
        DDays = dataService.read()
    }

    func createDDay(id: String, title: String, date: String, startWithOne: Bool) {
        dataService.create(id: id, title: title, date: date, startWithOne: startWithOne, order: (DDays.last?.order ?? 0) + 1)
        getAllDDays()
    }
    
    func deleteDDay(dday: DDay) {
        dataService.delete(dday)
        getAllDDays()
    }
    
    func moveDDay(from source: IndexSet, to destination: Int) {
        DDays.move(fromOffsets: source, toOffset: destination)
        dataService.move(from: source, to: destination, entities: DDays)
        getAllDDays()
    }
    
    func updateDDay(id: String, title: String, date: String, startWithOne: Bool, order: Int64) {
        dataService.update(id: id, title: title, date: date, startWithOne: startWithOne, order: order)
        getAllDDays()
    }
}
