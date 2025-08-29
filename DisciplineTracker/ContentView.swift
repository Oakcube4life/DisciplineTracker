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

            DailyLogView()
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

struct DailyLogData: Identifiable {
    let id = UUID()
    let date: Date
    let totalScore: Int
}

// Shared sample data
let sampleLogs: [DailyLogData] = [
    DailyLogData(date: Date().addingTimeInterval(-4*86400), totalScore: 85),
    DailyLogData(date: Date().addingTimeInterval(-3*86400), totalScore: 70),
    DailyLogData(date: Date().addingTimeInterval(-2*86400), totalScore: 90),
    DailyLogData(date: Date().addingTimeInterval(-1*86400), totalScore: 95),
    DailyLogData(date: Date(), totalScore: 60)
]

struct DailyLogView: View {
    @State private var nutrition: Double = 0
    @State private var sleep: Double = 0
    @State private var physical: Double = 0
    @State private var educational: Double = 0
    @State private var financial: Double = 0
    
    var totalScore: Int {
        Int(nutrition + sleep + physical + educational + financial)
    }
    
    var body: some View {
        NavigationView {
            Form {
                VStack(alignment: .leading) {
                    Text("Nutrition: \(Int(nutrition))")
                    Slider(value: $nutrition, in: 0...20, step: 1)
                        .accentColor(.green)
                }.padding(.vertical)
                
                VStack(alignment: .leading) {
                    Text("Sleep: \(Int(sleep))")
                    Slider(value: $sleep, in: 0...20, step: 1)
                        .accentColor(.blue)
                }.padding(.vertical)
                
                VStack(alignment: .leading) {
                    Text("Physical: \(Int(physical))")
                    Slider(value: $physical, in: 0...20, step: 1)
                        .accentColor(.red)
                }.padding(.vertical)
                
                VStack(alignment: .leading) {
                    Text("Educational: \(Int(educational))")
                    Slider(value: $educational, in: 0...20, step: 1)
                        .accentColor(.orange)
                }.padding(.vertical)
                
                VStack(alignment: .leading) {
                    Text("Financial: \(Int(financial))")
                    Slider(value: $financial, in: 0...20, step: 1)
                        .accentColor(.purple)
                }.padding(.vertical)
                
                Text("Todays Score: \(totalScore)")
                    .font(.headline)
                    .padding(.top)
                
                Button(action: {
                    print("Daily log saved: \(totalScore) points")
                    // Future: Save to persistence here
                }) {
                    Text("Save Log")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.top)
            }
            .navigationTitle("Daily Log")
        }
    }
}

struct DashboardView: View {
    var totalPoints: Int {
        sampleLogs.reduce(0) { $0 + $1.totalScore }
    }
    
    var averagePoints: Double {
        sampleLogs.isEmpty ? 0 : Double(totalPoints) / Double(sampleLogs.count)
    }
    
    var currentStreak: Int {
        var streak = 0
        for log in sampleLogs.reversed() {
            if log.totalScore > 0 {
                streak += 1
            } else {
                break
            }
        }
        return streak
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    
                    // Total Points
                    VStack {
                        Text("Total Points")
                            .font(.headline)
                        Text("\(totalPoints)")
                            .font(.largeTitle)
                            .bold()
                    }
                    
                    // Current Streak
                    VStack {
                        Text("Current Streak")
                            .font(.headline)
                        Text("\(currentStreak) days")
                            .font(.title)
                            .foregroundColor(.green)
                    }
                    
                    // Average Points
                    VStack {
                        Text("Average Points")
                            .font(.headline)
                        Text(String(format: "%.1f", averagePoints))
                            .font(.title)
                            .foregroundColor(.blue)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Points Over Time")
                            .font(.headline)
                        
                        Chart {
                            // Daily logs line
                            ForEach(sampleLogs) { log in
                                LineMark(
                                    x: .value("Date", log.date),
                                    y: .value("Total Points", log.totalScore)
                                )
                                .foregroundStyle(.blue)
                                .symbol(Circle())
                            }
                            
                            // Average Line
                            RuleMark(y: .value("Average Points", averagePoints))
                                .foregroundStyle(.black)
                                .lineStyle(StrokeStyle(lineWidth: 2, dash: [5]))
                        }
                        .frame(height: 200)
                    }
                    .padding(.top)

                    
                    // Motivational text
                    VStack {
                        if currentStreak >= 5 {
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
}

struct HistoryView: View {
    // Date formatter for display
    private var dateFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateStyle = .medium
        return df
    }
    
    var body: some View {
        NavigationView {
            List(sampleLogs) { log in
                HStack {
                    Text(dateFormatter.string(from: log.date))
                    Spacer()
                    Text("\(log.totalScore) pts")
                        .bold()
                }
            }
            .navigationTitle("History")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
