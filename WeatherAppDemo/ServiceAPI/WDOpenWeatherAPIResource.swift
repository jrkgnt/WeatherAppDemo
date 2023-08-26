//
//  WDWeatherAPIResource.swift
//  WeatherAppDemo
//
//  Created by Ravikiran Jagarlamudi on 8/24/23.
//

import Foundation

enum WDOpenWeatherAPIResource: Codable {
    case geo(location: String)
    case reverseGeo(latitude: Double, longitude: Double)
    case weather(lat: Double, lon: Double)
    case weatherWithCity(location: String)
}

extension WDOpenWeatherAPIResource  {
    static let baseUrlString = "https://api.openweathermap.org/"
    static let baseIconUrlString = "https://openweathermap.org/"
    var url: URL {
        return self.baseUrl
            .appendingPathComponent(self.resourcePath)
            .appendingPathComponent(self.endpointPath)
    }
    
    var queryItems: [URLQueryItem] {
        return self.parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
    }
    
    //
    // MARK: - Private
    //
    
    private var baseUrl: URL {
        return URL(string: Self.baseUrlString)!
    }
    
    
    private var resourcePath: String {
        switch self {
        case .geo, .reverseGeo:
            return "geo/1.0"
            
        case .weather, .weatherWithCity:
            return "data/2.5"
        }
    }
    
    private var endpointPath: String {
        switch self {
        case .geo:
            return "direct"
            
        case .reverseGeo:
            return "reverse"
            
        case .weather, .weatherWithCity:
            return "weather"
        }
    }
    
    private var parameters: [String: String] {
        var params: [String: String]
        
        switch self {
        case .geo(let location):
            params = ["q": location, "limit": "5"]
        case .weatherWithCity(let location):
            params = ["q": location, "units":"imperial"]
        case .reverseGeo(let lat, let lon):
            let lat: String = lat.format(".4")
            let lon: String = lon.format(".4")
            params = ["lat": lat, "lon": lon, "limit": "5"]
        case .weather(let lat, let lon):
            let lat: String = lat.format(".4")
            let lon: String = lon.format(".4")
            params = ["lat": lat, "lon": lon, "units": "imperial"]
        }
        
        // TODO: typically credentials & configs should be set at the service level (i.e WDWeatherLoadingService); refactor later
        params["appid"] = WDAPISecrets.apiKey
        
        // Set language
        if let lang = Locale.current.languageCode {
            params["lang"] = lang.lowercased()
        }
        
        return params
    }
    
    
}
