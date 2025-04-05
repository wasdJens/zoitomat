//
//  ZoitomatTests.swift
//  ZoitomatTests
//
//  Created by Jens Reiner on 09.01.25.
//

import Testing
@testable import Zoitomat

struct ZoitomatTests {

    @Test("Start time entry")
    func startTimeEntry() async throws {
        var testEntry = ZoitTimeEntry(
            title: "Time Entry Test"
        )
        
        testEntry.startOrResume()
        
        #expect(testEntry.state == .running)
        #expect(testEntry.startedAt != nil)
    }
    
    @Test("Stop time entry")
    func stopTimeEntry() async throws {
        var testEntry = ZoitTimeEntry(
            title: "Time Entry Test"
        )
        
        testEntry.startOrResume()
        try await Task.sleep(for: .seconds(1))
        
        testEntry.stop()
        
        #expect(testEntry.state == .stopped)
        #expect(testEntry.stoppedAt != nil)
    }
}
