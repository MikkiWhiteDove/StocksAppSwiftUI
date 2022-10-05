//
//  Models.swift
//  StocksApp
//
//  Created by Mishana on 01.10.2022.
//

import Foundation

struct Stocks: Codable, Identifiable {
    let id = UUID()
    let metaData: MetaData
    let timeSeries5Min: [String: TimeSeries5Min]
    
    var latestClose: String {
        timeSeries5Min.first?.value.close ?? "NaN"
    }
    
    var closeValues: [Double] {
        let rawValues = timeSeries5Min.values.map { Double($0.close)!}
        let max = rawValues.max()!
        let min = rawValues.min()!
        
        return rawValues.map { ($0 - min * 0.95) / (max - min * 0.95) }
    }
    
    var openClose: Bool {
        guard let close = Double(timeSeries5Min.values.first!.close) else {return Bool()}
        guard let open = Double(timeSeries5Min.values.reversed().first!.open) else {return Bool()}
        
        return open <= close
    }
    
    enum CodingKeys: String, CodingKey {
        case metaData = "Meta Data"
        case timeSeries5Min = "Time Series (5min)"
    }
}

// MARK: - MetaData
struct MetaData: Codable {
    let information, symbol, lastRefreshed, interval: String
    let outputSize, timeZone: String

    enum CodingKeys: String, CodingKey {
        case information = "1. Information"
        case symbol = "2. Symbol"
        case lastRefreshed = "3. Last Refreshed"
        case interval = "4. Interval"
        case outputSize = "5. Output Size"
        case timeZone = "6. Time Zone"
    }
}

// MARK: - TimeSeries5Min
struct TimeSeries5Min: Codable {
    let open, high, low, close: String
    let volume: String

    enum CodingKeys: String, CodingKey {
        case open = "1. open"
        case high = "2. high"
        case low = "3. low"
        case close = "4. close"
        case volume = "5. volume"
    }
}
