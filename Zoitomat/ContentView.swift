//
//  ContentView.swift
//  Zoitomat
//
//  Created by Jens Reiner on 09.01.25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Query private var timeEntries: [TimeEntry]
    @Environment(\.modelContext) private var modelContext
    
    @State private var columnVisibility = NavigationSplitViewVisibility.detailOnly
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            List(timeEntries) { entry in
                HStack {
                    Text(entry.title)
                    TimerView(entry: entry)
                    switch entry.state {
                    case .created, .paused, .stopped:
                        Button("", systemImage: "play.circle") {
                            entry.startOrResume()
                        }
                    case .running:
                        Button("", systemImage: "pause.circle") {
                            entry.pause()
                        }
                    case .archived:
                        Text("Not Possible")
                    }
                }
            }
            .navigationSplitViewColumnWidth(min: 250, ideal: 300)
            .toolbar {
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        } detail: {
            DatePicker(selection: /*@START_MENU_TOKEN@*/.constant(Date())/*@END_MENU_TOKEN@*/, label: { /*@START_MENU_TOKEN@*/Text("Date")/*@END_MENU_TOKEN@*/ })
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = TimeEntry(title: "New Item")
            modelContext.insert(newItem)
        }
    }

}

#Preview {
    ContentView()
        .modelContainer(for: TimeEntry.self, inMemory: true)
}
