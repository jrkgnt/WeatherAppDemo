//
//  WDCitySearchViewController.swift
//  WeatherAppDemo
//
//  Created by Ravikiran Jagarlamudi on 8/25/23.
//

import Foundation
import MapKit
import Combine
import UIKit


class WDWeatherSearchViewController: UIViewController {
    let theme: WDTheme = WDAppTheme()
    let locationFetcher = WDCurrentLocationFetcher()
    
    var currentLocation: CLLocation?
    var searchController : UISearchController!
    var cancellables = Set<AnyCancellable>()
    private let storage: WDStorageManaging =  WDUserDefaultsPersistence()
    
    @IBOutlet var savedCitiescollectionView: UICollectionView!
    @IBOutlet var fetchingProgressLabel: UILabel!
    
    private var savedCitiesDataSource: UICollectionViewDiffableDataSource<WDCityWeatherSectionViewModel, WDWeatherViewModel>!
    private var savedCitiesSections: [WDCityWeatherSectionViewModel] = []
    
    @Published var weatherListOfCities: [WDWeather] = []
    
    var filteredCities: [WDWeatherViewModel] = [] {
        didSet {
            self.savedCitiesSections = [WDCityWeatherSectionViewModel(items: filteredCities)]
            self.applySnapshot()
        }
    }
    
    override func viewDidLoad() {
        // TODO: localization if any
        
        self.navigationItem.title = "Weather Demo"
        self.fetchingProgressLabel.isHidden = true
        setupSearchController()
        setupCollectionView()
        makeDataSource()
        
        let listOfSavedWeatherInfo = self.storage.loadListOfSavedWeathers()
        locationFetcher.$currentLocation.sink { [weak self] locationSubject in
            debugPrint("FETCHED CURRENT LOCATION")
            if locationSubject != self?.currentLocation, let location = locationSubject {
                self?.currentLocation = location
                self?.fetchingProgressLabel.isHidden = false
                
               let hasDataForCurrentLocation = listOfSavedWeatherInfo.first { weatherInfo in
                    let locationLat = Double(location.coordinate.latitude).rounded(toPlaces: 4)
                    let locationLon = Double(location.coordinate.longitude).rounded(toPlaces: 4)
                    let sameLat = weatherInfo.coord?.lat == locationLat
                    let sameLon = weatherInfo.coord?.lon == locationLon
                    return sameLat && sameLon
               } != nil
                
                // fetch only if current location data is not on disk
                let loadCurrentLocation = !hasDataForCurrentLocation //&& listOfSavedWeatherInfo.count == 0
                if loadCurrentLocation {
                    self?.presentWeatherDetailsVC(place: .location(WDWeather.Coord(lon: location.coordinate.latitude, lat: location.coordinate.latitude)))
                }
            }
        }.store(in: &cancellables)
        locationFetcher.requestCurrentUserLocation()
        
        // Update filteredCities; which will update collection view
        let loadSavedCityWeatherInfo: ()-> Void = { [weak self] in
            let listOfSavedWeatherInfo = self?.storage.loadListOfSavedWeathers() ?? []
            self?.fetchingProgressLabel.isHidden = true
            self?.filteredCities = listOfSavedWeatherInfo.map { weatherInfo in
                WDWeatherViewModel(weatherDetails: weatherInfo)
            }
        }
        
        // subscribe to chnages in weatherListOfCities
        UserDefaults.standard.publisher(for: \.weatherList).delay(for: .seconds(0.5), scheduler: RunLoop.main).sink { _ in
            debugPrint("UserDefaults chnaged on key weatherList")
            loadSavedCityWeatherInfo()
            
        }.store(in: &cancellables)
        
        // load first time irrespective of subscription
        loadSavedCityWeatherInfo()
        
    }
    
    func presentWeatherDetailsVC(place: WDWeatherDetailsFetchType) {
        let weatherDetailsController = WDWeatherDetailsViewController(place: place)
        weatherDetailsController.modalPresentationStyle = .automatic
        let navigationController = UINavigationController(rootViewController: weatherDetailsController)
        self.present(navigationController, animated: true)
    }
    
