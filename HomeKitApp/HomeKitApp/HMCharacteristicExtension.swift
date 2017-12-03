//
//  HMCharacteristicExtension.swift
//  HomeKitApp
//
//  Created by Raj on 29/10/17.
//  Copyright © 2017 Raj. All rights reserved.
//

import HomeKit

extension HMCharacteristic {

    fileprivate struct Const {
        static let numberFormatter = NumberFormatter()

        static let numericFormats = [
            HMCharacteristicMetadataFormatInt,
            HMCharacteristicMetadataFormatFloat,
            HMCharacteristicMetadataFormatUInt8,
            HMCharacteristicMetadataFormatUInt16,
            HMCharacteristicMetadataFormatUInt32,
            HMCharacteristicMetadataFormatUInt64
        ]
    }
 
    var isReadOnly: Bool {
        return !properties.contains(HMCharacteristicPropertyWritable)
            && properties.contains(HMCharacteristicPropertyReadable)
    }

    var isWriteOnly: Bool {
        return !properties.contains(HMCharacteristicPropertyReadable)
            && properties.contains(HMCharacteristicPropertyWritable)
    }

    var isBoolean: Bool {
        guard let metadata = metadata else { return false }
        return metadata.format == HMCharacteristicMetadataFormatBool
    }

    var isNumeric: Bool {
        guard let metadata = metadata else { return false }
        guard let format = metadata.format else { return false }
        return Const.numericFormats.contains(format)
    }

    var isFloatingPoint: Bool {
        guard let metadata = metadata else { return false }
        return metadata.format == HMCharacteristicMetadataFormatFloat
    }

    var isInteger: Bool {
        return self.isNumeric && !self.isFloatingPoint
    }

    var hasValueDescriptions: Bool {
        guard let number = self.value as? Int else { return false }
        return self.descriptionForNumber(number) != nil
    }

    var valueDescription: String {
        if let value = self.value {
            return descriptionForValue(value as AnyObject)
        }
        return ""
    }

    var unitDecoration: String {
        if let units = self.metadata?.units {
            switch units {
            case HMCharacteristicMetadataUnitsPercentage: return "%"
            case HMCharacteristicMetadataUnitsFahrenheit: return "℉"
            case HMCharacteristicMetadataUnitsCelsius: return "℃"
            case HMCharacteristicMetadataUnitsArcDegree: "º"
            default:
                break
            }
        }
        return ""
    }

    var valueCount: Int {
        guard let metadata = metadata, let minimumValue = metadata.minimumValue as? Int else { return 0 }
        guard let maximumValue = metadata.maximumValue as? Int else { return 0 }
        var range = maximumValue - minimumValue
        if let stepValue = metadata.stepValue as? Double {
            range = Int(Double(range) / stepValue)
        }
        return range + 1
    }

    var allValues: [AnyObject]? {
        guard self.isInteger else { return nil }
        guard let metadata = metadata, let stepValue = metadata.stepValue as? Double else { return nil }
        let choices = Array(0..<self.valueCount)
        let map  = choices.map { choice in
            Int(Double(choice) * stepValue)
        }
        return map as [AnyObject]
    }


    func descriptionForValue(_ value: AnyObject) -> String {
        if self.isWriteOnly {
            return "Write-Only"

        } else if let metadata = self.metadata {
            if metadata.format == HMCharacteristicMetadataFormatBool {
                if let boolValue = value.boolValue {
                    return boolValue ? "On" : "Off"
                }
            }
        }

        if let intValue = value as? Int {
            if let desc = self.descriptionForNumber(intValue) {
                return desc
            }
            if let stepValue = self.metadata?.stepValue {
                Const.numberFormatter.minimumFractionDigits = Int(log10(1.0 / stepValue.doubleValue))
                if let string = Const.numberFormatter.string(from: NSNumber(value:intValue)) {
                    return string + self.unitDecoration
                }
            }
        }

        return "\(value)"
    }

    func descriptionForNumber(_ number: Int) -> String? {
        switch self.characteristicType {
        case HMCharacteristicTypePowerState, HMCharacteristicTypeInputEvent, HMCharacteristicTypeOutputState:
            return Bool(number as NSNumber) ? "On" : "Off"

        case HMCharacteristicTypeObstructionDetected:
            return Bool(number as NSNumber) ? "Yes" : "No"

        case HMCharacteristicTypeTargetDoorState, HMCharacteristicTypeCurrentDoorState:
            if let state = HMCharacteristicValueDoorState(rawValue: number) {
                switch state {
                case .open: return "Open"
                case .opening: return "Opening"
                case .closed: return "Closed"
                case .closing: return "Closing"
                case .stopped: return "Stopped"
                }
            }

        case HMCharacteristicTypePositionState:
            if let state = HMCharacteristicValuePositionState(rawValue: number) {
                switch state {
                case .opening: return "Opening"
                case .closing: return "Closing"
                case .stopped: return "Stopped"
                }
            }

        case HMCharacteristicTypeRotationDirection:
            if let dir = HMCharacteristicValueRotationDirection(rawValue: number) {
                switch dir {
                case .clockwise: return "Clockwise"
                case .counterClockwise: return "Counter Clockwise"
                }
            }
        default:
            break
        }
        return nil
    }
}
