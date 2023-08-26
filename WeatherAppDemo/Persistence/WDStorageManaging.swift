//
//  WDStorageManaging.swift
//  WeatherAppDemo
//
//  Created by Ravikiran Jagarlamudi on 8/24/23.
//

import Foundation

protocol WDStorageManaging {
    func saveLocationWeather(_ weather: WDWeather) -> Result<Void, Error>
    func loadLastSavedLocationWeather() -> Result<WDWeather, Error>
    func loadListOfSavedWeathers() -> [WDWeather]
    func updateWeatherDetails(_ weather: WDWeather) -> Result<Void, Error>
}


// relying on NSUserDefaults as data is small;


public extension UserDefaults {
    @objc dynamic var weatherList: Any? {
        get{
            self.object(forKey: "weather_list")
        }
        set{
            set(newValue, forKey: "weather_list")
        }
    }
}

// TODO: NOTE: implementation detail of saving the list in speciifc order and always retriving the first item is hard coded;
class WDUserDefaultsPersistence: WDStorageManaging {
    
    func loadLastSavedLocationWeather() -> Result<WDWeather, Error> {
        let savedList = loadListOfSavedWeathers()
        if  let firstItem = savedList.first  {
            return .success(firstItem)
        }
        return .failure(WDCustomError.custom(code: WDCustomErrorCodes.persistenceFailure.rawValue, message: "No items in defaults"))
    }
    
    func loadListOfSavedWeathers() -> [WDWeather] {
        let defaults = UserDefaults.standard
        if let savedList = defaults.weatherList as? Data {
            let decoder = JSONDecoder()
            if let loadedList = try? decoder.decode([WDWeather].self, from: savedList) {
                return loadedList
            }
        }
        
        return []
    }
    
    func saveLocationWeather(_ weather: WDWeather) -> Result<Void, Error> {
        
        var existingList = loadListOfSavedWeathers()
        // update existing list if needed or append
        if existingList.contains(weather), let idx = existingList.firstIndex(of: weather) {
            // update
            existingList[idx] = weather
        } else {
            existingList = [weather] + existingList
        }
        
        // save the updated existing list
        return writeToDisk(existingList: existingList)
    }
    
    
    func updateWeatherDetails(_ weather: WDWeather) -> Result<Void, Error> {
        var existingList = loadListOfSavedWeathers()
        // update existing list
        if existingList.contains(weather), let idx = existingList.firstIndex(of: weather) {
            // delete and it will be moved to first
            existingList[idx] = weather
        }
        
        return writeToDisk(existingList: existingList)
    }
    
    private func writeToDisk(existingList: [WDWeather]) -> Result<Void, Error> {
        // save the updated existing list
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(existingList) {
            let defaults = UserDefaults.standard
            defaults.weatherList = encoded
        } else {
            return .failure(WDCustomError.custom(code: WDCustomErrorCodes.persistenceFailure.rawValue, message: "Can't persist to defaults"))
        }
        
        return .success(())
    }
    
}
