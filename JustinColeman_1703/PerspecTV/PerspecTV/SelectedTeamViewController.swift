//
//  SelectedTeamViewController.swift
//  PerspecTV
//
//  Created by Justin Coleman on 3/21/17.
//  Copyright © 2017 Justin Coleman. All rights reserved.
//

import UIKit

class SelectedTeamViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource{

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
            bannerImage.backgroundColor = UIColor.black
        }
        
        teamName.text = selectedTeam.name
        channels = selectedTeam.members
        membersCount.text = channels.count.description
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Storyboard Actions
    @IBAction func watchTapped(_ sender: UIButton){
        //Clears array and sets the selected channel to the only stream
        appDelegate.streams = [selectedChannel]
        if appDelegate.isPhone == true{
            performSegue(withIdentifier: "toWatch", sender: self)
        }else{
            performSegue(withIdentifier: "toDetail", sender: self)
        }
    }
    
    @IBAction func addTapped(_ sender: UIButton){
        //Adds selected stream to array of streams
        appDelegate.streams.append(selectedChannel)
        if appDelegate.isPhone == true{
            performSegue(withIdentifier: "toWatch", sender: self)
        }else{
            performSegue(withIdentifier: "toDetail", sender: self)
        }
    }
    
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedChannel = channels[indexPath.row]
        let selectedCell = collectionView.cellForItem(at: indexPath) as! ChannelCollectionViewCell
        if selectedCell.isFlipped == false{
            UIView.transition(with: selectedCell, duration: 0.5, options: .transitionFlipFromRight, animations: {
                collectionView.isUserInteractionEnabled = false
                //selectedCell.previewImage.isHidden = true
                selectedCell.gameTitle.isHidden = true
                selectedCell.streamerName.isHidden = true
                selectedCell.viewerCount.isHidden = true
                selectedCell.addBtn.isHidden = false
                selectedCell.watchBtn.isHidden = false
                selectedCell.viewersIcon.isHidden = true
                selectedCell.addLabel.isHidden = false
                selectedCell.watchLabel.isHidden = false
                
                //Check current streams
                let streams = self.appDelegate.streams!
                if !streams.contains(where: { (Channel) -> Bool in
                    if Channel.content.username == self.selectedChannel.content.username{
                        return true
                    }else{
                        return false
                    }
                }){
                    selectedCell.watchBtn.isEnabled = true
                    selectedCell.addBtn.isEnabled = true
                    if streams.count == 4{
                        selectedCell.addBtn.isEnabled = false
                        selectedCell.watchBtn.isEnabled = false
                    }
                }else{
                    selectedCell.watchBtn.isEnabled = false
                    selectedCell.addBtn.isEnabled = false
                }
                
            }, completion: { (Bool) in
                selectedCell.isFlipped = true
                collectionView.isUserInteractionEnabled = true
            })
        }else{
            UIView.transition(with: selectedCell, duration: 0.5, options: .transitionFlipFromLeft, animations: {
                collectionView.isUserInteractionEnabled = false
                //selectedCell.previewImage.isHidden = false
                selectedCell.gameTitle.isHidden = false
                selectedCell.streamerName.isHidden = false
                selectedCell.viewerCount.isHidden = false
                selectedCell.addBtn.isHidden = true
                selectedCell.watchBtn.isHidden = true
                selectedCell.viewersIcon.isHidden = false
                selectedCell.addLabel.isHidden = true
                selectedCell.watchLabel.isHidden = true
            }, completion: { (Bool) in
                selectedCell.isFlipped = false
                collectionView.isUserInteractionEnabled = true
            })
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        //Unflip the cell
        let selectedCell = collectionView.cellForItem(at: indexPath) as! ChannelCollectionViewCell
        if selectedCell.isFlipped == true{
            UIView.transition(with: selectedCell, duration: 0.5, options: .transitionFlipFromLeft, animations: {
                collectionView.isUserInteractionEnabled = false
                //selectedCell.previewImage.isHidden = false
                selectedCell.gameTitle.isHidden = false
                selectedCell.streamerName.isHidden = false
                selectedCell.viewerCount.isHidden = false
                selectedCell.addBtn.isHidden = true
                selectedCell.watchBtn.isHidden = true
                selectedCell.viewersIcon.isHidden = false
                selectedCell.addLabel.isHidden = true
                selectedCell.watchLabel.isHidden = true
            }, completion: { (Bool) in
                selectedCell.isFlipped = false
                collectionView.isUserInteractionEnabled = true
            })
        }
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
