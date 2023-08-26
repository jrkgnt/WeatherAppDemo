//
//  WDGeoRequest.swift
//  WeatherAppDemo
//
//  Created by Ravikiran Jagarlamudi on 8/24/23.
//

import Foundation

typealias WDGeoResponseJSONParser = WDHTTPJSONParser<WDWeatherResponseModel>
typealias WDGeoResponseModel = WDGeoDirectModel


struct WDGeoRequest: WDHTTPRequest, Encodable {

    typealias ResponseParserType = WDGeoResponseJSONParser

    public var headers: [String: String] {
        get {
            return [:]
        }
        set {
            
        }
    }
    public var queryParameters: [URLQueryItem] {
        apiResource.queryItems
        
    }
    public var method: WDHTTPMethod {
        WDHTTPMethod.get
    }
    public var requestURL: URL {
        apiResource.url
    }

    private let apiResource: WDOpenWeatherAPIResource

    init(location: String) {
        apiResource = WDOpenWeatherAPIResource.geo(location: location)
    }

    public var request: URLRequest? {

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
