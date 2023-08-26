//
//  WDAppTheme.swift
//  WeatherAppDemo
//
//  Created by Ravikiran Jagarlamudi on 8/26/23.
//

import Foundation
import UIKit

public protocol WDTheme {
    var colors: WDThemeColors { get }
    var tempColors: WDTemperatureColors { get }
}

public protocol WDThemeColors {
    var background: UIColor { get }
    var secondaryBackground: UIColor { get }
    
    var label: UIColor { get }
    var secondaryLabel: UIColor { get }
    
    var shadow: UIColor { get }
}


public struct WDAppTheme: WDTheme {
    public let colors: WDThemeColors = WDAppColors()
    public let tempColors: WDTemperatureColors = WDAppTemperatureColors()

    public init() { }
}

public struct WDAppColors: WDThemeColors {
    // TODO: based on trait.userInterfaceStyle
    public let background: UIColor = UIColor(rgb: 0xFFF2E7)
    
    public let secondaryBackground: UIColor = UIColor(rgb: 0xFFF6EE)
    
    public let label: UIColor =  UIColor.white //UIColor(rgb: 0x735D4A)
    
    public let secondaryLabel: UIColor = UIColor.white  //UIColor(rgb: 0xC0AF9F)
    
    public let shadow: UIColor = UIColor(rgb: 0x3A1B00)
    
}


public protocol WDTemperatureColors {
    /// 40°C and above
    var superHot: UIColor { get }
    
    /// 30°C and above
    var hot: UIColor { get }
    
    /// 20°C and above
    var warm: UIColor { get }
    
    /// 10°C and above
    var neutral: UIColor { get }
    
    /// 0°C and above
    var zero: UIColor { get }
    
    /// -10°C and above
    var cold: UIColor { get }
    
    /// Below -25°C
    var superCold: UIColor { get }
}

extension WDTemperatureColors {
    func colorFor(tempInFarenhiet: Int) -> UIColor {
        let temp = (tempInFarenhiet - 32) * 5/9
        switch temp {
        case _ where temp < -25:
            return self.superCold
        case (-25)..<(-10):
            return self.cold
        case -10..<0:
            return self.zero
        case 0..<10:
            return self.neutral
        case 10..<30:
            return self.warm
        case 30..<40:
            return self.hot
        case 40..<Int.max:
            return self.superHot
        default:
            return self.neutral
        }
    }
}

public struct WDAppTemperatureColors: WDTemperatureColors {
    public let superHot: UIColor = UIColor(rgb: 0xE85E5E)
    public let hot: UIColor = UIColor(rgb: 0xE4A80C)
    public let warm: UIColor = UIColor(rgb: 0x4DB958)
    public let neutral: UIColor = UIColor(rgb: 0x78B199)
    public let zero: UIColor = UIColor(rgb: 0x39B4DB)
    public let cold: UIColor =  UIColor(rgb: 0x4696F5)
    public let superCold: UIColor = UIColor(rgb: 0x6764E7)
}
