//
//  TestVC.swift
//  JESideMenu
//
//  Created by JE on 03.08.17.
//  Copyright © 2017 JE. All rights reserved.
//

import UIKit

class TestVC: UIViewController, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    let data = ["Kühe", "Kühe","Kühe","Kühe","Kühe","Kühe","Kühe","Kühe","Kühe","Kühe","Kühe","Kühe","Kühe","Kühe","Kühe","Kühe","Kühe","Kühe","Kühe","Kühe","Kühe","Kühe",]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - TableView DataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = data[indexPath.row]
        
        return cell
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
