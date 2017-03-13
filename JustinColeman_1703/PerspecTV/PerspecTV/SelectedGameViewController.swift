//
//  SelectedGameViewController.swift
//  PerspecTV
//
//  Created by Justin Coleman on 3/12/17.
//  Copyright © 2017 Justin Coleman. All rights reserved.
//

import UIKit

class SelectedGameViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

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
        downloadAndParse(urlString: "https://api.twitch.tv/kraken/search/streams?query=\(gameNameUrl)&client_id=\(appDelegate.consumerID)&\(appDelegate.apiVersion)")
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

    
    //MARK: - Methods
    func backTapped(_ sender: UITapGestureRecognizer){
        performSegue(withIdentifier: "selectedgameBackTapped", sender: self)
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
