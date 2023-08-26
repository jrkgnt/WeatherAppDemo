//
//  WDWeatherSearchCollectionViewCell.swift
//  WeatherAppDemo
//
//  Created by Ravikiran Jagarlamudi on 8/26/23.
//

import Foundation
import UIKit


class WDWeatherSearchCollectionViewCell: UICollectionViewCell {
    @IBOutlet  var cityLabel: UILabel!
    @IBOutlet  var descLabel: UILabel!
    @IBOutlet  var tempLabel: UILabel!
    
    var cornerRadius: CGFloat = 7.0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Apply rounded corners to contentView
        contentView.layer.cornerRadius = cornerRadius
        contentView.layer.masksToBounds = true
        
        // Set masks to bounds to false to avoid the shadow
        // from being clipped to the corner radius
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = false
        
        // Apply a shadow
        layer.shadowRadius = 8.0
        layer.shadowOpacity = 0.10
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 5)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Improve scrolling performance with an explicit shadowPath
        layer.shadowPath = UIBezierPath(
            roundedRect: bounds,
            cornerRadius: cornerRadius
        ).cgPath
    }
    
    func updateTemperature(temperature: String, theme: WDTheme? = nil) {
        tempLabel.attributedText = makeTemperatureText(with: temperature, theme: theme)
        let backgroundColor = theme?.tempColors.colorFor(tempInFarenhiet: Int(temperature) ?? 20) ?? UIColor.systemGroupedBackground
        self.contentView.backgroundColor = backgroundColor
    }
    
    private func makeTemperatureText(with temperature: String, theme: WDTheme? = nil) -> NSAttributedString {
        
        var boldTextAttributes = [NSAttributedString.Key: AnyObject]()
        boldTextAttributes[.foregroundColor] = theme?.colors.label ?? UIColor.label
        boldTextAttributes[.font] = UIFont.boldSystemFont(ofSize: 50)
        
        var plainTextAttributes = [NSAttributedString.Key: AnyObject]()
        plainTextAttributes[.font] = UIFont.systemFont(ofSize: 40)
        plainTextAttributes[.foregroundColor] = theme?.colors.label ?? UIColor.label
        
        let text = NSMutableAttributedString(string: temperature, attributes: boldTextAttributes)
        text.append(NSAttributedString(string: "°F", attributes: plainTextAttributes))
        
        return text
    }
    
}


