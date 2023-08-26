//
//  WDCitySearchViewController.swift
//  WeatherAppDemo
//
//  Created by Ravikiran Jagarlamudi on 8/25/23.
//

import Foundation
import UIKit


extension WDCitySearchResultsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let resultViewModel = cityResultsDataSource.itemIdentifier(for: indexPath) else {
            collectionView.deselectItem(at: indexPath, animated: false)
            return
        }
        onCitySelection(resultViewModel)
    }
}


class WDCitySearchResultsViewController: UIViewController {
    
    private var cityResultscollectionView: UICollectionView!
    private var cityResultsDataSource: UICollectionViewDiffableDataSource<WDCitySearchSectionViewModel, WDCitySearchResultViewModel>!
    private var cityResultsSections: [WDCitySearchSectionViewModel] = []
    
    let theme: WDTheme = WDAppTheme()
    
    var filteredCities: [WDCitySearchResultViewModel] = [] {
        didSet {
            self.cityResultsSections = [WDCitySearchSectionViewModel(items: filteredCities)]
            self.applySnapshot()
        }
    }
    
    var onCitySelection: (WDCitySearchResultViewModel) -> Void = {_ in
    }
    
    override func viewDidLoad() {
        createCollectionView()
        makeDataSource()
        
        super.viewDidLoad()
    }
    
  
    private func createListLayout() -> UICollectionViewLayout {
        let config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        let collectionListViewLayout = UICollectionViewCompositionalLayout.list(using: config)
        return collectionListViewLayout
    }
    
    private func createCollectionView() {
        cityResultscollectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createListLayout())
        cityResultscollectionView.backgroundColor = .systemBackground
        cityResultscollectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(cityResultscollectionView)
        cityResultscollectionView.delegate = self
    }
    
    private func makeDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, WDCitySearchResultViewModel> { cell, indexPath, item in
            
            var contentConfiguration = cell.defaultContentConfiguration()
            //contentConfiguration.text = item.title
            contentConfiguration.attributedText = item.highlightedText
            contentConfiguration.secondaryAttributedText = item.subtitleHighlightedText
            cell.contentConfiguration = contentConfiguration
        }
        cityResultsDataSource =  UICollectionViewDiffableDataSource(collectionView: cityResultscollectionView) { collectionView, indexPath, item in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }
        
    }
    
    private func applySnapshot(animatingDifferences: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<WDCitySearchSectionViewModel, WDCitySearchResultViewModel>()
        snapshot.appendSections(cityResultsSections)
        cityResultsSections.forEach { section in
            snapshot.appendItems(section.items, toSection: section)
        }
        DispatchQueue.main.async {[weak self] in
            self?.cityResultsDataSource.apply(snapshot, animatingDifferences: animatingDifferences)
        }
    }
    
}



