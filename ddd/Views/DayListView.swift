//
//  DayListView.swift
//  ddd
//
//  Created by Finny Jakey on 2023/10/07.
//

import SwiftUI
import WidgetKit

struct DayListView: View {
    @StateObject var ddaysVM: DDaysViewModel = DDaysViewModel()

    var body: some View {
        List {
            Text("My D-Day \(ddaysVM.DDays.count)")
                .font(.caption)
                .foregroundColor(.secondary.opacity(1.4))
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
                .padding(.horizontal)
            
            ForEach(ddaysVM.DDays) { dday in
                DayItem(dday: dday)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets())
                    .swipeActions(allowsFullSwipe: false) {
                        Button {
                            deleteItem(item: dday)
                        } label: {
                            Image(systemName: "trash")
                        }
                        .tint(.red)
                        
                        NavigationLink {
                            EditView(dday: dday, ddaysVM: ddaysVM)
                        } label: {
                            Image(systemName: "square.and.pencil")
                        }
                        .tint(.yellow)
                    }
                    .padding(.horizontal)
                
                
            }
            .onDelete(perform: deleteItemIndexSet)
            .onMove(perform: moveItemIndexSet)
        }
        .listStyle(.plain)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    AddView(ddaysVM: ddaysVM)
                } label: {
                    Text("Add")
                        .foregroundColor(.secondary.opacity(1.5))
                }
            }
            
            ToolbarItem(placement: .navigationBarLeading) {
                EditButton()
                    .foregroundColor(.secondary.opacity(1.5))
                
            }
        }
    }
    
    func deleteItem(item dday: DDay) {
        ddaysVM.deleteDDay(dday: dday)
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    func deleteItemIndexSet(at offsets: IndexSet) {
        withAnimation {
            offsets.map { ddaysVM.DDays[$0] }.forEach(ddaysVM.deleteDDay)
        }
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    func moveItemIndexSet(from source: IndexSet, to destination: Int) {
        ddaysVM.moveDDay(from: source, to: destination)
        WidgetCenter.shared.reloadAllTimelines()
    }
}

struct DayListView_Previews: PreviewProvider {
    static var previews: some View {
        DayListView(ddaysVM: DDaysViewModel())
    }
}
