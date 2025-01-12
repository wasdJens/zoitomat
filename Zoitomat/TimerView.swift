//
//  TimerView.swift
//  Zoitomat
//
//  Created by Jens Reiner on 12.01.25.
//

import SwiftUI

struct TimerView: View {
    @Bindable var entry: TimeEntry
    
    @State private var display = "00:00"
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        Text(display)
            .onReceive(timer) { _ in
                updateDisplay()
            }
            .onAppear {
                updateDisplay()
            }
    }
    
    private func updateDisplay() {
        let elapsedTime: TimeInterval
        if entry.state == .running, let startedAt = entry.startedAt {
            elapsedTime = Date().timeIntervalSince(startedAt) - entry.totalPausedDuration
        } else {
            elapsedTime = entry.duration
        }

        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        display = formatter.string(from: elapsedTime) ?? "00:00"
    }
}

#Preview {
    TimerView(entry: TimeEntry(title: "Test"))
}
