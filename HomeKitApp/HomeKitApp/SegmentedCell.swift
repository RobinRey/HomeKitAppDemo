//
//  SegmentedCell.swift
//  HomeKitApp
//
//  Created by Manolo de la Torriente on 10/14/15.
//  Created by Raj on 29/10/17.
//  Copyright © 2017 Raj. All rights reserved.
//

import UIKit
import HomeKit

class SegmentetCell: CharacteristicCell {

    @IBOutlet weak var segmentedControl: UISegmentedControl!

    @IBAction func segmentValueChanged(_ sender: UISegmentedControl) {
        let value = titleValues[segmentedControl.selectedSegmentIndex]
        setValue(value as AnyObject, notify: true)
    }

    var titleValues = [Int]() {
        didSet {
            segmentedControl.removeAllSegments()
            for index in 0..<titleValues.count {
                let value: AnyObject = titleValues[index] as AnyObject
                let title = self.characteristic.descriptionForValue(value)
                segmentedControl.insertSegment(withTitle: title, at: index, animated: false)
            }
        }
    }

    override var characteristic: HMCharacteristic! {
        didSet {
            segmentedControl.isUserInteractionEnabled = reachable

            if let values = self.characteristic.allValues as? [Int] {
                titleValues = values
            }
        }
    }

    override func setValue(_ newValue: AnyObject?, notify: Bool) {
        super.setValue(newValue, notify: notify)
        if !notify {
            if let intValue = value as? Int, let index = titleValues.index(of: intValue) {
                segmentedControl.selectedSegmentIndex = index
            }
        }
    }
}
