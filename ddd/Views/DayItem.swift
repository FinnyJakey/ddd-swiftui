//
//  DayItem.swift
//  ddd
//
//  Created by Finny Jakey on 2023/10/07.
//

import SwiftUI

struct DayItem: View {
    let dday: DDay
    
    @ObservedObject var ddaysVM: DDaysViewModel = DDaysViewModel()
    
    var body: some View {
        VStack(alignment: .leading) {
            Spacer(minLength: 18)
            
            HStack {
                Text(getDayInformation(date: dday.date!))
                    .font(.callout)
                    .foregroundColor(.accentColor)
                
                Spacer()
                
                Text(getDateInformation(date: dday.date!))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            
            Spacer(minLength: 8)
            
            Text(dday.title!)

            Spacer(minLength: 18)

            Divider()
            
            
        }
        .frame(
            minWidth: 0,
            maxWidth: .infinity,
            minHeight: 0,
            maxHeight: .infinity,
            alignment: .topLeading
        )
    }
    
    func getDayInformation(date: Date) -> String {
        let dateFormatter: DateFormatter = .init()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.locale = Locale.current
        
        let todayString = dateFormatter.string(from: Date())
        guard let todayDate = dateFormatter.date(from: todayString) else {
            return ""
        }
        
        let compareDayString = dateFormatter.string(from: date)
        guard let compareDate = dateFormatter.date(from: compareDayString) else {
            return ""
        }
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: todayDate, to: compareDate)
        
        if (components.day == 0) {
            return dday.startWithOne ? "1 days" : "D-DAY"
        }
        
        if (components.day! > 0) {
            return "D-\(components.day!)"
        }
        
        if (components.day! < 0) {
            return dday.startWithOne ? "\(abs(components.day!) + 1) days" : "\(abs(components.day!)) days"
        }
        
        return ""
    }
    
    func getDateInformation(date: Date) -> String {
        let dateFormatter: DateFormatter = .init()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.locale = Locale.current
        
        return dateFormatter.string(from: date)
    }
}
