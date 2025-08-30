//
//  LogStore.swift
//  DisciplineTracker
//
//  Created by Gavin MacFadyen on 2025-08-29.
//

import Foundation

struct DailyLog: Identifiable, Codable {
    var id: UUID = UUID()
    let date: Date
    let nutrition: Double
    let sleep: Double
    let physical: Double
    let education: Double
    let financial: Double
    
    var totalPoints: Double {
        nutrition + sleep + physical + education + financial
    }
}

class LogStore: ObservableObject {
    @Published var logs: [DailyLog] = []
    
    private let saveKey = "dailyLogs"
    
    init() {
        load()
    }
    
    func addLog(_ log: DailyLog) {
        logs.append(log)
        save()
    }
    
    func hasLog(for date: Date) -> Bool {
        logs.contains { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }
    
    func resetAllLogs() {
        logs.removeAll()
        UserDefaults.standard.removeObject(forKey: "dailyLogs")
    }
    
    private func save() {
        if let encoded = try? JSONEncoder().encode(logs) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    private func load() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([DailyLog].self, from: data) {
            logs = decoded
        }
    }
}
