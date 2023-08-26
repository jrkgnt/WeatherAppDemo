//
//  WDImageLoaderService.swift
//  WeatherAppDemo
//
//  Created by Ravikiran Jagarlamudi on 8/26/23.
//

import Foundation
import UIKit

protocol WDImageLoaderServiceable {
    func cancelFetch(urlString: String)
    func fetchImage(urlString: String, completion: @escaping (UIImage?) -> Void) -> URLSessionDataTask?
}

final class WDImageLoaderService: WDImageLoaderServiceable {
    // TODO: abstract this into a separate service
    let imageCache = NSCache<NSString, UIImage>()

    private var tasks: [String : URLSessionTask] = [:]

    func cancelFetch(urlString: String) {
        // cancel sessionTask and remove it from tasks
        var keysToRemove: [String] = []

        for (urlStringKey, sessionTaskValue) in tasks {
            guard urlString == urlStringKey else { continue }
            sessionTaskValue.cancel()
            keysToRemove.append(urlStringKey)
        }

        keysToRemove.forEach { tasks.removeValue(forKey: $0) }
    }

    func fetchImage(urlString: String, completion: @escaping (UIImage?) -> Void) -> URLSessionDataTask? {
        guard let url = URL(string: urlString) else { return nil }

        if let cachedResult = imageCache.object(forKey: NSString(string: urlString)) {
            completion(cachedResult)
            print("using cached for \(urlString)")
            return nil
        }

        let dataTask = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data,
                  let imageData = UIImage(data: data) else {
                return
            }
            completion(imageData)
            self?.imageCache.setObject(imageData, forKey: NSString(string: urlString))

            // Remove Task from dictionary
            self?.tasks[urlString] = nil
        }

        tasks[urlString] = dataTask
        return dataTask
    }
}
