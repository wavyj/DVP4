//
//  FollowingViewController.swift
//  PerspecTV
//
//  Created by Justin Coleman on 3/8/17.
//  Copyright © 2017 Justin Coleman. All rights reserved.
//

import UIKit

//Global resuse identifier
private let cellID = "cell"

class FollowingViewController: UIViewController , UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate{

    //MARK: - Outlets
    @IBOutlet weak var activitySpinner: UIActivityIndicatorView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    //MARK: - Variables
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var currentUser: User!
    var channels = [(type: String, content: Channel)]()
    var userLoggedIn = false
    var channelsToDownload = [String]()
    var offset = 0
    var selectedChannel: (type: String, content: Channel)!
    var isMenuOpen = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        currentUser = appDelegate.currentUser
        if appDelegate.isPhone == false{
            self.splitViewController?.preferredDisplayMode = .primaryHidden
            let layout = UICollectionViewFlowLayout()
            layout.itemSize = CGSize(width: (self.view.frame.width / 2 - 20), height: self.collectionView.frame.height / 3.5)
            layout.minimumInteritemSpacing = 2
            layout.minimumLineSpacing = 10
            layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 10)
            collectionView.collectionViewLayout = layout
        }else{
            let layout = UICollectionViewFlowLayout()
            layout.itemSize = CGSize(width: (self.view.frame.width - 20), height: self.collectionView.frame.height / 3.5)
            layout.minimumInteritemSpacing = 10
            layout.minimumLineSpacing = 15
            layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 10)
            collectionView.collectionViewLayout = layout
        }
        
        if userLoggedIn == true{
            downloadandParse(urlString: "https://api.twitch.tv/kraken/users/\(currentUser.id)/follows/channels?limit=10&offset=\(offset)&client_id=\(appDelegate.consumerID)&\(appDelegate.apiVersion)", downloadTask: "User Followed")
        }else{
            downloadandParse(urlString: "https://api.twitch.tv/kraken/streams/followed?oauth_token=\(currentUser.authToken)&limit=10&offset\(offset)&stream_type=live&client_id=\(appDelegate.consumerID)&\(appDelegate.apiVersion)", downloadTask: "Followed Live")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //Unflip selected 
        if let selected = collectionView.indexPathsForSelectedItems?.first{
            collectionView.deselectItem(at: selected, animated: false)
            let selectedCell = collectionView.cellForItem(at: selected) as! ChannelCollectionViewCell
            UIView.transition(with: selectedCell, duration: 0.5, options: .transitionFlipFromLeft, animations: {
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
            })
        }
    }
    
    //MARK: - Storyboard Actions
    @IBAction func hamMenuTapped(_ sender: UIButton){
        if isMenuOpen{
            UIView.animate(withDuration: 0.5, animations: {
                self.splitViewController?.preferredDisplayMode = .primaryHidden
            }, completion: { (Bool) in
                self.collectionView.isUserInteractionEnabled = true
                self.isMenuOpen = false
            })
        }else{
            UIView.animate(withDuration: 0.5, animations: {
                self.splitViewController?.preferredDisplayMode = .allVisible
            }, completion: { (Bool) in
                self.collectionView.isUserInteractionEnabled = false
                self.isMenuOpen = true
            })
        }
    }
    
    @IBAction func watchTapped(_ sender: UIButton){
        //Clears array and sets the selected channel to the only stream
        appDelegate.streams = [selectedChannel]
        if appDelegate.isPhone == true{
            self.tabBarController?.selectedIndex = 2
        }else{
            performSegue(withIdentifier: "toDetail", sender: self)
        }
    }
    
    @IBAction func addTapped(_ sender: UIButton){
        //Adds selected stream to array of streams
        appDelegate.streams.append(selectedChannel)
        if appDelegate.isPhone == true{
            self.tabBarController?.selectedIndex = 2
        }else{
            performSegue(withIdentifier: "toDetail", sender: self)
        }
    }
    
    //MARK: - Collection View Data Source
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return channels.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! ChannelCollectionViewCell
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
    
    //MARK: - Scrollview Callbacks
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
            let scrollViewHeight = scrollView.frame.size.height
            let scrollViewContentSize = scrollView.contentSize.height
            let scrollOffset = scrollView.contentOffset.y
            
            if scrollOffset == 0 && offset != 0{
                //At the top
                offset -= 10
                update()
            }else if scrollOffset + scrollViewHeight == scrollViewContentSize && channels.count == 10{
                //At the bottom
                offset += 10
                update()
            }
    }
    
    //MARK: - Methods
    func update(){
        channels.removeAll()
        collectionView.reloadData()
        downloadandParse(urlString: "https://api.twitch.tv/kraken/users/\(currentUser.id)/follows/channels?limit=10&offset=\(offset)&client_id=\(appDelegate.consumerID)&\(appDelegate.apiVersion)", downloadTask: "User Followed")
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "toWatch"{
            let WVC = segue.destination as! WatchViewController
            WVC.currentChannel = selectedChannel
        }
        
        if segue.identifier == "toDetail"{
            let nav = segue.destination as! UINavigationController
            let DVC = nav.viewControllers.first as! DetailViewController
            DVC.segueTo = "ipadToWatch"
        }
    }

}
