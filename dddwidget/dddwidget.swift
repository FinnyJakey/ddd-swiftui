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
        
        let calendar = Calendar.current

        guard let nextMidnight = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: calendar.date(byAdding: .day, value: 1, to: currentDate)!) else {
            return
        }
        
        let entry = DDayEntry(date: nextMidnight)
        entries.append(entry)

        let timeline = Timeline(entries: entries, policy: .after(nextMidnight))
        
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

struct dddwidgetEntryView : View {
    @Environment(\.widgetFamily) private var widgetFamily
    
    var entry: Provider.Entry
    
    let firstData = try? getData().first
    
    var body: some View {
        switch widgetFamily {
        case .systemSmall:
            SystemSmallWidget(
                dayInfo: getDayInformation(inputDateString: firstData?.date ?? Date.now.toStringWithoutTime(), startWithOne: firstData?.startWithOne ?? false),
                title: firstData?.title ?? "Birth Day",
                dateInfo: firstData?.date ?? Date.now.toStringWithoutTime()
            )
        case .systemMedium:
            SystemMediumWidget(
                dayInfo: getDayInformation(inputDateString: firstData?.date ?? Date.now.toStringWithoutTime(), startWithOne: firstData?.startWithOne ?? false),
                title: firstData?.title ?? "Birth Day",
                dateInfo: firstData?.date ?? Date.now.toStringWithoutTime()
            )
        case .accessoryRectangular:
            VStack(alignment: .center) {
                Text(firstData?.title ?? "Birth Day")
                    .font(.callout)
                    .foregroundColor(.secondary)

                Spacer()
                    .frame(height: 8)

                Text(getDayInformation(inputDateString: firstData?.date ?? Date.now.toStringWithoutTime(), startWithOne: firstData?.startWithOne ?? false))
                    .fontWeight(.semibold)

            }
        default:
            Text("UNKNOWN")
        }
        
    }
    
    func getDayInformation(inputDateString: String, startWithOne: Bool) -> String {
        let dateFormatter: DateFormatter = .init()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        
        let calendar = Calendar.current
        let todayDate = calendar.startOfDay(for: Date())
        let targetDate = calendar.startOfDay(for: dateFormatter.date(from: inputDateString)!)
        
        let components = calendar.dateComponents([.day], from: todayDate, to: targetDate)
        
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

extension Date {
    func toStringWithoutTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        return dateFormatter.string(from: self)
    }
}
