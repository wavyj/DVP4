//
//  SearchViewController.swift
//  PerspecTV
//
//  Created by Justin Coleman on 3/12/17.
//  Copyright © 2017 Justin Coleman. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UITextViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource {

    //MARK: - Outlets
    @IBOutlet weak var searchBar: UIView!
    @IBOutlet weak var searchIcon: UIImageView!
    @IBOutlet weak var searchText: UITextView!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var scopeView: UIView!
    @IBOutlet weak var streamIcon: UIImageView!
    @IBOutlet weak var gameIcon: UIImageView!
    @IBOutlet weak var sortBtn: UIButton!
    @IBOutlet weak var scopeOriginY: NSLayoutConstraint!
    @IBOutlet weak var scopeMovedY: NSLayoutConstraint!
    @IBOutlet weak var activitySpinner: UIActivityIndicatorView!
    @IBOutlet weak var streamCollectionView: UICollectionView!
    @IBOutlet weak var gameCollectionView: UICollectionView!
    
    //MARK: - Variables
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var textToSearch = ""
    var isOpen = false
    var selectedScope = "Stream"
    var channels = [(type: String, content: Channel)]()
    var selectedChannel: (type: String, content: Channel)!
    var games = [Game]()
    var selectedGame: Game!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        searchIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.searchTapped(_:))))
        searchText.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.searchTapped(_:))))
        streamIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.scopeChanged(_:))))
        gameIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.scopeChanged(_:))))
        
        //Scope Setup
        var origImg = #imageLiteral(resourceName: "VideoCamIcon")
        var tintImg = origImg.withRenderingMode(.alwaysTemplate)
        streamIcon.image = tintImg
        streamIcon.tintColor = UIColor(colorLiteralRed: 52/255, green: 67/255, blue: 84/255, alpha: 1)
        origImg = #imageLiteral(resourceName: "GameIcon-Light")
        tintImg = origImg.withRenderingMode(.alwaysTemplate)
        gameIcon.image = tintImg
        gameIcon.tintColor = UIColor(white: 0, alpha: 0.5)
        
        //CollctionView Setup
        for i in [streamCollectionView, gameCollectionView]{
            let layout = UICollectionViewFlowLayout()
            layout.sectionInset = UIEdgeInsets(top: self.scopeView.frame.height + 10, left: 0, bottom: 0, right: 0)
            i?.collectionViewLayout = layout
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Storyboard Actions
    @IBAction func cancelTapped(_ sender: UIButton){
        scopeMovedY.isActive = false
        scopeOriginY.isActive = true
        UIView.animate(withDuration: 0.5, animations: {
            self.searchBar.layoutIfNeeded()
            self.scopeView.layoutIfNeeded()
            self.searchText.text = "Search"
            self.cancelBtn.isHidden = true
        }, completion: { (Bool) in
            self.isOpen = false
            self.searchText.resignFirstResponder()
            self.searchText.layoutIfNeeded()
            print("closed")
        })
    }
    
    //MARK: - TextView Callbacks
    func textViewDidChange(_ textView: UITextView) {
        textToSearch = textView.text
        activitySpinner.startAnimating()
        
        //Search selected text based on selected search type
        if selectedScope == "Stream"{
            streamCollectionView.isHidden = false
            gameCollectionView.isHidden = true
            if textToSearch != ""{
                downloadAndParse(urlString: "https://api.twitch.tv/kraken/search/streams?query=\(textToSearch)&client_id=\(appDelegate.consumerID)&\(appDelegate.apiVersion)", downloadTask: "Stream")
            }
        }else if selectedScope == "Game"{
            gameCollectionView.isHidden = true
            streamCollectionView.isHidden = false
            if textToSearch != ""{
                downloadAndParse(urlString: "https://api.twitch.tv/kraken/search/games?query=\(textToSearch)&client_id=\(appDelegate.consumerID)&\(appDelegate.apiVersion)", downloadTask: "Game")
            }
        }
        
    }
    
//    func textViewDidBeginEditing(_ textView: UITextView) {
//        
//    }
    
    //MARK: - Collection View Callbacks
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if selectedScope == "Stream"{
            return channels.count
        }else{
            return games.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView.tag {
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ChannelCollectionViewCell
            let current = channels[indexPath.row]
            cell.gameTitle.text = current.content.game
            cell.streamerName.text = current.content.username
            cell.viewerCount.text = current.content.viewers.description
            cell.previewImage.image = current.content.previewImage
            cell.layer.cornerRadius = 6
            cell.isFlipped = false
            return cell
        case 2:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! GameCollectionViewCell
            let currentGame = games[indexPath.row]
            if let image = currentGame.image{
                cell.gameImage.image = image
            }else{
                cell.gameLabel.text = currentGame.name
                cell.gameLabel.isHidden = false
            }
            return cell
        default:
            print("Mistakes were made.")
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView.tag {
        case 1:
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
        case 2:
            selectedGame = games[indexPath.row]
            performSegue(withIdentifier: "toSelectedGame", sender: self)
        default:
            print("Mistakes were made.")
        }
    }
    
    //MARK: - Methods
    func searchTapped(_ sender: UITapGestureRecognizer){
        if !isOpen{
            self.scopeOriginY.isActive = false
            self.scopeMovedY.isActive = true
            UIView.animate(withDuration: 0.5, animations: {
                self.scopeView.layoutIfNeeded()
                self.searchText.text = ""
                self.cancelBtn.isHidden = false
            }, completion: { (Bool) in
                self.isOpen = true
                self.searchText.becomeFirstResponder()
                self.searchText.layoutIfNeeded()
                print("opened")
            })
        }else{
            self.scopeMovedY.isActive = false
            self.scopeOriginY.isActive = true
            UIView.animate(withDuration: 0.5, animations: {
                self.scopeView.layoutIfNeeded()
                self.searchText.text = "Search"
                self.cancelBtn.isHidden = true
            }, completion: { (Bool) in
                self.isOpen = false
                self.searchText.resignFirstResponder()
                self.searchText.layoutIfNeeded()
                print("closed")
            })
        }
    }
    
    func scopeChanged(_ sender: UITapGestureRecognizer){
        let s = sender.view as! UIButton
        switch s.tag {
        case 1:
            selectedScope = "Stream"
            s.tintColor = UIColor(colorLiteralRed: 52/255, green: 67/255, blue: 84/255, alpha: 1)
            gameIcon.tintColor = UIColor(white: 0, alpha: 0.5)
        case 2:
            selectedScope = "Game"
            s.tintColor = UIColor(colorLiteralRed: 52/255, green: 67/255, blue: 84/255, alpha: 1)
            gameIcon.tintColor = UIColor(white: 0, alpha: 0.5)
        default:
            print("Mistakes were made.")
        }
        
        //Call Textview did change
        searchText.text = ""
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "toSelectedGame"{
            let SGVC = segue.destination as! SelectedGameViewController
            SGVC.currentGame = selectedGame
        }
    }
 

}
