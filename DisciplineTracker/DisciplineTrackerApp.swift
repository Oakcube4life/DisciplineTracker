//
//  DisciplineTrackerApp.swift
//  DisciplineTracker
//
//  Created by Gavin MacFadyen on 2025-08-29.
//

import SwiftUI

@main
struct DisciplineTrackerApp: App {
    @StateObject private var logStore = LogStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(logStore)
        }
    }
}
