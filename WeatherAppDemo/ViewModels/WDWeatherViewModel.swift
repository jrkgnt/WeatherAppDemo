//
//  WDWeatherViewModel.swift
//  WeatherAppDemo
//
//  Created by Ravikiran Jagarlamudi on 8/25/23.
//

import Foundation

import Combine
import MapKit


// Represents section view model in filtered cities list view
struct WDCityWeatherSectionViewModel: Hashable {
    let items: [WDWeatherViewModel]
}

extension WDWeatherViewModel: Hashable {
    static func == (lhs: WDWeatherViewModel, rhs: WDWeatherViewModel) -> Bool {
        lhs.weatherDetails?.coord == rhs.weatherDetails?.coord
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(weatherDetails?.coord)
    }
}

class WDWeatherViewModel: ObservableObject {
    
    private var service: WDWeatherLoadingService? = nil
    
    @Published var weatherDetails: WDWeather?
    
    init(weatherDetails: WDWeather? = nil, service: WDWeatherLoadingService? = nil) {
        self.service = service ?? WDWeatherLoadingService()
        self.weatherDetails = weatherDetails
    }
    
    func loadWeatherDetails(city: String) {
        self.service?.loadWeather(city: city, onComplete: { [weak self]  result in
            switch result {
            case .success(let weatherModel):
                debugPrint(weatherModel)
                self?.weatherDetails = weatherModel
            case .failure(let error):
                debugPrint(error)
            }
        })
    }
    
    func loadWeatherDetails(latitude: Double, longitude: Double) {
        self.service?.loadWeather(latitude: 37.5299316, longitude: -121.9690171, onComplete: {[weak self]  result in
            switch result {
            case .success(let weatherModel):
                debugPrint("FROM LAT LONG: \(weatherModel)")
                self?.weatherDetails = weatherModel
            case .failure(let error):
                debugPrint(error)
            }
        })
    }
    
    
}


