//
//  WDWeatherModel.swift
//  WeatherAppDemo
//
//  Created by Ravikiran Jagarlamudi on 8/24/23.
//

import Foundation

// https://app.quicktype.io/
// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let weather = try? JSONDecoder().decode(Weather.self, from: jsonData)


// https://openweathermap.org/current#fields_json
// https://openweathermap.org/weather-conditions

import Foundation

// MARK: - Weather

extension WDWeather: Hashable {
    static func == (lhs: WDWeather, rhs: WDWeather) -> Bool {
        lhs.coord == rhs.coord 
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(coord)
    }
}

struct WDWeather: Codable {
    
    let coord: Coord?
    let weather: [WeatherElement]
    let base: String?
    let main: Main?
    let visibility: Int?
    let wind: Wind?
    let clouds: Clouds?
    let dt: Int?
    let sys: Sys?
    let timezone, id: Int?
    let name: String?
    let cod: Int?
    let rain: Rain?
    let snow: Snow?
    
    // https://openweathermap.org/weather-conditions
    enum Condition {
        /// Code group 2xx
        case thunderstorm
        
        /// Code group 3xx
        case drizzle
        
        /// Code 500
        case lightRain
        
        /// Code group 501 - 504
        case rain
        
        /// Code group 520 - 522 + 531
        case showerRain
        
        /// Codes 302, 312, 314, 502 - 504, 522
        case heavyRain
        
        /// Code 511
        case freezingRain
        
        /// Codes 602, 621, 622
        case snow
        
        /// Codes 600, 601, 611, 612, 613, 615, 616, 620
        case lightSnow
        
        /// Code group 7xx
        case atmosphere
        
        /// Code 800
        case clear
        
        /// Code 801
        case fewClouds
        
        /// Code 802
        case scatteredClouds
        
        /// Code group 803 - 804
        case clouds
    }
    
    
    // MARK: - Rain
    struct Rain: Codable {
        let rain1h: Int?  //(where available) Rain volume for the last 1 hour, mm.
        let rain3h: Int?  //(where available) Rain volume for the last 3 hour, mm.
        
        enum CodingKeys: String, CodingKey {
            case rain1h = "1h"
            case rain3h = "3h"
        }
    }

    // MARK: - Snow
    struct Snow: Codable {
        let snow1h: Int?  //(where available) Rain volume for the last 1 hour, mm.
        let snow3h: Int?  //(where available) Rain volume for the last 3 hour, mm.
        enum CodingKeys: String, CodingKey {
            case snow1h = "1h"
            case snow3h = "3h"
        }
    }
    // MARK: - Clouds
    struct Clouds: Codable {
        let all: Int? // Cloudiness, %
    }

    // MARK: - Coord
    struct Coord: Codable, Hashable {
        let lon, lat: Double
    }

    // MARK: - Main
    struct Main: Codable {
        let temp, feelsLike, tempMin, tempMax: Double?
        let pressure, humidity, seaLevel, grndLevel: Int?

        enum CodingKeys: String, CodingKey {
            case temp
            case feelsLike = "feels_like"
            case tempMin = "temp_min"
            case tempMax = "temp_max"
            case pressure, humidity
            case seaLevel = "sea_level"
            case grndLevel = "grnd_level"
        }
    }

    // MARK: - Sys
    struct Sys: Codable {
        let type, id: Int
        let country: String?
        let sunrise, sunset: Int?
    }

    // MARK: - WeatherElement
    struct WeatherElement: Codable, Hashable {
        let id: Int
        let main, description, icon: String
        
        var isNight: Bool {
            icon.contains("n")
        }
        
        var iconURLString: String {
            //eg:  https://openweathermap.org/img/wn/10d@2x.png
            return WDOpenWeatherAPIResource.baseIconUrlString + "img/wn/" + icon + "@2x.png"
        }
        
        var condition: WDWeather.Condition {
            switch self.id {
            case 200...299:
                return .thunderstorm
                
            case 302, 312, 314, 502...504, 522:
                return .heavyRain
                
            case 300...399:
                return .drizzle
                
            case 500:
                return .lightRain
                
            case 501:
                return .rain
                
            case 520, 521, 531:
                return .showerRain
                
            case 511:
                return .freezingRain
                
            case 600, 601, 611, 612, 613, 615, 616, 620:
                return .lightSnow
                
            case 602, 621, 622:
                return .snow
                
            case 700...799:
                return .atmosphere
                
            case 801:
                return .fewClouds
                
            case 802:
                return .scatteredClouds
            
            case 803, 804:
                return .clouds
                
            default:
                assert(self.id == 800)
                return .clear
            }
        }
        
        
    }

    // MARK: - Wind
    struct Wind: Codable {
        let speed: Double?
        let deg: Int?
        let gust: Double?
    }
    
}


extension WDWeather {
    func backgroundImageName() -> String? {
        guard let condition = self.weather.first?.condition else {
            return "sunny"
        }
        switch condition {
        case .thunderstorm:
            return "stormy"
        case .drizzle, .lightRain, .rain, .showerRain, .heavyRain , .freezingRain :
            return "Rainy"
        case .snow, .lightSnow:
            return "snowy"
        case .atmosphere:
            return "sunny"
        case .clear:
            return "sunny"
        case .fewClouds, .scatteredClouds, .clouds:
            return "cloudy"
        }
        
    }
}
