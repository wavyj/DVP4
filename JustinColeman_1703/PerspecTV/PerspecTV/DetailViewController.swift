//
//  DetailViewController.swift
//  PerspecTV
//
//  Created by Justin Coleman on 3/15/17.
//  Copyright © 2017 Justin Coleman. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    //Variables
    var currentUser: User!
    var segueTo = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if segueTo != ""{
            performSegue(withIdentifier: segueTo, sender: self)
        }else{
            performSegue(withIdentifier: "toMaster", sender: self)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "ipadToFollowing"{
            let FVC = segue.destination as! FollowingViewController
            FVC.userLoggedIn = true
            if currentUser != nil{
                FVC.channelsToDownload.append(currentUser.id)
            }
        }
    }
 

}
