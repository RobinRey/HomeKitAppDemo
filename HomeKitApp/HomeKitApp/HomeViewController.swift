//
//  HomeViewController.swift
//  HomeKitApp
//
//  Created by Raj on 29/10/17.
//  Copyright © 2017 Raj. All rights reserved.
//

import UIKit
import HomeKit

class HomeViewController: UITableViewController, HMHomeDelegate {

    var homeStore: HomeStore {
        return HomeStore.sharedInstance
    }
    var home: HMHome! {
        return homeStore.home
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        home?.delegate = self
        title = homeStore.home!.name

        NotificationCenter.default.addObserver(self,
            selector: #selector(HomeViewController.updateAccessories),
            name: NSNotification.Name(rawValue: HomeStore.Notification.AddAccessoryNotification), object: nil)
    }

    func updateAccessories() {
        print("updateAccessories selector called from NSNotificationCenter")
        tableView.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ServicesSegue" {
            let controller = segue.destination as! ServicesViewController
            let indexPath = tableView.indexPathForSelectedRow;
            controller.accessory = homeStore.home!.accessories[(indexPath?.row)!];
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {

        if homeStore.home?.accessories.count == 0 {
            setBackgroundMessage("No Accessories")
        } else {
            setBackgroundMessage(nil)
        }
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return homeStore.home!.accessories.count
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let accessory = homeStore.home!.accessories[indexPath.row];
        let reuseIdentifier = "AccessoryCell"

        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        cell.textLabel?.text = accessory.name

        let accessoryName = accessory.name
        let roomName = accessory.room!.name
        let inIdentifier = NSLocalizedString("%@ in %@", comment: "Accessory in Room")
        cell.detailTextLabel?.text = String(format: inIdentifier, accessoryName, roomName)
        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return homeStore.home?.accessories.count != 0 ? "Accessories" : ""
        }
        return nil
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 1 {
            return true
        }
        return false
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {

        if (editingStyle == .delete) {

            let accessory = homeStore.home?.accessories[indexPath.row]
            homeStore.home?.removeAccessory(accessory!, completionHandler: { error in
                if error != nil {
                    print("Error \(error)")
                    UIAlertController.showErrorAlert(self, error: error! as NSError)

                } else {
                    tableView.beginUpdates()
                        let rowAnimation = self.homeStore.home?.accessories.count == 0 ? UITableViewRowAnimation.fade : UITableViewRowAnimation.automatic
                        tableView.deleteRows(at: [indexPath], with: rowAnimation)
                    tableView.endUpdates()
                    tableView.reloadData()
                }
            })
        }
    }

    // MARK: HMHomeDelegate methods

    func home(_ home: HMHome, didAdd accessory: HMAccessory) {
        print("didAddAccessory \(accessory.name)")
        tableView.reloadData()
    }

    func home(_ home: HMHome, didRemove accessory: HMAccessory) {
        print("didRemoveAccessory \(accessory.name)")
        tableView.reloadData()
    }

    // MARK: Private methods

    fileprivate func setBackgroundMessage(_ message: String?) {
        if let message = message {
            let label = UILabel()
            label.text = message
            label.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
            label.textColor = UIColor.lightGray
            label.textAlignment = .center
            label.sizeToFit()
            tableView.backgroundView = label
            tableView.separatorStyle = .none
        }
        else {
            tableView.backgroundView = nil
            tableView.separatorStyle = .singleLine
        }
    }
}
