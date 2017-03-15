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
    var channels = [Channel]()
    var offset = 0
    var selectedChannel: Channel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //Header View Setup
        //Gesture Recognizer for back arrow
        backArrow.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.backTapped(_:))))
        gameTitle.text = currentGame.name

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
        performSegue(withIdentifier: "toWatch", sender: self)
    }
    
    @IBAction func addTapped(_ sender: UIButton){
        //Adds selected stream to array of streams
        appDelegate.streams.append(selectedChannel)
        performSegue(withIdentifier: "toWatch", sender: self)
    }
    
    //MARK: - Collection View Data Source
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return channels.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ChannelCollectionViewCell
        let current = channels[indexPath.row]
        cell.streamerName.text = current.username
        cell.viewerCount.text = current.viewers.description
        cell.previewImage.image = current.previewImage
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
                    if Channel.username == self.selectedChannel.username{
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
            })
        }else{
            UIView.transition(with: selectedCell, duration: 0.5, options: .transitionFlipFromLeft, animations: {
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
            })
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        //Unflip the cell
        let selectedCell = collectionView.cellForItem(at: indexPath) as! ChannelCollectionViewCell
        UIView.transition(with: selectedCell, duration: 0.5, options: .transitionFlipFromLeft, animations: {
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
        })
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
        performSegue(withIdentifier: "selectedgameBackTapped", sender: self)
    }
    
    func update(){
        channels.removeAll()
        collectionView.reloadData()
        
        let gameName = currentGame.name
        //remove spaces from name
        let gameNameUrl = gameName.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        downloadAndParse(urlString: "https://api.twitch.tv/kraken/search/streams?query=\(gameNameUrl)&limit=10&offset=\(offset)&client_id=\(appDelegate.consumerID)&\(appDelegate.apiVersion)")
    }

    
    /*// MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }*/
 

}
