//
//  SelectedGameViewController.swift
//  PerspecTV
//
//  Created by Justin Coleman on 3/12/17.
//  Copyright © 2017 Justin Coleman. All rights reserved.
//

import UIKit

class SelectedGameViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate {

    //MARK: - Outlets
    @IBOutlet weak var backArrow: UIImageView!
    @IBOutlet weak var gameTitle: UILabel!
    @IBOutlet weak var activitSpinner: UIActivityIndicatorView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var gameImage: UIImageView!
    @IBOutlet weak var gameView: UIView!
    @IBOutlet weak var totalViewersLabel: UILabel!
    @IBOutlet weak var totalChannelsLabel: UILabel!
    
    //MARK: - Variables
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var currentGame: Game!
    var channels = [(type: String, content: Channel)]()
    var offset = 0
    var selectedChannel: (type: String, content: Channel)!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //Header View Setup
        //Gesture Recognizer for back arrow
        backArrow.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.backTapped(_:))))
        gameTitle.text = currentGame.name

        if appDelegate.isPhone == false{
            self.splitViewController?.preferredDisplayMode = .primaryHidden
            
            let layout = UICollectionViewFlowLayout()
            layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 10)
            layout.itemSize = CGSize(width: collectionView.frame.width / 1 - 20, height: collectionView.frame.height / 2.5)
            layout.minimumInteritemSpacing = 2
            layout.minimumLineSpacing = 10
            collectionView.collectionViewLayout = layout
        }else{
            let layout = UICollectionViewFlowLayout()
            layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 10)
            layout.itemSize = CGSize(width: collectionView.frame.width - 20, height: collectionView.frame.height / 3)
            layout.minimumInteritemSpacing = 5
            layout.minimumLineSpacing = 10
            collectionView.collectionViewLayout = layout
        }
        
        //Game View Setup
        gameView.clipsToBounds = true
        gameImage.image = currentGame.image
        gameImage.clipsToBounds = true
        totalViewersLabel.text = currentGame.viewers.description
        totalChannelsLabel.text = currentGame.channels.description
        
        //Initial Download
        let gameName = currentGame.name
        //remove spaces from name
        let gameNameUrl = gameName.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        downloadAndParse(urlString: "https://api.twitch.tv/kraken/search/streams?query=\(gameNameUrl)&limit=10&offset=\(offset)&client_id=\(appDelegate.consumerID)&\(appDelegate.apiVersion)")
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
            performSegue(withIdentifier: "toDetailWatch", sender: self)
        }
    }
    
    @IBAction func addTapped(_ sender: UIButton){
        //Adds selected stream to array of streams
        appDelegate.streams.append(selectedChannel)
        if appDelegate.isPhone == true{
            performSegue(withIdentifier: "toWatch", sender: self)
        }else{
            performSegue(withIdentifier: "toDetailWatch", sender: self)
        }
    }
    
    @IBAction func fromSearch(_ segue: UIStoryboardSegue){
        //do nothing
    }
    
    //MARK: - Collection View Data Source
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return channels.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ChannelCollectionViewCell
        let current = channels[indexPath.row]
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

    //MARK: - Scrollbar Callbacks
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
    func backTapped(_ sender: UITapGestureRecognizer){
        if appDelegate.isPhone == true{
            performSegue(withIdentifier: "selectedgameBackTapped", sender: self)
        }else{
            performSegue(withIdentifier: "toDetail", sender: self)
        }
    }
    
    func update(){
        channels.removeAll()
        collectionView.reloadData()
        
        let gameName = currentGame.name
        //remove spaces from name
        let gameNameUrl = gameName.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        downloadAndParse(urlString: "https://api.twitch.tv/kraken/search/streams?query=\(gameNameUrl)&limit=10&offset=\(offset)&client_id=\(appDelegate.consumerID)&\(appDelegate.apiVersion)")
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "toDetail"{
            let nav = segue.destination as! UINavigationController
            let DVC = nav.viewControllers.first as! DetailViewController
            DVC.segueTo = "ipadToGames"
        }else if segue.identifier == "toDetailWatch"{
            let nav = segue.destination as! UINavigationController
            let DVC = nav.viewControllers.first as! DetailViewController
            DVC.segueTo = "ipadToWatch"
        }
    }
 

}
