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
                EntryDetail(entry: entry, isDetail: false)
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
            List(timeEntries) { entry in
                EntryDetail(entry: entry)
            }
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

struct EntryDetail: View {
    @Bindable var entry: TimeEntry
    var isDetail: Bool = true
    
    var body: some View {
        VStack {
            HStack {
                Text(entry.createdOn.ISO8601Format())
            }
            HStack {
                if (isDetail) {
                    Form {
                        TextField("", text: $entry.title)
                    }
                } else {
                    Text(entry.title)
                }
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

    }
}
