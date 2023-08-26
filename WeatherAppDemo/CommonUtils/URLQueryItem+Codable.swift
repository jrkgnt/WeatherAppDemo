//
//  URLQueryItem+Codable.swift
//  WeatherAppDemo
//
//  Created by Ravikiran Jagarlamudi on 8/24/23.
//

import Foundation

extension URLQueryItem: Codable {
    enum CodingKeys: String, CodingKey {
        case keyValue
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode([self.name : self.value], forKey: .keyValue)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let dict = try container.decode([String:String].self, forKey: .keyValue)
        let key = dict.keys.first ?? ""
        self = URLQueryItem(name: key, value: dict[key])
    }
}
