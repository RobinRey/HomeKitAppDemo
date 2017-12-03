//
//  AccessoryBrowser.swift
//  HomeKitApp
//
//  Created by Raj on 29/10/17.
//  Copyright © 2017 Raj. All rights reserved.
//

import UIKit
import HomeKit
import ExternalAccessory


class AccessoryBrowser: UITableViewController, HMAccessoryBrowserDelegate {

    let accessoryBrowser = HMAccessoryBrowser()
    var accessories = [HMAccessory]()
    var selectedAccessory: HMAccessory?

    override func viewDidLoad() {
        super.viewDidLoad()
        accessoryBrowser.delegate = self
        accessoryBrowser.startSearchingForNewAccessories()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        accessoryBrowser.stopSearchingForNewAccessories()
    }

    @IBAction func done(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }

    // MARK: UITableViewController methods

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accessories.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let accessory = accessories[indexPath.row];
        let cell = tableView.dequeueReusableCell(withIdentifier: "AccessoryCell", for: indexPath)
        cell.textLabel?.text = accessory.name
        cell.detailTextLabel?.text = accessory.category.localizedDescription
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: true)

        selectedAccessory = accessories[indexPath.row]
        HomeStore.sharedInstance.home?.addAccessory(self.selectedAccessory!, completionHandler: { error in

            if (error != nil) {
                print("Error: \(error)")
                UIAlertController.showErrorAlert(self, error: error! as NSError)

            } else {
                NotificationCenter.default.post(name: Notification.Name(rawValue: HomeStore.Notification.AddAccessoryNotification), object: nil)
                HomeStore.sharedInstance.home?.assignAccessory(self.selectedAccessory!, to: (HomeStore.sharedInstance.home?.roomForEntireHome())!, completionHandler: { error in
                    if let error = error {
                        print("failed to assign accessory to room: \(error)")
                    } else {
                        print("added \(self.selectedAccessory!.name) to room")
                    }
                })
            }

        })
    }

    // MARK: HMAccessoryBrowserDelegate methods

    func accessoryBrowser(_ browser: HMAccessoryBrowser, didFindNewAccessory accessory: HMAccessory) {
        print("didFindNewAccessory \(accessory.name)")
        if !self.accessories.contains(accessory) {
            self.accessories.insert(accessory, at: 0)
            let indexPath = IndexPath(row: 0, section: 0)
            tableView.insertRows(at: [indexPath], with: .automatic)
        }
    }

    func accessoryBrowser(_ browser: HMAccessoryBrowser, didRemoveNewAccessory accessory: HMAccessory) {
        print("didRemoveNewAccessory \(accessory.name)")
        if let index = accessories.index(of: accessory) {
            let indexPath = IndexPath(row: index, section: 0)
            accessories.remove(at: index)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}
