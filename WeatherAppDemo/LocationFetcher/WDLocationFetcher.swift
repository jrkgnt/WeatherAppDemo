//
//  WDLocationFetcher.swift
//  WeatherAppDemo
//
//  Created by Ravikiran Jagarlamudi on 8/26/23.
//

import Foundation
import CoreLocation
import Combine

class WDCurrentLocationFetcher: NSObject, ObservableObject {
    let locationManager = CLLocationManager()
    @Published private(set) var currentLocation: CLLocation?
    @Published private(set) var authorizationStatus: CLAuthorizationStatus?
    
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    func  requestCurrentUserLocation() {
        let status: CLAuthorizationStatus = self.locationManager.authorizationStatus
        if status == .notDetermined {
        // Ask permissions
            self.locationManager.requestWhenInUseAuthorization()
        } else {
            locationManager.requestLocation()
        }
        
    }
    
}

extension WDCurrentLocationFetcher: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        debugPrint("didUpdateLocations CURRENT LOCATION:\(locations)")
        if let location = locations.last {
            locationManager.stopUpdatingLocation()
            // Handle location update
            currentLocation = location
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    func locationManager( _ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // Handle changes if location permissions
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways, .authorizedWhenInUse:
            // do what is needed if you have access to location
            locationManager.requestLocation()
        case .denied, .restricted:
            // do what is needed if you have no access to location
            locationManager.stopUpdatingLocation()
        case .notDetermined:
            self.locationManager.requestWhenInUseAuthorization()
        @unknown default:
            // raise an error - This case should never be called
            print(" This case should never be called for didChangeAuthorization status: CLAuthorizationStatus ")
        }
        
        authorizationStatus = status
    }
}
