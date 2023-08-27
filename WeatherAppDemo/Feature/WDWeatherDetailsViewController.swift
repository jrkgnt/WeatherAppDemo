//
//  WDWeatherDetailsViewController.swift
//  WeatherAppDemo
//
//  Created by Ravikiran Jagarlamudi on 8/25/23.
//

import Foundation
import Combine
import UIKit

enum WDWeatherDetailsFetchType {
    case city(String)
    case location(WDWeather.Coord)
}

class WDWeatherDetailsViewController: UIViewController {
    
    let weatherDetailsViewModel = WDWeatherViewModel()
    let imageLoaderService =  WDImageLoaderService()
    let theme: WDTheme = WDAppTheme()
    var weatherView = WDWeatherDetailsView()
    var parentVC: UIViewController?
    
    var knownWeatherInfo:WDWeather? = nil
    var onPresentationDismissBlock: ((Bool) -> Void)?
    
    var cancellables = Set<AnyCancellable>()
    
    private let city: String?
    private let location: WDWeather.Coord?
    
    private let storage: WDStorageManaging?
    init(place: WDWeatherDetailsFetchType, knownWeatherInfo: WDWeather? = nil ,storage: WDStorageManaging? = nil ) {
        
        if case .city(let city) = place {
            self.city = city
        } else {
            self.city = nil
        }
        
        if case .location(let coord) = place {
            self.location = coord
        } else {
            self.location = nil
        }
        
        self.storage = storage ?? WDUserDefaultsPersistence()
        self.knownWeatherInfo = knownWeatherInfo
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = weatherView
    }
    
    override func viewDidLoad() {
        self.customizeNavBar()
        
        // load the view with existing info
        if let existingWeatherInfo = knownWeatherInfo {
            self.weatherView.updateViewWithWeather(weatherInfo: existingWeatherInfo, imageLoaderService: self.imageLoaderService, theme: self.theme)
        }
        // fetch and update UI
        if let validCity = city {
            weatherDetailsViewModel.loadWeatherDetails(city: validCity+",US")
        } else if let validLocation = location {
            weatherDetailsViewModel.loadWeatherDetails(latitude: validLocation.lat, longitude: validLocation.lon)
        }
        
        weatherDetailsViewModel.$weatherDetails
            .receive(on: DispatchQueue.main)
            .sink { [weak self] weatherInfo in
                debugPrint("UPDATED $weatherDetails:\(String(describing: weatherInfo))")
                guard let sself = self, weatherInfo != nil else {
                    return
                }
                sself.weatherView.updateViewWithWeather(weatherInfo: weatherInfo, imageLoaderService: sself.imageLoaderService, theme: sself.theme)
                
                // update with latest details if existing
                if let nonEmptyWeatherInfo = weatherInfo {
                    _ = sself.storage?.updateWeatherDetails(nonEmptyWeatherInfo)
                }
                
            }.store(in: &cancellables)
        parentVC = self.presentingViewController
       
    }
    
    
    func customizeNavBar() {
        guard self.isModal else {
            return
        }
        var shouldShowAddOption = false
        let listOfSavedWeatherInfo = self.storage?.loadListOfSavedWeathers() ?? []
        if let validCity = city {
            // look for this city in saved list
            let haveCityWeatherInfo = listOfSavedWeatherInfo.contains { weatherInfo in
                let cityNameWithoutState = String(validCity.split(separator: ",").first ?? "")
                return weatherInfo.name == validCity || cityNameWithoutState == weatherInfo.name
            }
            shouldShowAddOption = !haveCityWeatherInfo
        } else if let validLocation = location {
            // look for this coordinates in saved list
            let haveCityWeatherInfo = listOfSavedWeatherInfo.contains { weatherInfo in
                let sameLon = weatherInfo.coord?.lon.rounded(toPlaces: 4) == validLocation.lon.rounded(toPlaces: 4)
                let sameLat = weatherInfo.coord?.lat.rounded(toPlaces: 4) == validLocation.lat.rounded(toPlaces: 4)
                return sameLon && sameLat
            }
            shouldShowAddOption = !haveCityWeatherInfo
        }
        
        // Customize left and right bar button items
        let leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelAction))
        navigationItem.leftBarButtonItem = leftBarButtonItem
        if shouldShowAddOption {
            let rightBarButtonItem = UIBarButtonItem(title: "Add", style: .done, target: self, action: #selector(addAction))
            navigationItem.rightBarButtonItem = rightBarButtonItem
        }
        self.navigationController?.navigationBar.tintColor = theme.colors.label // UIColor.white
    }
    
    
    @objc func cancelAction() {
        DispatchQueue.main.async { [weak self] in
            self?.dismiss(animated: true, completion: nil)
            self?.onPresentationDismissBlock?(true)
        }
    }
    
    @objc func backAction() {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func addAction() {
        // save it to list
        if let weatherInfo = weatherDetailsViewModel.weatherDetails {
            let result = storage?.saveLocationWeather(weatherInfo)
            switch result {
            case .success(_):
                showAlert(with: " \(String(describing: weatherInfo.name)) succcessfully saved, tap on it to view more details", title: "Saved")
                break
            case .failure(let err):
                if case WDCustomError.custom(let code , let message) = err  {
                    showAlert(with: message, title: "Error-\(code)")
                }
                break
            case .none:
                break
            }
        }
        DispatchQueue.main.async { [weak self] in
            self?.dismiss(animated: true, completion: nil)
            self?.onPresentationDismissBlock?(true)
        }
        
    }
    
    
    func showAlert(with message: String, title: String) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        parentVC?.present(alert, animated: true, completion: nil)
    }
    
    deinit {
        debugPrint(#function)
    }
    
}
