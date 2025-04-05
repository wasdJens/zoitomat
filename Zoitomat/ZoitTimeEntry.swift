//
//  TimeEntry.swift
//  Zoitomat
//
//  Created by Jens Reiner on 11.01.25.
//

import Foundation
import SwiftData

enum TimerState: Codable {
    case created
    case running
    case paused
    case stopped
    case archived
}

@Model
class ZoitTimeEntry: Identifiable {
    var id = UUID()
    
    /**
     * Data Model Properties
     */
    
    // The actual time entry label something like "Project XY"
    var label: String
    // Internal state for easily update the UI
    var state: TimerState
    // Date when the entry was created
    var createdOn: Date
    // Anytime the entry is modified we keep track of it
    var modifiedOn: Date
    // Start date when the tracking started
    var startedAt: Date?
    // End date when tracking stopped
    var stoppedAt: Date?
    // Archives the time entry when the user removes it
    var isArchived = false
    // Keep track of the total idle time
    var pauseStartedAt: Date?
    var totalPausedDuration: TimeInterval = 0
    // Time entry final duration
    var duration: TimeInterval = 0
    
    
    /**
     * Relationships
     */
    @Relationship(inverse: \ZoitProject.timeEntries)
    var project: ZoitProject?
    
    init(label: String, createdOn: Date = Date(), modifiedOn: Date = Date()) {
        self.label = label
        self.createdOn = createdOn
        self.modifiedOn = modifiedOn
        self.state = TimerState.created
    }
    
    func startOrResume() {
        switch state {
        case .created:
            startedAt = Date()
            modifiedOn = Date()
            state = .running
            break
        case .paused:
            // Resuming a paused timer
            guard let pauseStart = pauseStartedAt else {
                zoity.error("No paused state to resume from")
                return
            }
            totalPausedDuration += Date().timeIntervalSince(pauseStart)
            pauseStartedAt = nil
            modifiedOn = Date()
            state = .running
            break
        default:
            zoity.error("A time entry tried to start but was already archived")
        }
    }
    
    func stop() {
        guard state == .running || state == .paused else {
            zoity.error("A time entry tried to stop but was never started or paused")
            return
        }
        
        guard let startedAt = startedAt else {
            zoity.error("Cannot stop timer without a startedAt date")
            return
        }
        
        if state == .paused, let pauseStart = pauseStartedAt {
            totalPausedDuration += Date().timeIntervalSince(pauseStart)
            pauseStartedAt = nil
        }
        
        stoppedAt = Date()
        modifiedOn = Date()
        duration = stoppedAt!.timeIntervalSince(startedAt) - totalPausedDuration
        state = .stopped
    }
    
    func pause() {
        guard state == .running else {
            zoity.error("A time entry tried to pause but was never started")
            return
        }
        guard let startedAt = startedAt else {
            zoity.error("Cannot pause timer without a startedAt date")
            return
        }
        pauseStartedAt = Date()
        duration = Date().timeIntervalSince(startedAt) - totalPausedDuration
        modifiedOn = Date()
        state = .paused
    }
    
    func archive() {
        guard state == .running || state == .paused else {
            zoity.error("Can not delete a running time entry")
            return
        }

        modifiedOn = Date()
        isArchived = true
        state = .archived
    }
}
