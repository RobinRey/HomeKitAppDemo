//
//  HomeStore
//  HomeKitApp
//
//  Created by Raj on 29/10/17.
//  Copyright © 2017 Raj. All rights reserved.

import HomeKit

class HomeStore: NSObject {

    static let sharedInstance = HomeStore()

    struct Notification {
        static let AddAccessoryNotification = "AddAccessoryNotification"
    }

    var homeManager: HMHomeManager = HMHomeManager()
    var home: HMHome?
}
