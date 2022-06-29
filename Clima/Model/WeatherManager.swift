//
//  WeatherManager.swift
//  Clima
//
//  Created by shy attoun on 07/05/2022.

//

import Foundation
import UIKit
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
}

struct WeatherManager{
    let weatherUrl = "https://api.openweathermap.org/data/2.5/weather?lat=35&lon=139&appid=af6b24571255d4738069c4c66f0dda2f&units=metric"
    
    var delegate: WeatherManagerDelegate?
    
    func fetchWeather (cityName: String){
        let urlString = "\(weatherUrl)&q=\(cityName)"
        performRequest(with: urlString)
    }
    func fetchWeather (latitude: CLLocationDegrees,longitute: CLLocationDegrees){
        let urlString = "\(weatherUrl)&lat=\(latitude)&lon=\(longitute)"
        performRequest(with: urlString)
        
    }
    func performRequest(with urlString: String){
        //create a url
        if let url = URL(string: urlString){
            //create a url session
            let session =  URLSession(configuration: .default)
            
            //give a session a task
            let task = session.dataTask(with: url) { (data, respone, error) in
                if error != nil{
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                
                if let safeData = data {
                    if let weather = self.parseJSON(safeData){
                        self.delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
            }
            
            //start a task
            
            task.resume()
            
        }
        
    }
    func parseJSON(_ weatherData: Data) -> WeatherModel?{
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
            
            
            return weather
            
        }catch{
            delegate?.didFailWithError(error: error)
            return nil
        }
        
    }
    
}
    


