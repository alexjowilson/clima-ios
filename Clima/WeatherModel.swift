//
//  WeatherModel.swift
//  Clima
//
//  Created by Alex Wilson on 10/10/25.
//  Copyright © 2025 App Brewery. All rights reserved.
//

import Foundation


struct WeatherModel{
    let conditionId: Int
    let cityName: String
    let temperature: Double
    
    var temperatureString: String{
        return String(format: "%.1f", temperature)
    }
    
    var conditionName: String {
        switch self.conditionId{
        case 200...232:
            return "cloud.bolt"
        case 300...321:
            return "cloud.drizzle"
        case 500...531:
            return "cloud.rain"
        case 600...622:
            return "cloud.snow"
        case 701...781:
            return "cloud.fog"
        case 800:
            return "cloud.bolt"
        default:
            return "cloud"
        }
    }
}
