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
        debugPrint(#function)
        
        if self.isModal {
            // Customize left and right bar button items
            let leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelAction))
            navigationItem.leftBarButtonItem = leftBarButtonItem
            
            let rightBarButtonItem = UIBarButtonItem(title: "Add", style: .done, target: self, action: #selector(addAction))
            navigationItem.rightBarButtonItem = rightBarButtonItem
        }
        
        self.navigationController?.navigationBar.tintColor = theme.colors.label // UIColor.white
        // load the view with existing info
        if let existingWeatherInfo = knownWeatherInfo {
            self.weatherView.updateViewWithWeather(weatherInfo: existingWeatherInfo, imageLoaderService: self.imageLoaderService, theme: self.theme)
        }
        // fetch fresh and update UI after receiving data
        
        if let validCity = city {
            weatherDetailsViewModel.loadWeatherDetails(city: validCity+",US")
        } else if let validLocation = location {
            weatherDetailsViewModel.loadWeatherDetails(latitude: validLocation.lat, longitude: validLocation.lon)
        }
        
        
        weatherDetailsViewModel.$weatherDetails
            .receive(on: DispatchQueue.main)
            .sink { [weak self] weatherInfo in
                debugPrint("FECTHED weatherInfo:\(String(describing: weatherInfo))")
                guard let sself = self else {
                    return
                }
                sself.weatherView.updateViewWithWeather(weatherInfo: weatherInfo, imageLoaderService: sself.imageLoaderService, theme: sself.theme)
                
                // update with latest details if existing
                if let nonEmptyWeatherInfo = weatherInfo {
                    sself.storage?.updateWeatherDetails(nonEmptyWeatherInfo)
                }
                    
            }.store(in: &cancellables)
        parentVC = self.presentingViewController
    }
    
    
    @objc func cancelAction() {
        dismiss(animated: true, completion: nil)
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
        dismiss(animated: true, completion: nil)
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