    func setupSearchController() {
        // SEARCH CONTROLLER SETUP
        let cityResultsListViewController = WDCitySearchResultsViewController()
        cityResultsListViewController.onCitySelection = { [weak self] cityResultViewModel in
            // make search inactive
            self?.searchController.dismiss(animated: true, completion: {
                // show  detail view as a modal with add & cancel options
                // TODO: delegate this logic of presentation to coordinator
                
                self?.presentWeatherDetailsVC(place: .city(cityResultViewModel.title))
                
            })
            self?.searchController.isActive = false
        }
        
        self.searchController = UISearchController(searchResultsController: cityResultsListViewController)
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        searchController.searchBar.autocapitalizationType = .none
        searchController.searchBar.delegate = self // Monitor when the search button is tapped.
        
        searchController.searchBar.placeholder = NSLocalizedString("Search for a City", comment: "")
        searchController.searchBar.textContentType = .addressCity
        searchController.searchBar.searchBarStyle = .minimal
        
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = true
        navigationItem.hidesSearchBarWhenScrolling = false
        
        
        // Place the search bar in the navigation bar.
        navigationItem.searchController = searchController
        
        let searchNavigationController = self.navigationController
        searchNavigationController?.navigationBar.isTranslucent = true
        searchNavigationController?.navigationBar.tintColor =  .black //theme.colors.label //
        //searchNavigationController?.navigationBar.barStyle = .black
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()

        searchNavigationController?.navigationBar.prefersLargeTitles = true
        
        self.definesPresentationContext = true
    }
    
    func createListLayout() -> UICollectionViewLayout {
        let numOfItemsInGroup: CGFloat = traitCollection.horizontalSizeClass == .compact ?  1 : 2.0
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0/numOfItemsInGroup),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 0, trailing: 5)
      
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .estimated(100))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                         subitems: [item])
        group.interItemSpacing = .fixed(12)
      
        let section = NSCollectionLayoutSection(group: group)
        

        let layout = UICollectionViewCompositionalLayout(section: section)
        layout.configuration.contentInsetsReference = .readableContent
        return layout
    }
    
    private func setupCollectionView() {
        savedCitiescollectionView.collectionViewLayout = createListLayout()
        savedCitiescollectionView.delegate = self
    }
    
    private func makeDataSource() {
        
        savedCitiesDataSource = UICollectionViewDiffableDataSource(collectionView: savedCitiescollectionView, cellProvider: { [weak self] collectionView, indexPath, item in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WDWeatherSearchCollectionViewCell", for: indexPath)
            
            if let validCell = cell as? WDWeatherSearchCollectionViewCell {
                validCell.cityLabel.text = item.weatherDetails?.name ?? "---------"
                validCell.descLabel.text = item.weatherDetails?.weather.first?.description ?? ""
                
                let temp = String(Int(item.weatherDetails?.main?.temp ?? 0))
                validCell.updateTemperature(temperature: temp, theme: self?.theme)
            }
            
            return cell
        })
    }
    
    private func applySnapshot(animatingDifferences: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<WDCityWeatherSectionViewModel, WDWeatherViewModel>()
        snapshot.appendSections(savedCitiesSections)
        savedCitiesSections.forEach { section in
            var orderedUniqueList: [WDWeatherViewModel] = []
            var uniqueEnforcer: Set<WDWeatherViewModel> = Set()
            
            for item in section.items {
                if uniqueEnforcer.contains(item) {
                    continue
                }
                orderedUniqueList.append(item)
                uniqueEnforcer.insert(item)
            }
        
            snapshot.appendItems(orderedUniqueList, toSection: section)
        }
        DispatchQueue.main.async {[weak self] in
            self?.savedCitiesDataSource.apply(snapshot, animatingDifferences: animatingDifferences)
        }
    }

}

extension WDWeatherSearchViewController: UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate {
    
    func updateSearchResults(for searchController: UISearchController) {
        //let isSearchActive = searchController.isActive
        let searchText = searchController.searchBar.text ?? ""
        
        // trigger search and set the results; Note WDMapSearch takes care of debouncing of 0.25 sec when user types fast key strokes
        let citySearch = WDCitySearch()
        citySearch.searchTerm = searchText
        citySearch.$locationResults.sink { searchResults in
            var filteredResults: [WDCitySearchResultViewModel]  = []
            if !searchText.isEmpty {
                let filteredItems =  searchResults.filter { searchItem in
                    return searchItem.subtitle == "United States"
                }
                filteredResults = filteredItems.map { localSearchResult in
                    WDCitySearchResultViewModel(from: localSearchResult)
                }
            }
            if let resultsVC = self.searchController.searchResultsController as? WDCitySearchResultsViewController {
                resultsVC.filteredCities = filteredResults
            }
            
        }.store(in: &cancellables)
        
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
        
    }
}


extension WDWeatherSearchViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let resultViewModel = savedCitiesDataSource.itemIdentifier(for: indexPath) else {
            collectionView.deselectItem(at: indexPath, animated: false)
            return
        }
        // TODO: Show full screen details page in a paged view
        let cityName = resultViewModel.weatherDetails?.name ?? "------"
        let weatherDetailsController = WDWeatherDetailsViewController(place: .city(cityName), knownWeatherInfo: resultViewModel.weatherDetails, storage: storage)
        self.navigationController?.pushViewController(weatherDetailsController, animated: true)
    }
}

