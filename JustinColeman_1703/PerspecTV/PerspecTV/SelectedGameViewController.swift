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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //Gesture Recognizer for back arrow
        
        //Header View Setup
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
        return cell
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
