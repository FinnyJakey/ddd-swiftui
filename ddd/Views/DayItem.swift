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
                Text(getDayInformation(inputDateString: dday.date!))
                    .font(.callout)
                    .foregroundColor(.accentColor)

                Spacer()

                Text(dday.date!)
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
    
    func getDayInformation(inputDateString: String) -> String {
        let dateFormatter: DateFormatter = .init()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        
        let calendar = Calendar.current
        let todayDate = calendar.startOfDay(for: Date())
        let targetDate = calendar.startOfDay(for: dateFormatter.date(from: inputDateString)!)
        
        let components = calendar.dateComponents([.day], from: todayDate, to: targetDate)
        
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
}
