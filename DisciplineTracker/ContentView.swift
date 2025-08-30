//
//  ContentView.swift
//  DisciplineTracker
//
//  Created by Gavin MacFadyen on 2025-08-29.
//

import SwiftUI
import Charts

struct ContentView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "chart.bar")
                }

            LogView()
                .tabItem {
                    Label("Log", systemImage: "checkmark.circle")
                }
                        
            HistoryView()
                .tabItem {
                    Label("History", systemImage: "calendar")
                }
        }
    }
}

struct DashboardView: View {
    @EnvironmentObject var logStore: LogStore
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    
                    // Total Points
                    VStack {
                        Text("Total Points")
                            .font(.headline)
                        Text("\(totalPoints())")
                            .font(.largeTitle)
                            .bold()
                    }
                    
                    // Current Streak
                    VStack {
                        Text("Current Streak")
                            .font(.headline)
                        Text("\(currentStreak()) days")
                            .font(.title)
                            .foregroundColor(.green)
                    }
                    
                    // Average Points
                    VStack {
                        Text("Average Points")
                            .font(.headline)
                        Text(String(format: "%.1f", averagePoints()))
                            .font(.title)
                            .foregroundColor(.blue)
                    }
                    
                    VStack(alignment: .leading) {
                        if logStore.logs.isEmpty {
                            Text("Log data to view graph")
                                .foregroundColor(.gray)
                                .italic()
                                .frame(height: 200)
                                .frame(maxWidth: .infinity)
                                .background(Color(white: 0.95))
                                .cornerRadius(10)
                                .padding(.top)
                        } else {
                            Chart {
                                
                                
                                ForEach(logStore.logs) { log in
                                    LineMark(
                                        x: .value("Date", log.date),
                                        y: .value("Total Points", log.totalPoints)
                                    )
                                    .foregroundStyle(.blue)
                                    .symbol(Circle())
                                }
                                
                                // Average line, only if there is data
                                if !logStore.logs.isEmpty {
                                    RuleMark(y: .value("Average Points", averagePoints()))
                                        .foregroundStyle(.black)
                                        .lineStyle(StrokeStyle(lineWidth: 2, dash: [5]))
                                }
                            }
                            .frame(height: 200)
                        }
                    }
                    .padding(.top)
                    
                    // Motivational text TODO: add more of these
                    VStack {
                        if currentStreak() >= 5 {
                            Text("🔥 Keep it up! You're on fire!")
                                .font(.title3)
                                .multilineTextAlignment(.center)
                                .padding()
                        } else {
                            Text("Keep logging daily to build your streak!")
                                .font(.title3)
                                .multilineTextAlignment(.center)
                                .padding()
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Dashboard")
        }
    }
    
    private func averagePoints() -> Double {
        guard !logStore.logs.isEmpty else { return 0 }
        let total = logStore.logs.map { $0.totalPoints }.reduce(0, +)
        return total / Double(logStore.logs.count)
    }
    
    private func totalPoints() -> Int {
        let total = logStore.logs.map { $0.totalPoints }.reduce(0, +)
        return Int(total)
    }
    
    private func currentStreak() -> Int {
        // Super basic streak counter
        let sorted = logStore.logs.sorted(by: { $0.date > $1.date })
        guard let mostRecent = sorted.first else { return 0 }
        
        var streak = 1
        var prevDate = mostRecent.date
        
        for log in sorted.dropFirst() {
            if Calendar.current.isDate(log.date, inSameDayAs: Calendar.current.date(byAdding: .day, value: -1, to: prevDate)!) {
                streak += 1
                prevDate = log.date
            } else {
                break
            }
        }
        
        return streak
    }
}

struct LogView: View {
    @EnvironmentObject var logStore: LogStore
    @State private var nutrition: Double = 0
    @State private var sleep: Double = 0
    @State private var physical: Double = 0
    @State private var education: Double = 0
    @State private var financial: Double = 0
    
    var totalScore: Int {
        Int(nutrition + sleep + physical + education + financial)
    }
    
    var body: some View {
        NavigationView {
            Form {
                SliderView(title: "Nutrition", slideColor: .orange, value: $nutrition)
                SliderView(title: "Sleep", slideColor: .purple, value: $sleep)
                SliderView(title: "Physical", slideColor: .red, value: $physical)
                SliderView(title: "Education", slideColor: .green, value: $education)
                SliderView(title: "Financial", slideColor: .blue, value: $financial)
                
                Text("Todays Score: \(totalScore)")
                    .font(.headline)
                    .padding(.top)
                
                Button("Save Log") {
                    let newLog = DailyLog(
                        date: Date(),
                        nutrition: nutrition,
                        sleep: sleep,
                        physical: physical,
                        education: education,
                        financial: financial
                    )
                    logStore.addLog(newLog)
                }
                .disabled(logStore.hasLog(for: Date()))
                .frame(maxWidth: .infinity)
                .padding()
                .background(logStore.hasLog(for: Date()) ? Color.gray : Color.blue.opacity(0.8))
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .navigationTitle("Daily Log")
        }
    }
}

struct SliderView: View {
    let title: String
    let slideColor: Color
    @Binding var value: Double
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("\(title): \(Int(value))")
            Slider(value: $value, in: 0...20, step: 1)
                .accentColor(slideColor)
        }.padding(.vertical)
    }
}

struct HistoryView: View {
    @EnvironmentObject var logStore: LogStore
    
    var body: some View {
        NavigationView {
            List {
                ForEach(logStore.logs.sorted(by: { $0.date > $1.date })) { log in
                    VStack(alignment: .leading) {
                        Text(log.date, style: .date)
                            .font(.headline)
                        Text("Total Points: \(log.totalPoints, specifier: "%.0f")")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                Button("Reset All Logs") {
                    logStore.resetAllLogs()
                }
                .padding()
                .disabled(logStore.logs.isEmpty)
                .frame(maxWidth: .infinity)
                .background(logStore.logs.isEmpty ? Color.gray : Color.red.opacity(0.8))
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            
            .navigationTitle("History")
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(LogStore())
    }
}
