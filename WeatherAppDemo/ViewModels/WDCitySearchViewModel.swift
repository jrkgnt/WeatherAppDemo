//
//  WDCitySearchViewModel.swift
//  WeatherAppDemo
//
//  Created by Ravikiran Jagarlamudi on 8/25/23.
//

import Foundation
import MapKit

// Represents section view model in filtered cities list view
struct WDCitySearchSectionViewModel: Hashable {
    let items: [WDCitySearchResultViewModel]
}

// Represents row view model in filtered cities list view
struct WDCitySearchResultViewModel: Hashable {
    let title: String
    let subTitle: String
    let highlightedText: NSAttributedString?
    let subtitleHighlightedText: NSAttributedString?
}

extension WDCitySearchResultViewModel {
    init(from item: MKLocalSearchCompletion) {
        self.title = item.title
        self.subTitle = item.subtitle
        
        let attributedText = NSMutableAttributedString(string: item.title)
        let titleFont = UIFont.preferredFont(forTextStyle: .subheadline)
        attributedText.addAttribute(NSAttributedString.Key.font, value:titleFont, range:NSMakeRange(0, item.title.count))
        
        let bold = UIFont.boldSystemFont(ofSize: titleFont.pointSize)
        for value in item.titleHighlightRanges {
            attributedText.addAttribute(NSAttributedString.Key.font, value:bold, range:value.rangeValue)
        }
        self.highlightedText = attributedText
        
        
        let subTitleAttributedText = NSMutableAttributedString(string: item.subtitle)
        let subTitleFont = UIFont.preferredFont(forTextStyle: .body)
        subTitleAttributedText.addAttribute(NSAttributedString.Key.font, value:subTitleFont, range:NSMakeRange(0, item.subtitle.count))
        
        let subtitleBold = UIFont.boldSystemFont(ofSize: subTitleFont.pointSize)
        for value in item.subtitleHighlightRanges {
            subTitleAttributedText.addAttribute(NSAttributedString.Key.font, value:subtitleBold, range:value.rangeValue)
        }
        self.subtitleHighlightedText = subTitleAttributedText
        
        
    }
}
