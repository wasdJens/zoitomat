//
//  ZoitProject.swift
//  Zoitomat
//
//  Created by Jens Reiner on 05.04.25.
//

import Foundation
import SwiftData

@Model
class ZoitProject: Identifiable {
    var id = UUID()
    
    /**
     * Data Model Properties
     */
    var name: String
    var timeEntries: [ZoitTimeEntry] = []
    
    init(name: String) {
        self.name = name
    }
    
    func addTimeEntries(_ entries: [ZoitTimeEntry]) {
        for entry in entries {
            if !timeEntries.contains(where: { $0.id == entry.id}) {
                timeEntries.append(entry)
            }
        }
    }
    
    func removeTimeEntries(_ entries: [ZoitTimeEntry]) {
        for entry in entries {
            if let index = timeEntries.firstIndex(where: { $0.id == entry.id }) {
                timeEntries.remove(at: index)
            }
        }
    }
}
