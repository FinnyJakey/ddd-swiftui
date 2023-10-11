//
//  EditView.swift
//  ddd
//
//  Created by Finny Jakey on 2023/10/07.
//

import SwiftUI
import WidgetKit

struct EditView: View {
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var ddaysVM: DDaysViewModel

    let dday: DDay
    
    @State var title: String
    @State var date: Date
    @State var startWithOne: Bool
    
    @State var disabled: Bool = false
    
    init(dday: DDay, ddaysVM: DDaysViewModel) {
        self.dday = dday
        self.ddaysVM = ddaysVM
        
//        _title = State(initialValue: dday.title!)
        _title = State(initialValue: dday.title ?? "")
//        _date = State(initialValue: dday.date!)
        _date = State(initialValue: dday.date ?? Date())
        _startWithOne = State(initialValue: dday.startWithOne)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                HStack() {
                    TextField("Title", text: $title)
                        .onChange(of: title, perform: { _ in
                            limitText(15)
                            
                            if (title.count > 0) {
                                disabled = false
                            } else {
                                disabled = true
                            }
                        })
                    
                    Text("\(title.count)/15")
                        .foregroundColor(.secondary.opacity(0.5))
                        .font(.footnote)
                }
                
                Divider()
                
                Spacer(minLength: 20)
                
                DatePicker("Date", selection: $date, displayedComponents: .date)
                    .environment(\.locale, Locale.current)
                    .datePickerStyle(.compact)
                
                Spacer(minLength: 12)
                
                Divider()
                    .overlay(Color(red: 0.9, green: 0.9, blue: 0.9))
                
                VStack(alignment: .leading) {
                    Toggle("Getting Started with 1 day", isOn: $startWithOne)
                    Text("Set the D-Day as 1 day")
                        .foregroundColor(.secondary)
                        .font(.callout)
                    
                }
            }
            .padding()
            .frame(
                minWidth: 0,
                maxWidth: .infinity,
                minHeight: 0,
                maxHeight: .infinity,
                alignment: .topLeading
            )
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.primary)
                }
                
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    let dateFormatter: DateFormatter = .init()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
                    dateFormatter.locale = Locale.current
                    
                    let selectedDateString = dateFormatter.string(from: date)
                    guard let selectedDate = dateFormatter.date(from: selectedDateString) else {
                        return
                    }
                    
                    ddaysVM.updateDDay(id: dday.id!, title: title, date: selectedDate, startWithOne: startWithOne, order: dday.order)

                    WidgetCenter.shared.reloadAllTimelines()
                    
                    dismiss()
                } label: {
                    Text("Done")
                        .foregroundColor(.secondary.opacity(disabled ? 0.5 : 1.5))
                }
                .disabled(disabled)
                
            }
        }
        .navigationTitle("Edit D-Day")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
    }
    
    func limitText(_ upper: Int) {
        if title.count > upper {
            title = String(title.prefix(upper))
        }
    }
}

struct EditView_Previews: PreviewProvider {
    static var previews: some View {
        EditView(dday: DDay.init(entity: .init(), insertInto: .none), ddaysVM: DDaysViewModel())
    }
}
