//
//  WDWeatherService.swift
//  WeatherAppDemo
//
//  Created by Ravikiran Jagarlamudi on 8/24/23.
//

import Foundation

// https://openweathermap.org/api/statistics-api#:~:text=The%20frequency%20of%20data%20update%20is%201%20hour.

//TOOD: Try using URLCached response as mentioned here https://stackoverflow.com/questions/19855280/how-to-set-nsurlrequest-cache-expiration

typealias WDWeatherServiceCompletionHandler = (Result<WDWeather, Error>) -> Void
protocol WDWeatherLoading {
    func loadWeather(latitude: Double, longitude: Double, onComplete: @escaping WDWeatherServiceCompletionHandler, callbackQueue: DispatchQueue?)
    func loadWeather(city: String, onComplete: @escaping WDWeatherServiceCompletionHandler, callbackQueue: DispatchQueue?)
}


class WDWeatherLoadingService: WDWeatherLoading {
    private let httpClient: WDHTTPClient
    private let serviceQueue: DispatchQueue = DispatchQueue(label: "com.ravi.personal.WeatherAppDemo.servicequeue")
    
    init() {
        self.httpClient = WDHTTPClient()
    }
    
    func loadWeather(latitude: Double, longitude: Double, onComplete: @escaping WDWeatherServiceCompletionHandler, callbackQueue: DispatchQueue?=nil) {
        let request = WDWeatherRequest(lat: latitude, lon: longitude)
        
        serviceQueue.async { [weak self] in
            self?.httpClient.perform(request) { result in
                guard let sself = self else {
                    onComplete(.failure(WDCustomError.custom(code: 5100, message: "UNEXPECTED RELEASE OF SELF")))
                    return
                }
                let validCallBackQueue = callbackQueue ?? sself.serviceQueue
                validCallBackQueue.async {
                    switch result {
                    case .success(let weatherModel):
                        onComplete(.success(weatherModel))
                    case .failure(let error):
                        onComplete(.failure(error))
                        debugPrint(error)
                    }
                }
            }
        }
        
    }
    
    func loadWeather(city: String, onComplete: @escaping WDWeatherServiceCompletionHandler, callbackQueue: DispatchQueue?=nil) {
        let request = WDWeatherRequest(city: city)
        serviceQueue.async {[weak self] in
            self?.httpClient.perform(request) { result in
                guard let sself = self else {
                    onComplete(.failure(WDCustomError.custom(code: 5100, message: "UNEXPECTED RELEASE OF SELF")))
                    return
                }
                let validCallBackQueue = callbackQueue ?? sself.serviceQueue
                validCallBackQueue.async {
                    switch result {
                    case .success(let weatherModel):
                        onComplete(.success(weatherModel))
                    case .failure(let error):
                        onComplete(.failure(error))
                        debugPrint(error)
                    }
                }
            }
        }
        
    }
    
}





