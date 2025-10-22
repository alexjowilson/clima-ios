//
//  ViewController.swift
//  Clima
//
//  Created by Angela Yu on 01/09/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreLocation


class WeatherViewController: UIViewController{

    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var updateLocation: UIButton!
    
    var weatherManager = WeatherManager()
    let locationManager = CLLocationManager()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        

        weatherManager.delegate = self
        searchTextField.delegate = self
        
    }
    
    @IBAction func updateLocationPressed(_ sender: UIButton) {
        print("inside updateLocationPressed()")
        sender.isEnabled = false
        locationManager.requestLocation()
    }
}


// MARK: - UITextFieldDelegate
extension WeatherViewController: UITextFieldDelegate{
    @IBAction func searchPressed(_ sender: UIButton) {
        print("inside searchPressed()")
        searchTextField.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("inside textFieldShouldReturn()")
        searchTextField.endEditing(true)
    
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        print("inside textFieldShouldEndEditing()")
        if textField.text != ""{
                return true
        }
        else{
            textField.placeholder = "Type something"
            return false
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("inside textFieldDidEndEditing()")
        print("The user is done entering text")
        print("The user entered: " + searchTextField.text!)
        
        if let city = searchTextField.text{
            weatherManager.fetchWeather(cityName: city)
            print("city = " + city)
        }
        
        searchTextField.text = ""
    }
}

// MARK: - WeatherManagerDelegate
extension WeatherViewController: WeatherManagerDelegate{
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel){
        print("inside didUpdateWeather()")
        print("About to update the temperature Label")
        
        DispatchQueue.main.async {
            //update the temperature
            self.temperatureLabel.text = weather.temperatureString
            print(weather.temperature)
            
            // update the weather icon
            self.conditionImageView.image = UIImage(systemName: weather.conditionName)
            
            // update city name
            self.cityLabel.text = weather.cityName
        }
    }
    
    func didFailWithError(error: Error){
        print("inside didFailWithError()")
        
        print(error)
    }
}

// MARK: - CLLocationManagerDelegate
extension WeatherViewController: CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Inside WeatheViewController CLLocationManagerDelegate, didUpdateLocations()")
        print("Got location data")
         // You can access the most recent location:
         if let location = locations.last {
             locationManager.stopUpdatingLocation()
             let lat = location.coordinate.latitude
             let lon = location.coordinate.longitude
             print("Latitude: \(lat), Longitude: \(lon)")
             weatherManager.fetchWeather(latitude: lat, longitude: lon)
             
             DispatchQueue.main.async {
                 self.updateLocation.isEnabled = true
             }
         }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        print("Inside WeatheViewController CLLocationManagerDelegate, didFailWithError()")
        print("There is an error")
        print(error)
        DispatchQueue.main.async {
            self.updateLocation.isEnabled = true
        }
    }
}

