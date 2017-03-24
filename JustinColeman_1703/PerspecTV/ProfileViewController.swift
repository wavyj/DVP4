//
//  ProfileViewController.swift
//  PerspecTV
//
//  Created by Justin Coleman on 3/20/17.
//  Copyright © 2017 Justin Coleman. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate{
    
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
    @IBOutlet weak var warningView: UIView!
    @IBOutlet weak var videoIcon: UIImageView!
    
    
    //MARK: - Variables
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var currentUser: User!
    var currentID = ""
    var teams = [Team]()
    var tempTeams = [Team]()
    var channelsToDownload = [String]()
    var videos = [(type: String, content: Channel)]()
    var selectedVideo: (type: String, content: Channel)!
    var offset = 0
    var iterator = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if appDelegate.isPhone == false{
            let layout = UICollectionViewFlowLayout()
            layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 10)
            layout.itemSize = CGSize(width: collectionView.frame.width / 1 - 20, height: collectionView.frame.height / 2.5)
            layout.minimumInteritemSpacing = 5
            layout.minimumLineSpacing = 10
            collectionView.collectionViewLayout = layout
        }else{
            let layout = UICollectionViewFlowLayout()
            layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 10)
            layout.itemSize = CGSize(width: view.frame.width - 20, height: collectionView.frame.height / 2)
            layout.minimumInteritemSpacing = 5
            layout.minimumLineSpacing = 10
            collectionView.collectionViewLayout = layout
        }
        teamIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.teamTapped(_:))))
        backArrow.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.backTapped(_:))))
        let origImg = #imageLiteral(resourceName: "StarIcon")
        let tintedImg = origImg.withRenderingMode(.alwaysTemplate)
        teamIcon.image = tintedImg
        teamIcon.tintColor = UIColor(white: 1, alpha: 0.4)
        
        currentUser = User()
        downloadAndParse(urlString: "https://api.twitch.tv/kraken/channels/\(currentID)?client_id=\(appDelegate.consumerID)&\(appDelegate.apiVersion)", downloadTask: "profile")
        
        downloadAndParse(urlString: "https://api.twitch.tv/kraken/channels/\(currentID)/videos?limit=10&offset=\(offset)&client_id=\(appDelegate.consumerID)&\(appDelegate.apiVersion)", downloadTask: "videos")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Collection View Callbacks
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ChannelCollectionViewCell
        let current = videos[indexPath.row]
        cell.streamerName.text = current.content.title
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
        selectedVideo = videos[indexPath.row]
        let selectedCell = collectionView.cellForItem(at: indexPath) as! ChannelCollectionViewCell
        if selectedCell.isFlipped == false{
            UIView.transition(with: selectedCell, duration: 0.5, options: .transitionFlipFromRight, animations: {
                collectionView.isUserInteractionEnabled = false
                //selectedCell.previewImage.isHidden = true
                selectedCell.streamerName.isHidden = true
                selectedCell.viewerCount.isHidden = true
                selectedCell.addBtn.isHidden = false
                selectedCell.watchBtn.isHidden = false
                selectedCell.viewersIcon.isHidden = true
                selectedCell.addLabel.isHidden = false
                selectedCell.watchLabel.isHidden = false
                
                //Check current streams
                let streams = self.appDelegate.streams!
                if !streams.contains(where: { (Video) -> Bool in
                    if Video.content.videoID == self.selectedVideo.content.videoID{
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
    
    //MARK: - Scrollview Callbacks
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let scrollViewHeight = scrollView.frame.size.height
        let scrollViewContentSize = scrollView.contentSize.height
        let scrollOffset = scrollView.contentOffset.y
        
        if scrollOffset == 0 && offset != 0{
            //At the top
            offset -= 10
            updateVideos()
        }else if scrollOffset + scrollViewHeight == scrollViewContentSize && videos.count == 10{
            //At the bottom
            offset += 10
            updateVideos()
        }
    }
    
    //MARK: - Storyboard Actions
    @IBAction func profileBack(_ segue: UIStoryboardSegue){
        //do nothing
    }
    
    @IBAction func watchTapped(_ sender: UIButton){
        //Clears array and sets the selected channel to the only stream
        appDelegate.streams = [selectedVideo]
        if appDelegate.isPhone == true{
            performSegue(withIdentifier: "toWatch", sender: self)
        }else{
            performSegue(withIdentifier: "toDetail", sender: self)
        }
    }
    
    @IBAction func addTapped(_ sender: UIButton){
        //Adds selected stream to array of streams
        appDelegate.streams.append(selectedVideo)
        if appDelegate.isPhone == true{
            performSegue(withIdentifier: "toWatch", sender: self)
        }else{
            performSegue(withIdentifier: "toDetail", sender: self)
        }
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
        bannerImage.clipsToBounds = true
        profileView.isHidden = false
        activitySpinner.stopAnimating()
    }
    
    func updateVideos(){
        videos.removeAll()
        collectionView.reloadData()
        
        downloadAndParse(urlString: "https://api.twitch.tv/kraken/channels/\(currentID)/videos?limit=10&offset=\(offset)&client_id=\(appDelegate.consumerID)&\(appDelegate.apiVersion)", downloadTask: "videos")
        
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
