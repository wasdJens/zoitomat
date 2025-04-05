//
//  ContentView.swift
//  Zoitomat
//
//  Created by Jens Reiner on 09.01.25.
//

import SwiftUI
import SwiftData

enum ActiveView: Hashable {
    case timeEntries
    case projects
}

struct ContentView: View {
    @State private var columnVisibility = NavigationSplitViewVisibility.detailOnly
    @State private var activeView: ActiveView? = .timeEntries
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            List(selection: $activeView) {
                NavigationLink("Time Entries", value: ActiveView.timeEntries)
                NavigationLink("Projects", value: ActiveView.projects)
            }
            .navigationTitle("Categories")
            .onChange(of: activeView) { newValue, _ in
                navigationPath = NavigationPath()
            }
        } detail: {
            NavigationStack(path: $navigationPath) {
                if let activeView = activeView {
                    switch activeView {
                    case .timeEntries:
                        TimeEntriesListView()
                    case .projects:
                        ProjectListView()
                    }
                } else {
                    Text("Landing Page")
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: ZoitTimeEntry.self, inMemory: true)
}

struct TimeEntriesListView: View {
    @Query(filter: #Predicate<ZoitTimeEntry> { entry in
        entry.isArchived == false
    }, sort: \ZoitTimeEntry.createdOn) private var timeEntries: [ZoitTimeEntry]
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTimeEntries: Set<ZoitTimeEntry> = []
    
    private func addItem() {
        withAnimation {
            let newItem = ZoitTimeEntry(label: "New Time Entry")
            modelContext.insert(newItem)
        }
    }
    
    private func deleteItems() {
        withAnimation {
            for entry in selectedTimeEntries {
                entry.archive() // Call the custom archive method
            }
            selectedTimeEntries.removeAll()
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                List(timeEntries, id: \.self, selection: $selectedTimeEntries) { entry in
                    EntryDetail(entry: entry)
                        .listRowSeparator(.hidden)
                        .listRowBackground(selectedTimeEntries.contains(entry) ? Color.accentColor.opacity(0.3) : Color.clear)
                }
                .listStyle(.plain)
                
                // Custom bottom toolbar view
                if !selectedTimeEntries.isEmpty {
                    HStack {
                        Button(action: deleteItems) {
                            Label("Delete", systemImage: "trash")
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        Spacer()
                    }
                    .padding()
                    .background(Color(NSColor.windowBackgroundColor))
                }
            }
            .navigationTitle("Time Entries")
            .toolbar {
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Track time", systemImage: "plus")
                            .labelStyle(.titleAndIcon)
                    }
                }
            }
        }
    }
}

struct ProjectListView: View {
    @Query(sort: \ZoitProject.name) var projects: [ZoitProject]
    
    var body: some View {
        NavigationStack {
            List(projects) { project in
                NavigationLink(value: project) {
                    Text(project.name)
                }
            }
            .navigationTitle(Text("Projects"))
            .navigationDestination(for: ZoitProject.self) { project in
                ProjectDetailView(project: project)
            }
        }
    }
}

struct ProjectDetailView: View {
    @Bindable var project: ZoitProject
    
    var body: some View {
        VStack {
            Text("Project: \(project.name)")
        }
        .padding()
        .navigationTitle(Text("Project Detail"))
    }
}

struct EntryDetail: View {
    @Bindable var entry: ZoitTimeEntry
    
    // Formatter to display date in YYYY-MM-DD HH:MM format
    private var formattedCreatedOn: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter.string(from: entry.createdOn)
    }
    
    var body: some View {
        HStack(alignment: .center) {
            // Left side: Label and created timestamp
            VStack(alignment: .leading, spacing: 4) {
                TextField("Label", text: $entry.label)
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(.system(size: 16))
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    Text(formattedCreatedOn)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
            // Right side: Timer and button controls
            HStack(spacing: 16) {
                TimerView(entry: entry)
                switch entry.state {
                case .created, .paused, .stopped:
                    Button(action: { entry.startOrResume() }) {
                        Image(systemName: "play.circle")
                            .font(.system(size: 32))
                    }
                    .buttonStyle(BorderlessButtonStyle())
                case .running:
                    Button(action: { entry.pause() }) {
                        Image(systemName: "pause.circle")
                            .font(.system(size: 32))
                    }
                    .buttonStyle(BorderlessButtonStyle())
                case .archived:
                    Text("Not Possible")
                        .font(.system(size: 20))
                }
            }
        }
        .padding()
        .font(.system(size: 20))
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray.opacity(0.1)) // Adjust the color as needed
                .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
        )
    }
}
