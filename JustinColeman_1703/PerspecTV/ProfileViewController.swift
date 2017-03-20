//
//  ProfileViewController.swift
//  PerspecTV
//
//  Created by Justin Coleman on 3/20/17.
//  Copyright © 2017 Justin Coleman. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource{
    
    //MARK: - Outlets
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var channelName: UILabel!
    @IBOutlet weak var totalViewers: UILabel!
    @IBOutlet weak var totalFollowers: UILabel!
    @IBOutlet weak var bannerImage: UIImageView!
    @IBOutlet weak var teamIcon: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activitySpinner: UIActivityIndicatorView!
    @IBOutlet weak var backArrow: UIImageView!
    
    
    //MARK: - Variables
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var currentUser: User!
    var currentID = ""
    var teams = [Team]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        teamIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.teamTapped(_:))))
        backArrow.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.backTapped(_:))))
        
        currentUser = User()
        downloadAndParse(urlString: "https://api.twitch.tv/kraken/channels/\(currentID)?client_id=\(appDelegate.consumerID)&\(appDelegate.apiVersion)", downloadTask: "profile")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Collection View Callbacks
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 0
    }
    
    //MARK: - Storyboard Actions
    @IBAction func profileBack(_ segue: UIStoryboardSegue){
        //do nothing
    }
    
    //MARK: - Methods
    func update(){
        profilePic.image = currentUser.image
        profilePic.layer.cornerRadius = 10
        profilePic.layer.borderWidth = 3.0
        profilePic.layer.borderColor = UIColor.white.cgColor
        profilePic.clipsToBounds = true
        channelName.text = currentUser.username
        totalViewers.text = currentUser.views.description
        totalFollowers.text = currentUser.followers.description
        bannerImage.image = currentUser.banner
        
    }
    
    func backTapped(_ sender: UITapGestureRecognizer){
        performSegue(withIdentifier: "goBack", sender: self)
    }
    
    func teamTapped(_ sender: UITapGestureRecognizer){
        performSegue(withIdentifier: "toTeams", sender: self)
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "toTeams"{
            let TVC = segue.destination as! TeamsViewController
            TVC.teams = teams
            TVC.currentChannel = currentUser.username
        }
    }
 

}
