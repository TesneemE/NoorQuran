//
//  BarChartWeekView.swift
//  NoorQuran
//
//  Created by Tes Essa on 12/9/24.
//

import SwiftUI
import Charts
import Foundation


struct BarChartWeekView: View {
    @EnvironmentObject var memorizationStore: MemorizationStore
    @State private var weekData: [AyahsMemorizedWeekly] = []
    @State private var isBarChart = true

    var body: some View {
        VStack {
            Text("Memorization History")
                .foregroundColor(.black)
                .bold()
                .font(.title)
                .padding()
            
            if weekData.isEmpty {
                Text("No data available for the past week.")
                    .font(.headline)
                    .padding()
            } else {
                if isBarChart {
                    Chart(weekData) { day in
                        BarMark(
                            x: .value("Date", day.date, unit: .day),
                            y: .value("Ayahs Memorized", day.count)
                        )
                    }
                    .chartXAxisLabel("Date")
                    .chartYAxisLabel("Ayahs Memorized")
                    .foregroundColor(Color("Green").opacity(0.9))
                    .padding()
                } else {
                    Chart(weekData) { day in
                        LineMark(
                            x: .value("Date", day.date, unit: .day),
                            y: .value("Ayahs Memorized", day.count)
                        )
                        .symbol(.circle)
                        .interpolationMethod(.catmullRom)
                    }
                    .chartXAxisLabel("Date")
                    .chartYAxisLabel("Ayahs Memorized")
                    .foregroundColor(Color("Green").opacity(0.9))
                    .padding()
                }
            }


            Toggle("Bar Chart", isOn: $isBarChart)
                .padding()
                .foregroundColor(.black)
        }
        .onAppear {
            weekData = memorizationStore.weeklyMemorizedAyahs()
            
        //to fill in missing days w/ 0
            let calendar = Calendar.current
            let today = Date()
            let lastWeekDates = (0..<7).map { calendar.date(byAdding: .day, value: -$0, to: today)! }
            
            weekData = lastWeekDates.map { date in
                weekData.first(where: { calendar.isDate($0.date, inSameDayAs: date) })
                ?? AyahsMemorizedWeekly(date: date, count: 0)
            }
            .sorted { $0.date < $1.date } // to sort in order
        }

    }
}

struct BarChartWeekView_Previews: PreviewProvider {
    static var store: MemorizationStore = {
        let store = MemorizationStore()
        store.memorizedAyahs = [
            MemorizedAyah(surah: 1, surahName: "Al-Fatiha", ayah: 1, dateMemorized: Date()),
            MemorizedAyah(surah: 2, surahName: "Al-Baqara", ayah: 255, dateMemorized: Calendar.current.date(byAdding: .day, value: -1, to: Date())!)
        ]
        return store
    }()
    static var previews: some View {
        BarChartWeekView()
            .environmentObject(store) 
    }
}


//
//struct BarChartWeekView_Previews: PreviewProvider {
//  static var previews: some View {
//      BarChartWeekView()
//      .environmentObject(HistoryStore(preview: true))
//  }
//}
