//
//  WDWeatherRequest.swift
//  WeatherAppDemo
//
//  Created by Ravikiran Jagarlamudi on 8/24/23.
//

import Foundation


typealias WDWeatherResponseJSONParser = WDHTTPJSONParser<WDWeatherResponseModel>
typealias WDWeatherResponseModel = WDWeather

extension WDWeatherResponseModel : WDHTTPResponse {
}

struct WDWeatherRequest: WDHTTPRequest, Encodable {
    
    typealias ResponseParserType = WDWeatherResponseJSONParser
    
    public var headers: [String: String]
    public var queryParameters: [URLQueryItem]
    public var method: WDHTTPMethod
    public var requestURL: URL
    
    private let apiResource: WDOpenWeatherAPIResource
    
    init(lat: Double, lon: Double) {
        apiResource = WDOpenWeatherAPIResource.weather(lat: lat, lon: lon)
        self.method = WDHTTPMethod.get
        self.requestURL = apiResource.url        
        self.headers = [:]
        self.queryParameters = apiResource.queryItems
    }
    
    init(city: String) {
        apiResource = WDOpenWeatherAPIResource.weatherWithCity(location: city)
        self.method = WDHTTPMethod.get
        self.requestURL = apiResource.url
        self.headers = [:]
        self.queryParameters = apiResource.queryItems
    }
    
    var request: URLRequest? {
        
        if var comps = URLComponents(string: self.requestURL.absoluteString) {
            comps.queryItems = self.queryParameters

            if let url = comps.url {
                var request: URLRequest = URLRequest(url: url)
                request.httpMethod = method.rawValue
                return request
            }
        }
        return nil
    }
}
