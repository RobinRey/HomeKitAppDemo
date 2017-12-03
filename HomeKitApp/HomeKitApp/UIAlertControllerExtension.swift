//
//  UIAlertControllerExtension.swift
//  HomeKitApp
//
//  Created by Raj on 29/10/17.
//  Copyright © 2017 Raj. All rights reserved.
//

import UIKit

extension UIAlertController {

    class func showErrorAlert(_ host: UIViewController, error: NSError) {
        let controller = UIAlertController(title: "Error", message: error.description, preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        host.present(controller, animated: true, completion: nil)
    }
}

