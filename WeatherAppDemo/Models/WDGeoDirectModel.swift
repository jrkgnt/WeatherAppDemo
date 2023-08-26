//
//  WDGeoDirectModel.swift
//  WeatherAppDemo
//
//  Created by Ravikiran Jagarlamudi on 8/24/23.
//

import Foundation

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let wDGeoDirectModel = try? JSONDecoder().decode(WDGeoDirectModel.self, from: jsonData)

import Foundation

// MARK: - WDGeoDirectModelElement
struct WDGeoDirectModelElement: Codable {
    let name: String?
    let localNames: [String: String]?
    let lat, lon: Double
    let country, state: String?

    enum CodingKeys: String, CodingKey {
        case name
        case localNames = "local_names"
        case lat, lon, country, state
    }
}

typealias WDGeoDirectModel = [WDGeoDirectModelElement]
