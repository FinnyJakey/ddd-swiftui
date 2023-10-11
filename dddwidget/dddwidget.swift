//
//  dddwidget.swift
//  dddwidget
//
//  Created by Finny Jakey on 2023/10/08.
//

import WidgetKit
import SwiftUI
import Intents

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> DDayEntry {
        DDayEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (DDayEntry) -> ()) {
        let entry: DDayEntry = DDayEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [DDayEntry] = []
        
        let currentDate = Date()
        for dayOffset in 0..<7 {
            let entryDate = Calendar.current.date(byAdding: .day, value: dayOffset, to: currentDate)!
            let startOfDate = Calendar.current.startOfDay(for: entryDate)
            let entry = DDayEntry(date: startOfDate)
            entries.append(entry)
        }
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct DDayEntry: TimelineEntry {
    let date: Date
}

func getData() throws -> [DDay] {
    let context = PersistenceController.shared.container.viewContext
    
    let request = DDay.fetchRequest()
    request.sortDescriptors = [NSSortDescriptor(keyPath: \DDay.order, ascending: true)]

    let result = try context.fetch(request)
    
    return result
}

func getDayInformation(date: Date, startWithOne: Bool) -> String {
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
        return startWithOne ? "1 days" : "D-DAY"
    }
    
    if (components.day! > 0) {
        return "D-\(components.day!)"
    }
    
    if (components.day! < 0) {
        return startWithOne ? "\(abs(components.day!) + 1) days" : "\(abs(components.day!)) days"
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

struct dddwidgetEntryView : View {
    @Environment(\.widgetFamily) private var widgetFamily
    
    var entry: Provider.Entry
    
    let firstData = try? getData().first
    
    var body: some View {
        switch widgetFamily {
        case .systemSmall:
            SystemSmallWidget(dayInfo: getDayInformation(date: firstData?.date ?? Date(), startWithOne: firstData?.startWithOne ?? false), title: firstData?.title ?? "Birth Day", dateInfo: getDateInformation(date: firstData?.date ?? Date()))
        case .systemMedium:
            SystemMediumWidget(dayInfo: getDayInformation(date: firstData?.date ?? Date(), startWithOne: firstData?.startWithOne ?? false), title: firstData?.title ?? "Birth Day", dateInfo: getDateInformation(date: firstData?.date ?? Date()))
        case .accessoryRectangular:
            VStack(alignment: .center) {
                Text(firstData?.title ?? "Birth Day")
                    .font(.callout)
                    .foregroundColor(.secondary)
                
                Spacer()
                    .frame(height: 8)
                
                Text(getDayInformation(date: firstData?.date ?? Date.now, startWithOne: firstData?.startWithOne ?? false))
                    .fontWeight(.semibold)

            }
        default:
            Text("UNKNOWN")
        }
        
    }
}

struct SystemSmallWidget : View {
    let dayInfo: String
    let title: String
    let dateInfo: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(dayInfo)
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(.accentColor)
            
            Spacer()
                .frame(height: 8)
            
            Text(title)
            
            Spacer()
                .frame(height: 6)
            
            Text(dateInfo)
                .font(.caption)
                .foregroundColor(.secondary)
            
        }
    }
}

struct SystemMediumWidget : View {
    let dayInfo: String
    let title: String
    let dateInfo: String
    
    var body: some View {
        VStack(alignment: .center) {
            Text(title)
                .font(.title2)
            
            Spacer()
                .frame(height: 8)
            
            Text(dayInfo)
                .font(.title)
                .fontWeight(.medium)
                .foregroundColor(.accentColor)
            
            Spacer()
                .frame(height: 6)
            
            Text(dateInfo)
                .font(.callout)
                .foregroundColor(.secondary)
        }
    }
}

struct dddwidget: Widget {
    let kind: String = "dddwidget"

    private var supportedFamilies: [WidgetFamily] {
        return [.systemSmall, .systemMedium, .accessoryRectangular]
    }
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            dddwidgetEntryView(entry: entry)
        }
        .configurationDisplayName("DDD")
        .description("You can choose your D-Day widget.")
        .supportedFamilies(supportedFamilies)
    }
}

struct dddwidget_Previews: PreviewProvider {
    static var previews: some View {
        dddwidgetEntryView(entry: DDayEntry(date: Date()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
//            .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
//            .previewContext(WidgetPreviewContext(family: .accessoryCircular))
    }
}

