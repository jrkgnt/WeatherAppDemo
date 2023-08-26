//
//  WDMapSearch.swift
//  WeatherAppDemo
//
//  Created by Ravikiran Jagarlamudi on 8/25/23.
//

import Foundation


import SwiftUI
import Combine
import MapKit


// TODO: Note this is picked from stackoverflow https://stackoverflow.com/questions/33380711/how-to-implement-auto-complete-for-address-using-apple-map-kit while learning use of combine


class WDCitySearch : NSObject, ObservableObject {
    @Published var locationResults : [MKLocalSearchCompletion] = []
    @Published var searchTerm = ""
    
    private var cancellables : Set<AnyCancellable> = []
    
    private var searchCompleter = MKLocalSearchCompleter()
    private var onComplete : ((Result<[MKLocalSearchCompletion], Error>) -> Void)?
    
    override init() {
        super.init()
        searchCompleter.delegate = self
        
        $searchTerm
            .debounce(for: .seconds(0.25), scheduler: RunLoop.main)
            .removeDuplicates()
            .flatMap({ (currentSearchTerm) in
                self.searchTermToResults(searchTerm: currentSearchTerm)
            })
            .sink(receiveCompletion: { (completion) in
                //handle error
            }, receiveValue: { (results) in
                self.locationResults = results
            })
            .store(in: &cancellables)
    }
    
    private func searchTermToResults(searchTerm: String) -> Future<[MKLocalSearchCompletion], Error> {
        Future { promise in
            
            self.searchCompleter.resultTypes = .address
            
            // Define the center coordinate for the United States
            let centerCoordinate = CLLocationCoordinate2D(latitude: 37.0902, longitude: -95.7129)

            // Define the span (latitudeDelta and longitudeDelta) for the region
            let span = MKCoordinateSpan(latitudeDelta: 40.0, longitudeDelta: 40.0)

            // Create the MKCoordinateRegion using the center coordinate and span
            let usRegion = MKCoordinateRegion(center: centerCoordinate, span: span)
            
            self.searchCompleter.region = usRegion//= .init(center: <#T##CLLocationCoordinate2D#>, span: MKCoordinateSpan)
            // Begin the search
            self.searchCompleter.queryFragment = searchTerm
            self.onComplete = promise
        }
    }
}

extension WDCitySearch : MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
            onComplete?(.success(completer.results))
        }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        //could deal with the error here, but beware that it will finish the Combine publisher stream
        onComplete?(.failure(error))
    }
}
