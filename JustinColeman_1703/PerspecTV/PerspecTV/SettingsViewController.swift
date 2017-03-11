//
//  SettingsTableViewController.swift
//  PerspecTV
//
//  Created by Justin Coleman on 3/10/17.
//  Copyright © 2017 Justin Coleman. All rights reserved.
//

import UIKit

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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        currentUser = appDelegate.currentUser
        
        //Profile View Setup
        profileView.layer.cornerRadius = 6
        profilePic.image = currentUser.image
        profilePic.layer.cornerRadius = 10
        profilePic.layer.borderWidth = 3.0
        profilePic.layer.borderColor = UIColor.white.cgColor
        profilePic.clipsToBounds = true
        userName.text = currentUser.username
        bannerImage.image = currentUser.banner
        bannerImage.layer.cornerRadius = 6
        bannerImage.clipsToBounds = true
        profileView.layer.shadowOpacity = 0.5
        profileView.layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
        profileView.layer.shadowColor = UIColor.black.cgColor
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
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        (view as! UITableViewHeaderFooterView).textLabel?.textColor = UIColor.lightGray
    }
    

    //Methods
    @IBAction func removeUser(){
        DispatchQueue.main.async {
            self.activitySpinner.startAnimating()
        }
        
        appDelegate.currentUser = nil
        
        //Removes User data from UserDefaults
        UserDefaults.standard.set(false, forKey: "LoggedIn")
        UserDefaults.standard.removeObject(forKey: "AuthToken")
        UserDefaults.standard.removeObject(forKey: "UserLink")
        
        //unwind back to login screen
        performSegue(withIdentifier: "loggedOut", sender: self)
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