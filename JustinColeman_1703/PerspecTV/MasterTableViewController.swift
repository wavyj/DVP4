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
        self.navigationItem.title = "PerspecTV"
        self.splitViewController?.preferredDisplayMode = .allVisible
        tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: UITableViewScrollPosition.none)
        tableView(self.tableView, didSelectRowAt: IndexPath(row: 0, section: 0))
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
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .none
        switch indexPath.row {
        case 0:
            cell.pageTitle.text = "Following"
            let origImg = #imageLiteral(resourceName: "HeartIcon")
            let tintedImg = origImg.withRenderingMode(.alwaysTemplate)
            cell.icon.image = tintedImg
            cell.icon.tintColor = UIColor(white: 1, alpha: 0.5)
        case 1:
            cell.pageTitle.text = "Games"
            let origImg = #imageLiteral(resourceName: "GameIcon")
            let tintedImg = origImg.withRenderingMode(.alwaysTemplate)
            cell.icon.image = tintedImg
            cell.icon.tintColor = UIColor(white: 1, alpha: 0.5)
        case 2:
            cell.pageTitle.text = "Watch"
            let origImg = #imageLiteral(resourceName: "PlayIcon")
            let tintedImg = origImg.withRenderingMode(.alwaysTemplate)
            cell.icon.image = tintedImg
            cell.icon.tintColor = UIColor(white: 1, alpha: 0.5)
        case 3:
            cell.pageTitle.text = "Search"
            let origImg = #imageLiteral(resourceName: "SearchIcon")
            let tintedImg = origImg.withRenderingMode(.alwaysTemplate)
            cell.icon.image = tintedImg
            cell.icon.tintColor = UIColor(white: 1, alpha: 0.5)
        case 4:
            cell.pageTitle.text = "Settings"
            let origImg = #imageLiteral(resourceName: "SettingsIcon")
            let tintedImg = origImg.withRenderingMode(.alwaysTemplate)
            cell.icon.image = tintedImg
            cell.icon.tintColor = UIColor(white: 1, alpha: 0.5)
        default:
            print("Error")
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selected = tableView.cellForRow(at: indexPath) as! MenuTableViewCell
        selected.accessoryType = .none
        selected.icon.tintColor = UIColor(white: 1, alpha: 1)
        selected.backgroundColor = UIColor(white: 0, alpha: 0.5)
        switch indexPath.row {
        case 0:
            performSegue(withIdentifier: "goBack", sender: self)
        case 1:
            performSegue(withIdentifier: "goBack", sender: self)
        case 2:
            performSegue(withIdentifier: "goBack", sender: self)
        case 3:
            performSegue(withIdentifier: "goBack", sender: self)
        case 4:
            performSegue(withIdentifier: "goBack", sender: self)
        default:
            print("Error")
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let selected = tableView.cellForRow(at: indexPath) as! MenuTableViewCell
        selected.accessoryType = .disclosureIndicator
        selected.icon.tintColor = UIColor(white: 1, alpha: 0.5)
        selected.backgroundColor = UIColor.clear
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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "goBack"{
            let nav = segue.destination as! UINavigationController
            let DVC = nav.viewControllers.first as! DetailViewController
            let selected = tableView.indexPathForSelectedRow
            switch selected!.row{
            case 0:
                DVC.segueTo = "ipadToFollowing"
            case 1:
                DVC.segueTo = "ipadToGames"
            case 2:
                DVC.segueTo = "ipadToWatch"
            case 3:
                DVC.segueTo = "ipadToSearch"
            case 4:
                DVC.segueTo = "ipadToSettings"
            default:
                print("Error")
            }
        }
    }
 

}
