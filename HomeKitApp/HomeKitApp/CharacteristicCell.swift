//
//  CharacteristicCell.swift
//  HomeKitApp
//
//  Created by Raj on 29/10/17.
//  Copyright © 2017 Raj. All rights reserved.
//

import UIKit
import HomeKit


class CharacteristicCell: UITableViewCell {

    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!

    var characteristic: HMCharacteristic! {
        didSet {
            var desc = characteristic.localizedDescription
            if characteristic.isReadOnly {
                desc = desc + " (Read Only)"
            } else if characteristic.isWriteOnly {
                desc = desc + " (Write Only)"
            }
            typeLabel.text = desc
            valueLabel?.text = "No Value"

            setValue(characteristic.value as AnyObject, notify: false)

            selectionStyle = characteristic.characteristicType == HMCharacteristicTypeIdentify ? .default : .none

            if characteristic.isWriteOnly {
                return
            }

            if reachable {
                characteristic.readValue { error in
                    if let error = error {
                        print("Error reading value for \(self.characteristic): \(error)")
                    } else {
                        self.setValue(self.characteristic.value as AnyObject, notify: false)
                    }
                }
            }
        }
    }

    var value: AnyObject?

    var reachable: Bool {
        return (characteristic.service?.accessory?.isReachable ?? false)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func setValue(_ newValue: AnyObject?, notify: Bool) {
        self.value = newValue
        if let value = self.value {
            self.valueLabel?.text = self.characteristic.descriptionForValue(value)
        }

        if notify {
            self.characteristic.writeValue(self.value, completionHandler: { error in
                if let error = error {
                    print("Failed to write value for \(self.characteristic): \(error.localizedDescription)")
                }
            })
        }
    }
}
