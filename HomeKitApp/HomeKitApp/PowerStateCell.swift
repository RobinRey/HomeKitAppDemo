//
//  PowerStateCell.swift
//  HomeKitApp
//
//  Created by Manolo de la Torriente on 10/13/15.
//  Created by Raj on 29/10/17.
//  Copyright © 2017 Raj. All rights reserved.
//

import UIKit
import HomeKit

class PowerStateCell: CharacteristicCell {

    @IBOutlet weak var powerSwitch: UISwitch!

    @IBAction func switchValueChanged(_ sender: UISwitch) {
        setValue(powerSwitch.isOn as AnyObject, notify: true)
    }

    override var characteristic: HMCharacteristic! {
        didSet {
            powerSwitch.isUserInteractionEnabled = reachable
        }
    }

    override func setValue(_ newValue: AnyObject?, notify: Bool) {
        super.setValue(newValue, notify: notify)
        if let newValue = newValue as? Bool, !notify {
            powerSwitch.setOn(newValue, animated: true)
        }
    }
}
