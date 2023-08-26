//
//  Numbers+Formt.swift
//  WeatherAppDemo
//
//  Created by Ravikiran Jagarlamudi on 8/24/23.
//

import Foundation

public extension Int {
    
    func format(_ f: String) -> String {
        return String(format: "%\(f)d", self)
    }
    
}

public extension Double {
    
    func format(_ f: String, dropZero: Bool = false) -> String {
        let value = String(format: "%\(f)f", self)
        if dropZero && value.starts(with: "0.") {
            return String(value[value.index(after: value.startIndex)..<value.endIndex])
        }
        return value
    }
    
    
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
    
}

public extension Float {
    
    func format(_ f: String, dropZero: Bool = false) -> String {
        let value = String(format: "%\(f)f", self)
        if dropZero && value.starts(with: "0.") {
            return String(value[value.index(after: value.startIndex)..<value.endIndex])
        }
        return value
    }
    
}
