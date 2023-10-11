//
//  AddView.swift
//  ddd
//
//  Created by Finny Jakey on 2023/10/07.
//

import SwiftUI
import WidgetKit

struct AddView: View {
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var ddaysVM: DDaysViewModel

    @State var title: String = ""
    @State var date: Date = .now
    @State var startWithOne: Bool = false
    @State var disabled: Bool = true
    
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
                
                Spacer(minLength: 20)
                
                VStack(alignment: .leading, spacing: 0) {
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
                    
                    ddaysVM.createDDay(id: UUID().uuidString, title: title, date: selectedDate, startWithOne: startWithOne)

                    WidgetCenter.shared.reloadAllTimelines()
                    
                    dismiss()
                } label: {
                    Text("Apply")
                        .foregroundColor(.secondary.opacity(disabled ? 0.5 : 1.5))
                }
                .disabled(disabled)
                
            }
        }
        .navigationTitle("Add D-Day")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
    }
    
    func limitText(_ upper: Int) {
        if title.count > upper {
            title = String(title.prefix(upper))
        }
    }
}

struct AddView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AddView(ddaysVM: DDaysViewModel())
        }
    }
}
