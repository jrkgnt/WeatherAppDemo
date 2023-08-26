//
//  UIViewController+ModalCheck.swift
//  WeatherAppDemo
//
//  Created by Ravikiran Jagarlamudi on 8/26/23.
//

import Foundation
import UIKit

extension UIViewController {
    var isModal: Bool {
        if let index = navigationController?.viewControllers.firstIndex(of: self), index > 0 {
            return false
        } else if presentingViewController != nil {
            return true
        } else if navigationController?.presentingViewController?.presentedViewController == navigationController {
            return true
        } else if tabBarController?.presentingViewController is UITabBarController {
            return true
        } else {
            return false
        }
    }
}
