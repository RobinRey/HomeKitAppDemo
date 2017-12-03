//
//  SliderCell.swift
//  HomeKitApp
//
//  Created by Manolo de la Torriente on 10/14/15.
//  Created by Raj on 29/10/17.
//  Copyright © 2017 Raj. All rights reserved.
//

import UIKit
import HomeKit

class SliderCell: CharacteristicCell {

    @IBOutlet weak var slider: UISlider!

    @IBAction func sliderValueChanged(_ sender: UISlider) {
        let value = roundedValueForSliderValue(slider.value)
        setValue(value as AnyObject, notify: true)
    }

    override var characteristic: HMCharacteristic! {
        didSet {
            slider.isUserInteractionEnabled = reachable
        }

        willSet {
            slider.minimumValue = newValue.metadata?.minimumValue as? Float ?? 0.0
            slider.maximumValue = newValue.metadata?.maximumValue as? Float ?? 100.0
        }
    }

    override func setValue(_ newValue: AnyObject?, notify: Bool) {
        super.setValue(newValue, notify: notify)
        if let newValue = newValue as? NSNumber, !notify {
            slider.value = newValue.floatValue
        }
    }

    fileprivate func roundedValueForSliderValue(_ value: Float) -> Float {
        if let metadata = characteristic.metadata,
            let stepValue = metadata.stepValue as? Float, stepValue > 0 {
                let newValue = roundf(value / stepValue)
                let stepped = newValue * stepValue
                return stepped
        }
        return value
    }
}
