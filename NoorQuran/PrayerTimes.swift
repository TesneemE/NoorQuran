//
//  PrayerTimes.swift
//  NoorQuran
//
//  Created by Tes Essa on 11/29/24.
//
import Foundation
import Combine
struct PrayerTimes: Identifiable, Codable {
    var id: String { date.readable } // Use the date as the unique identifier
    let date: date_format
    let meta: meta_data
    let timings: prayer_timings
}
struct prayer_timings: Codable {
    let Fajr: String
    let Sunrise: String
    let Dhuhr: String
    let Asr: String
    let Maghrib: String
    let Isha: String
}
struct meta_data: Codable{
    let latitude: Double
    let longitude: Double
}

struct date_format: Codable{
    let readable: String
}
struct PrayerTimesResponse: Codable {
    let code: Int
    let status: String
    let data: PrayerTimes
}
