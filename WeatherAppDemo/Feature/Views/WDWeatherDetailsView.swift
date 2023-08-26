//
//  WDWeatherDetailsView.swift
//  WeatherAppDemo
//
//  Created by Ravikiran Jagarlamudi on 8/25/23.
//

import Foundation
import UIKit


// PICKED UP LAYOUT FROM https://github.com/jrasmusson/swift-arcade/blob/master/Weathery/Weathery/WeatherViewController.swift

private struct LocalSpacing {
    static let buttonSizeSmall = CGFloat(44)
    static let buttonSizelarge = CGFloat(120)
}


class WDWeatherDetailsView: UIView {
    
    let rootStackView = UIStackView()
    
    // search
    let searchStackView = UIStackView()
    
    // weather
    let conditionImageView = UIImageView()
    let temperatureLabel = UILabel()
    let cityLabel = UILabel()
    let descriptionLabel = UILabel()
    
    // background
    let backgroundView = UIImageView()
    
    var iconURL: String?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        createSubviews()
    }
    
    func updateViewWithWeather(weatherInfo: WDWeather?, imageLoaderService: WDImageLoaderServiceable, theme: WDTheme? = nil) {
        cityLabel.text = weatherInfo?.name ?? "---------"
        cityLabel.textColor = theme?.colors.secondaryLabel
        
        
        descriptionLabel.text = weatherInfo?.weather.first?.description ?? (weatherInfo?.weather.first?.main ?? "------" )
        descriptionLabel.textColor = theme?.colors.secondaryLabel
        
        temperatureLabel.attributedText = makeTemperatureText(with: "--", theme: theme)
        if let validTemp = weatherInfo?.main?.temp {
            let tempToDisplay = Int(validTemp)
            temperatureLabel.attributedText = makeTemperatureText(with: String(tempToDisplay), theme: theme)
        }
        // cancel old image fetch if needed & fetch image from weather iconURL
        
        conditionImageView.image = nil
        if let oldIconURL = self.iconURL {
            imageLoaderService.cancelFetch(urlString: oldIconURL)
            self.iconURL = nil
        }
        
        if let weatherIconURL = weatherInfo?.weather.first?.iconURLString {
            self.iconURL = weatherIconURL
            imageLoaderService.fetchImage(urlString: weatherIconURL) { [weak self] image in
                DispatchQueue.main.async {
                    self?.conditionImageView.image = image
                }
            }?.resume()
        }
    }
    
    func createSubviews() {
        // all the style & layout code
        style()
        layout()
    }
    
    func style() {
        rootStackView.translatesAutoresizingMaskIntoConstraints = false
        rootStackView.axis = .vertical
        rootStackView.alignment = .trailing
        rootStackView.spacing = 10
        
        // search
        searchStackView.translatesAutoresizingMaskIntoConstraints = false
        searchStackView.spacing = 8
        
        // weather
        conditionImageView.translatesAutoresizingMaskIntoConstraints = false
        conditionImageView.image = UIImage(systemName: "sun.max")
        conditionImageView.tintColor = .label
        
        temperatureLabel.translatesAutoresizingMaskIntoConstraints = false
        temperatureLabel.font = UIFont.systemFont(ofSize: 80)
        temperatureLabel.attributedText = makeTemperatureText(with: "75")
        
        cityLabel.translatesAutoresizingMaskIntoConstraints = false
        cityLabel.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        cityLabel.text = "Cupertino"
        
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.font = UIFont.preferredFont(forTextStyle: .title2)
        descriptionLabel.text = ""
        
        // background
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.image = UIImage(named: "sunny")
        backgroundView.contentMode = .scaleAspectFill
    }
    
    
    private func makeTemperatureText(with temperature: String, theme: WDTheme? = nil) -> NSAttributedString {
        
        var boldTextAttributes = [NSAttributedString.Key: AnyObject]()
        boldTextAttributes[.foregroundColor] = theme?.colors.label ?? UIColor.label
        boldTextAttributes[.font] = UIFont.boldSystemFont(ofSize: 100)
        
        var plainTextAttributes = [NSAttributedString.Key: AnyObject]()
        plainTextAttributes[.font] = UIFont.systemFont(ofSize: 80)
        plainTextAttributes[.foregroundColor] = theme?.colors.label ?? UIColor.label
        
        let text = NSMutableAttributedString(string: temperature, attributes: boldTextAttributes)
        text.append(NSAttributedString(string: "°F", attributes: plainTextAttributes))
        
        return text
    }
    
    func layout() {
        rootStackView.addArrangedSubview(searchStackView)
        rootStackView.addArrangedSubview(conditionImageView)
        rootStackView.addArrangedSubview(temperatureLabel)
        rootStackView.addArrangedSubview(cityLabel)
        rootStackView.addArrangedSubview(descriptionLabel)
        
        self.addSubview(backgroundView)
        self.addSubview(rootStackView)
        
        NSLayoutConstraint.activate([
            rootStackView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
            rootStackView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.leadingAnchor, multiplier: 1),
            self.trailingAnchor.constraint(equalToSystemSpacingAfter: rootStackView.trailingAnchor, multiplier: 1),
            
            searchStackView.leadingAnchor.constraint(equalTo: rootStackView.leadingAnchor),
            conditionImageView.heightAnchor.constraint(equalToConstant: LocalSpacing.buttonSizelarge),
            conditionImageView.widthAnchor.constraint(equalToConstant: LocalSpacing.buttonSizelarge),
            
            backgroundView.topAnchor.constraint(equalTo: self.topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
    }
}
