//
//  WDAPISecrets.swift
//  WeatherAppDemo
//
//  Created by Ravikiran Jagarlamudi on 8/24/23.
//

import Foundation

// TODO: save in keychain
enum WDAPISecrets {
    private static let _apiKey: String = "ab986f9f25ef6d98085716e75fce4a9c"
    
    static let apiKey: String = {
        assert(WDAPISecrets._apiKey.isEmpty == false, "Set your API key")
        
        return WDAPISecrets._apiKey
    }()
}
