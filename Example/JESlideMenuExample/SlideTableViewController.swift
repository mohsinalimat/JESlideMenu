//
//  SlideTableViewController.swift
//  JESlideMenu
//
//  Created by JE on 08.08.17.
//  Copyright © 2017 JE. All rights reserved.
//

import UIKit

class SlideTableViewController: UITableViewController {

    let data = [NSLocalizedString("red", comment: ""),
                NSLocalizedString("green", comment: ""),
                NSLocalizedString("blue", comment: ""),
                NSLocalizedString("cyan", comment: ""),
                NSLocalizedString("magenta", comment: ""),
                NSLocalizedString("eggshell", comment: "")]
    let segueIdentifier = "show"
    let cellIdentifier = "cell"

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return data.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        cell.textLabel?.text = data[indexPath.row]

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let country = data[indexPath.row]
        performSegue(withIdentifier: segueIdentifier, sender: ["country": country])
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "show" {
            if sender != nil {
                if let dict = sender as? [String: String] {
                    let country = dict["country"]
                    let destination = segue.destination as? ViewController
                    destination?.text = country
                }
            }
        }
    }
}
