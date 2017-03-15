//
//  MasterTableViewController.swift
//  PerspecTV
//
//  Created by Justin Coleman on 3/15/17.
//  Copyright © 2017 Justin Coleman. All rights reserved.
//

import UIKit

class MasterTableViewController: UITableViewController {

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
        return 5
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)as! MenuTableViewCell

        // Configure the cell...
        switch indexPath.row {
        case 0:
            cell.pageTitle.text = "Following"
        case 1:
            cell.pageTitle.text = "Games"
        case 2:
            cell.pageTitle.text = "Watch"
        case 3:
            cell.pageTitle.text = "Search"
        case 4:
            cell.pageTitle.text = "Settings"
        default:
            print("Error")
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            self.navigationItem.title = "Following"
            performSegue(withIdentifier: "ipadToFollowing", sender: self)
        case 1:
            self.navigationItem.title = "Games"
            performSegue(withIdentifier: "ipadToGames", sender: self)
        case 2:
            self.navigationItem.title = "Watch"
            performSegue(withIdentifier: "ipadToWatch", sender: self)
        case 3:
            self.navigationItem.title = "Search"
            performSegue(withIdentifier: "ipadToSearch", sender: self)
        case 4:
            self.navigationItem.title = "Settings"
            performSegue(withIdentifier: "ipadToSettings", sender: self)
        default:
            print("Error")
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
