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
    @IBOutlet weak var activitySpinner: UIActivityIndicatorView!
    @IBOutlet weak var streamCollectionView: UICollectionView!
    
    //MARK: - Variables
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var textToSearch = ""
    var isOpen = false
    var selectedScope = "Stream"
    var channels = [(type: String, content: Channel)]()
    var channelsToDownload = [String]()
    var selectedChannel: (type: String, content: Channel)!
    var games = [Game]()
    var selectedGame: Game!
    var offset = 0
    var origin: CGRect!
    
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
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: 350, height: 170)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 15
        streamCollectionView.collectionViewLayout = layout
        
        searchText.delegate = self
        
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
    
    @IBAction func cancelTapped(_ sender: UIButton){
        if isOpen{
            UIView.animate(withDuration: 0.5, animations: {
                self.scopeView.frame = self.scopeView.frame.offsetBy(dx: 0, dy: -self.searchBar.frame.height)
                self.searchText.text = "Search"
                self.cancelBtn.isHidden = true
                self.searchText.resignFirstResponder()
            }, completion: { (Bool) in
                self.isOpen = false
                self.scopeView.isHidden = true
                self.scopeView.frame = self.origin
            })
        }
    }
    
    @IBAction func filterTapped(_ sender: UIButton){
        if selectedScope == "Stream"{
            switch sender.tag {
            case 1:
                sortBtn.setImage(#imageLiteral(resourceName: "ArrowUpIcon"), for: .normal)
                sortBtn.tag = 2
                sortBtn.setTitle("A-Z", for: .normal)
                
                //Sort
                if channels.count > 0{
                    channels = channels.sorted(by: { (A, B) -> Bool in
                        A.content.username.lowercased() < B.content.username.lowercased()   
                    })
                    streamCollectionView.reloadData()
                }
            case 2:
                sortBtn.setImage(#imageLiteral(resourceName: "DownArrowIcon"), for: .normal)
                sortBtn.tag = 3
                sortBtn.setTitle("A-Z", for: .normal)
                
                //Sort
                if channels.count > 0{
                    channels = channels.sorted(by: { (A, B) -> Bool in
                        A.content.username.lowercased() > B.content.username.lowercased()
                    })
                    streamCollectionView.reloadData()
                }
            case 3:
                sortBtn.setImage(#imageLiteral(resourceName: "ArrowUpIcon"), for: .normal)
                sortBtn.tag = 4
                sortBtn.setTitle("Viewers", for: .normal)
                
                //Sort
                if channels.count > 0{
                    channels = channels.sorted(by: { (A, B) -> Bool in
                        A.content.viewers > B.content.viewers
                    })
                    streamCollectionView.reloadData()
                }
            case 4:
                sortBtn.setImage(#imageLiteral(resourceName: "DownArrowIcon"), for: .normal)
                sortBtn.tag = 1
                sortBtn.setTitle("Viewers", for: .normal)
                
                //Sort
                if channels.count > 0{
                    channels = channels.sorted(by: { (A, B) -> Bool in
                        A.content.viewers < B.content.viewers
                    })
                    streamCollectionView.reloadData()
                }
            default:
                print("Mistakes were made.")
            }
        }
    }
    
    //MARK: - TextView Callbacks
    func textViewDidChange(_ textView: UITextView) {
        textToSearch = textView.text
        
        //Search selected text based on selected search type
        if textToSearch != ""{
            activitySpinner.isHidden = false
            activitySpinner.startAnimating()
            
            if selectedScope == "Stream"{
                channels.removeAll()
                downloadAndParse(urlString: "https://api.twitch.tv/kraken/search/channels?query=\(textToSearch)&limit=50&offset=\(offset)&client_id=\(appDelegate.consumerID)&\(appDelegate.apiVersion)", downloadTask: "Stream")
            }else if selectedScope == "Game"{
                games.removeAll()
                downloadAndParse(urlString: "https://api.twitch.tv/kraken/search/games?query=\(textToSearch)&limit=10&offset=\(offset)&client_id=\(appDelegate.consumerID)&\(appDelegate.apiVersion)", downloadTask: "Game")
            }
        }else{
            channels.removeAll()
            games.removeAll()
            streamCollectionView.reloadData()
        }
        
    }
    
    //MARK: - Collection View Callbacks
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0{
            return channels.count
        }else{
            return games.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "stream", for: indexPath) as! ChannelCollectionViewCell
            let current = channels[indexPath.row]
            cell.gameTitle.text = current.content.game
            cell.streamerName.text = current.content.username
            cell.viewerCount.text = current.content.viewers.description
            cell.previewImage.image = current.content.previewImage
            cell.layer.cornerRadius = 6
            cell.isFlipped = false
            return cell
        }else if indexPath.section == 1{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "game", for: indexPath) as! GameCollectionViewCell
            let currentGame = games[indexPath.row]
            if let image = currentGame.image{
                cell.gameImage.image = image
            }else{
                cell.gameLabel.text = currentGame.name
                cell.gameLabel.isHidden = false
            }
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
            return cell
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.section{
        case 0:
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
        case 1:
            selectedGame = games[indexPath.row]
            performSegue(withIdentifier: "toSelectedGame", sender: self)
        default:
            print("Mistakes were made.")
        }
    }
    
    //MARK: - Methods
    func searchTapped(_ sender: UITapGestureRecognizer){
        if !isOpen{
            origin = scopeView.frame
            scopeView.frame = scopeView.frame.offsetBy(dx: 0, dy: -searchBar.frame.height)
            scopeView.isHidden = false
            UIView.animate(withDuration: 0.5, animations: {
                self.scopeView.frame = self.origin
                self.searchText.text = ""
                self.cancelBtn.isHidden = false
                self.searchText.becomeFirstResponder()
            }, completion: { (Bool) in
                self.isOpen = true
            })
        }else{
            UIView.animate(withDuration: 0.5, animations: {
                self.scopeView.frame = self.scopeView.frame.offsetBy(dx: 0, dy: -self.searchBar.frame.height)
                self.searchText.text = "Search"
                self.cancelBtn.isHidden = true
                
                self.searchText.resignFirstResponder()
            }, completion: { (Bool) in
                self.isOpen = false
                self.scopeView.isHidden = true
                self.scopeView.frame = self.origin
            })
        }
    }
    
    func scopeChanged(_ sender: UITapGestureRecognizer){
        let s = sender.view as! UIImageView
        switch s.tag {
        case 1:
            selectedScope = "Stream"
            s.tintColor = UIColor(colorLiteralRed: 52/255, green: 67/255, blue: 84/255, alpha: 1)
            gameIcon.tintColor = UIColor(white: 0, alpha: 0.5)
            channels.removeAll()
            games.removeAll()
            sortBtn.isEnabled = true
            streamCollectionView.reloadData()
            let layout = UICollectionViewFlowLayout()
            layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 10)
            layout.itemSize = CGSize(width: 350, height: 170)
            layout.minimumInteritemSpacing = 10
            layout.minimumLineSpacing = 15
            streamCollectionView.collectionViewLayout = layout
        case 2:
            selectedScope = "Game"
            s.tintColor = UIColor(colorLiteralRed: 52/255, green: 67/255, blue: 84/255, alpha: 1)
            streamIcon.tintColor = UIColor(white: 0, alpha: 0.5)
            channels.removeAll()
            games.removeAll()
            sortBtn.isEnabled = false
            streamCollectionView.reloadData()
            let layout = UICollectionViewFlowLayout()
            layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 10)
            layout.itemSize = CGSize(width: 150, height: 200)
            layout.minimumInteritemSpacing = 10
            layout.minimumLineSpacing = 10
            streamCollectionView.collectionViewLayout = layout
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
