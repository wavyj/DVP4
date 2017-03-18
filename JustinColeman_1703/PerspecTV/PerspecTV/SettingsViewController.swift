//
//  SettingsTableViewController.swift
//  PerspecTV
//
//  Created by Justin Coleman on 3/10/17.
//  Copyright © 2017 Justin Coleman. All rights reserved.
//

import UIKit
import WebKit

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    //MARK: - Outlets
    @IBOutlet weak var activitySpinner: UIActivityIndicatorView!
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var bannerImage: UIImageView!
    @IBOutlet weak var viewsLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - Variables
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var currentUser: User!
    var isMenuOpen = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        currentUser = appDelegate.currentUser
        if appDelegate.isPhone == false{
            self.splitViewController?.preferredDisplayMode = .primaryHidden
        }
        //Profile View Setup
        profilePic.image = currentUser.image
        profilePic.layer.cornerRadius = 10
        profilePic.layer.borderWidth = 3.0
        profilePic.layer.borderColor = UIColor.white.cgColor
        profilePic.clipsToBounds = true
        userName.text = currentUser.username
        bannerImage.image = currentUser.banner
        bannerImage.clipsToBounds = true
        viewsLabel.text = currentUser.views.description
        followersLabel.text = currentUser.followers.description
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        // Configure the cell...
        cell.textLabel?.text = "Logout"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        removeUser()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Account"
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        (view as! UITableViewHeaderFooterView).textLabel?.textColor = UIColor.lightGray
    }
    

    //Methods
    @IBAction func hamMenuTapped(_ sender: UIButton){
        if isMenuOpen{
            UIView.animate(withDuration: 0.5, animations: {
                self.splitViewController?.preferredDisplayMode = .primaryHidden
            }, completion: { (Bool) in
                self.tableView.isUserInteractionEnabled = true
                self.isMenuOpen = false
            })
        }else{
            UIView.animate(withDuration: 0.5, animations: {
                self.splitViewController?.preferredDisplayMode = .allVisible
            }, completion: { (Bool) in
                self.tableView.isUserInteractionEnabled = false
                self.isMenuOpen = true
            })
        }
    }
    
    @IBAction func removeUser(){
        let alert = UIAlertController(title: "Remove Account", message: "Are you sure you want to logout of this account?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .destructive) { (YesAction) in
            self.appDelegate.currentUser = nil
            
            //Removes User data from UserDefaults
            UserDefaults.standard.set(false, forKey: "LoggedIn")
            UserDefaults.standard.removeObject(forKey: "AuthToken")
            UserDefaults.standard.removeObject(forKey: "UserLink")
            
            //unwind back to login screen
            self.performSegue(withIdentifier: "loggedOut", sender: self)
        }
        let noAction = UIAlertAction(title: "No", style: .cancel) { (NoAction) in
            self.tableView(self.tableView, didDeselectRowAt: self.tableView.indexPathForSelectedRow!)
            self.tableView.deselectRow(at: self.tableView.indexPathForSelectedRow!, animated: true)
        }
        alert.addAction(yesAction)
        alert.addAction(noAction)
        
        present(alert, animated: true, completion: nil)
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
