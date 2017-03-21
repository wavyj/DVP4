//
//  SelectedTeamViewController.swift
//  PerspecTV
//
//  Created by Justin Coleman on 3/21/17.
//  Copyright © 2017 Justin Coleman. All rights reserved.
//

import UIKit

class SelectedTeamViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate {

    //MARK: - Outlets
    @IBOutlet weak var teamView: UIView!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var teamName: UILabel!
    @IBOutlet weak var membersCount: UILabel!
    @IBOutlet weak var backArrow: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var bannerImage: UIImageView!
    
    //MARK: - Variables
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var channels = [(type: String, content: Channel)]()
    var selectedChannel: (type: String, content: Channel)!
    var selectedTeam: Team!
    var offset = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        backArrow.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.backTapped(_:))))
        
        //Team View Setup
        if selectedTeam.profilePic != nil{
            profilePic.image = selectedTeam.profilePic
            profilePic.layer.cornerRadius = 10
            profilePic.layer.borderWidth = 3.0
            profilePic.layer.borderColor = UIColor.white.cgColor
            profilePic.clipsToBounds = true
        }else{
            profilePic.backgroundColor = UIColor.white
        }
        if selectedTeam.bannerImage != nil{
            bannerImage.image = selectedTeam.bannerImage
        }else{
            bannerImage.backgroundColor = UIColor.blue
        }
        teamName.text = selectedTeam.name
        
        channels = selectedTeam.members
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Storyboard Actions
    
    
    //MARK: - Collection View Callbacks
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return channels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ChannelCollectionViewCell
        let current = channels[indexPath.row]
        cell.gameTitle.text = current.content.game
        cell.streamerName.text = current.content.username
        cell.viewerCount.text = current.content.viewers.description
        cell.previewImage.image = current.content.previewImage
        cell.layer.cornerRadius = 6
        cell.isFlipped = false
        
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    //MARK: - Methods
    func backTapped(_ sender: UITapGestureRecognizer){
        performSegue(withIdentifier: "goBack", sender: self)
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
