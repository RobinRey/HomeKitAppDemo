//
//  HomesViewController.swift
//  HomeKitApp

//  Created by Raj on 29/10/17.
//  Copyright © 2017 Raj. All rights reserved.
import UIKit
import HomeKit


class HomesViewController: UITableViewController, HMHomeManagerDelegate {

    enum HomeSections: Int {
        case homes = 0, primaryHome
        static let count = 2
    }

    struct Identifiers {
        static let addHomeCell = "AddHomeCell"
        static let noHomesCell = "NoHomesCell"
        static let primaryHomeCell = "PrimaryHomeCell"
        static let homeCell = "HomeCell"
    }

    var homeStore: HomeStore {
        return HomeStore.sharedInstance
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        homeStore.homeManager.delegate = self
    }

    // MARK: UITableView helpers

    func isHomesListEmpty() -> Bool {
        return homeStore.homeManager.homes.count == 0
    }

    func isIndexPathAddHome(_ indexPath: IndexPath) -> Bool {
        return indexPath.section == HomeSections.homes.rawValue
            && indexPath.row == homeStore.homeManager.homes.count
    }

    // MARK: UITableView methods

    override func numberOfSections(in tableView: UITableView) -> Int {
        return HomeSections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        let count = homeStore.homeManager.homes.count

        switch (section) {
        case HomeSections.primaryHome.rawValue:
            return max(count, 1)
        case HomeSections.homes.rawValue:
            return count + 1
        default:
            break
        }

        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if isIndexPathAddHome(indexPath) {
            return tableView.dequeueReusableCell(withIdentifier: Identifiers.addHomeCell, for: indexPath)
        } else if isHomesListEmpty() {
            return tableView.dequeueReusableCell(withIdentifier: Identifiers.noHomesCell, for: indexPath)
        }

        var reuseIdentifier: String?

        switch (indexPath.section) {
        case HomeSections.primaryHome.rawValue:
            reuseIdentifier = Identifiers.primaryHomeCell
        case HomeSections.homes.rawValue:
            reuseIdentifier = Identifiers.homeCell
        default:
            break
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier!, for: indexPath) as UITableViewCell

        let home = homeStore.homeManager.homes[indexPath.row] as HMHome
        cell.textLabel?.text = home.name

        if indexPath.section == HomeSections.primaryHome.rawValue {
            if home == homeStore.homeManager.primaryHome {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if isIndexPathAddHome(indexPath) {
            tableView.deselectRow(at: indexPath, animated: true)
            onAddHomeTouched()

        } else {
            homeStore.home = homeStore.homeManager.homes[indexPath.row]
            if HomeSections(rawValue: indexPath.section) == .primaryHome {
                let home = homeStore.homeManager.homes[indexPath.row]
                if home != homeStore.homeManager.primaryHome {
                    homeStore.homeManager.updatePrimaryHome(home, completionHandler: { error in
                        if let error = error {
                            UIAlertController.showErrorAlert(self, error: error as NSError)
                        } else {
                            let indexSet = IndexSet(integer: HomeSections.primaryHome.rawValue)
                            tableView.reloadSections(indexSet, with: .automatic)
                        }
                    })
                }
            }
        }
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return !isIndexPathAddHome(indexPath)
            && !isHomesListEmpty()
            && indexPath.section == HomeSections.homes.rawValue
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {

        if (editingStyle == .delete) {

            let home = homeStore.homeManager.homes[indexPath.row] as HMHome
            homeStore.homeManager.removeHome(home, completionHandler: { error in

                if error != nil {
                    print("Error \(error)")
                    return

                } else {
                    tableView.beginUpdates()
                    let primaryIndexPath = IndexPath(row: indexPath.row, section: HomeSections.primaryHome.rawValue)
                    if self.homeStore.homeManager.homes.count == 0 {
                        tableView.reloadRows(at: [primaryIndexPath], with: UITableViewRowAnimation.fade)
                    } else {
                        tableView.deleteRows(at: [primaryIndexPath], with: .automatic)
                    }
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                    tableView.endUpdates()
                }
            })
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == HomeSections.primaryHome.rawValue {
            return "Primary Home"
        }
        return nil
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == HomeSections.primaryHome.rawValue {
            return "Used by Siri to route commands when a home is not specified"
        }
        return nil
    }

    // MARK: HMHomeManagerDelegate methods

    func homeManagerDidUpdateHomes(_ manager: HMHomeManager) {
        print("homeManagerDidUpdateHomes")
        tableView.reloadData()
    }

    func homeManager(_ manager: HMHomeManager, didAdd home: HMHome) {
        print("didAddHome \(home.name)")
    }

    func homeManager(_ manager: HMHomeManager, didRemove home: HMHome) {
        print("didRemoveHome \(home.name)")
    }


    fileprivate func onAddHomeTouched() {

        let controller = UIAlertController(title: "Add Home", message: "Enter a name for the home", preferredStyle: .alert)

        controller.addTextField(configurationHandler: { textField in
            textField.placeholder = "My House"
        })

        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        controller.addAction(UIAlertAction(title: "Add Home", style: .default) { action in
            let textFields = controller.textFields as [UITextField]!
            if let homeName = textFields?[0].text {

                if homeName.isEmpty {
                    let alert = UIAlertController(title: "Error", message: "Please enter a name", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)

                } else {
                    self.homeStore.homeManager.addHome(withName: homeName, completionHandler: { home, error in
                        if error != nil {
                            print("failed to add new home. \(error)")
                        } else {
                            print("added home \(home!.name)")
                            self.tableView.reloadData()
                        }
                    })
                }
            }
        })
        present(controller, animated: true, completion: nil)
    }
}


