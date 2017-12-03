//
//  ServicesViewController.swift
//  HomeKitApp
//
//  Created by Raj on 29/10/17.
//  Copyright © 2017 Raj. All rights reserved.
//

import UIKit
import HomeKit


class ServicesViewController: UITableViewController, HMAccessoryDelegate {

    struct Identifiers {
        static let CharacteristicCell = "CharacteristicCell"
        static let PowerStateCell = "PowerStateCell"
        static let SliderCell = "SliderCell"
        static let SegmentedCell = "SegmentedCell"
    }

    var accessory: HMAccessory? {
        didSet {
            accessory?.delegate = self
        }
    }
    var services = [HMService]()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "\(accessory!.name) Services"
        configureServices()
        enableNotifications(true)
    }

    fileprivate func configureServices() {

        printServicesForAccessory(accessory!)

        for service in accessory!.services as [HMService] {
            if service.serviceType == HMServiceTypeAccessoryInformation {
                services.insert(service, at: 0)
            } else {
                services.append(service)
            }
        }
    }

    fileprivate func enableNotifications(_ enable: Bool) {
        for service in services {
            for characteristic in service.characteristics {
                if characteristic.properties.contains(NSNotification.Name.HMCharacteristicPropertySupportsEvent.rawValue) {
                    characteristic.enableNotification(enable, completionHandler: { error in
                        if let error = error {
                            print("Failed to enable notifications for \(characteristic): \(error.localizedDescription)")
                        }
                    })
                }
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        enableNotifications(false)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return services.count
    }

    // MARK: UITableViewController methods

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return services[section].characteristics.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var reuseIdentifier = Identifiers.CharacteristicCell

        let characteristic = services[indexPath.section].characteristics[indexPath.row]

        if characteristic.isReadOnly || characteristic.isWriteOnly {
            reuseIdentifier = Identifiers.CharacteristicCell
        } else if characteristic.isBoolean {
            reuseIdentifier = Identifiers.PowerStateCell
        } else if characteristic.hasValueDescriptions {
            reuseIdentifier = Identifiers.SegmentedCell
        } else if characteristic.isNumeric {
            reuseIdentifier = Identifiers.SliderCell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        if let cell = cell as? CharacteristicCell {
            cell.characteristic = characteristic
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return services[section].name
    }

    // MARK: HMAccessoryDelegate methods
    
    func accessory(_ accessory: HMAccessory, service: HMService, didUpdateValueFor characteristic: HMCharacteristic) {
        if let index = service.characteristics.index(of: characteristic) {
            let indexPath = IndexPath(row: index, section: 1)
            let cell = tableView.cellForRow(at: indexPath) as! CharacteristicCell
            cell.setValue(characteristic.value as AnyObject, notify: false)
        }
    }

    // MARK: Private hepler methods

    fileprivate func printServicesForAccessory(_ accessory: HMAccessory){
        print("Finding services for this accessory...")
        for service in accessory.services as [HMService]{
            print(" Service name is \(service.name)")
            print(" Service type is \(service.serviceType)")

            print(" Finding the characteristics for this service...")
            printCharacteristicsForService(service)
        }
    }

    fileprivate func printCharacteristicsForService(_ service: HMService){
        for characteristic in service.characteristics as [HMCharacteristic]{
            print("   Characteristic type is " + "\(characteristic.characteristicType)")
        }
    }
}
