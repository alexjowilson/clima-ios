//
//  WeatherManager.swift
//  Clima
//
//  Created by Alex Wilson on 10/8/25.
//  Copyright © 2025 App Brewery. All rights reserved.
//

import Foundation
import _LocationEssentials

protocol WeatherManagerDelegate{
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
}

struct WeatherManager{
    
    // Read from Info.plist → "OpenWeatherAPIKey" (set via xcconfig)
    private var apiKey: String {
        let key = Bundle.main.object(forInfoDictionaryKey: "OpenWeatherAPIKey") as? String ?? ""
        // print("Loaded OpenWeatherAPIKey from Info.plist =", key.isEmpty ? "<EMPTY>" : "<REDACTED>")
        return key
    }
    private let base = URL(string: "https://api.openweathermap.org/data/2.5/weather")!
    var delegate: WeatherManagerDelegate?
    
    
    func fetchWeather(cityName: String){
        print("inside fetchWeather() city")
        var comps = URLComponents(url: base, resolvingAgainstBaseURL: false)!
        comps.queryItems = [
            URLQueryItem(name: "appid", value: apiKey),
            URLQueryItem(name: "units", value: "imperial"),
            URLQueryItem(name: "q", value: cityName) // URLComponents will encode spaces, etc.
        ]
        guard let url = comps.url else { return }
        print("urlString = \(url.absoluteString)")
        print("About to performRequest")
        performRequest(with: url.absoluteString)
        
    }
    
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees){
        print("inside fetchWeather() lat,long")

        var comps = URLComponents(url: base, resolvingAgainstBaseURL: false)!
        comps.queryItems = [
            URLQueryItem(name: "appid", value: apiKey),
            URLQueryItem(name: "units", value: "imperial"),
            URLQueryItem(name: "lat", value: String(latitude)),
            URLQueryItem(name: "lon", value: String(longitude))
        ]
        guard let url = comps.url else { return }
        print("urlString = \(url.absoluteString)")
        print("About to performRequest")
        performRequest(with: url.absoluteString)
    }
    
    func performRequest(with urlString: String){
        print("Inside of performRequest()")
        
        // 1. Create the URL
        if let url = URL(string: urlString){
            // 2. Create a URLSession
            let session = URLSession(configuration: .default)
            // 3. Give the session a task
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil{
                    print("There is an error")
                    print("About to call didFailWithError() from performRequest() from WeatherManager")
                    self.delegate?.didFailWithError(error: error!)
                }
                if let safeData = data {
                    print("Got some data back from the API")
                    let dataString = String(data: safeData, encoding: .utf8)
                    print(dataString!)
                    // parse the JSON
                    if let weather = self.parseJSON(safeData){
                        self.delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
            }
            
            // 4. Start the task
            task.resume()
        }
    }
    
    func parseJSON(_ weatherData: Data) -> WeatherModel? {
        print("inside parseJSON()")
        let decoder = JSONDecoder()
        do{
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let name = decodedData.name
            let temp = decodedData.main.temp
            let id = decodedData.weather[0].id
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
            print(weather.conditionName)
            print("The current temp = " + weather.temperatureString)
        
            return weather
            
        }catch{
            print("There is in error in parseJSON()")
            print("About to call didFailWithError() from parseJSON from WeatherManager")
            
            self.delegate?.didFailWithError(error: error)
            
            return nil
        }
    }
}
