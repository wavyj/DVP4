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

class FollowingViewController: UIViewController , UICollectionViewDelegate, UICollectionViewDataSource{

    //MARK: - Outlets
    @IBOutlet weak var activitySpinner: UIActivityIndicatorView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    //MARK: - Variables
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var currentUser: User!
    var channels = [Channel]()
    var userLoggedIn = false
    var channelsToDownload = [String]()
    var isLive = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let nav = self.navigationController{
            nav.viewControllers.remove(at: 0)
        }
        currentUser = appDelegate.currentUser
        if userLoggedIn == true{
            downloadandParse(urlString: "https://api.twitch.tv/kraken/users/\(currentUser.id)/follows/channels?client_id=\(appDelegate.consumerID)&\(appDelegate.apiVersion)", downloadTask: "User Followed")
        }else{
            downloadandParse(urlString: "https://api.twitch.tv/kraken/streams/followed?oauth_token=\(currentUser.authToken)&stream_type=live&client_id=\(appDelegate.consumerID)&\(appDelegate.apiVersion)", downloadTask: "Followed Live")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func viewAll(){
        //Get all channels the user follows
        isLive = false
        //The download string is handled inside the 'UserLoggedInTask'
        downloadandParse(urlString: "", downloadTask: "User Followed")
    }
    
    //MARK: - Collection View Data Source
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return channels.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! ChannelCollectionViewCell
        let current = channels[indexPath.row]
        cell.gameTitle.text = current.game
        cell.streamerName.text = current.username
        cell.viewerCount.text = "\(current.viewers) Viewers"
        cell.previewImage.image = current.previewImage
        return cell
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
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