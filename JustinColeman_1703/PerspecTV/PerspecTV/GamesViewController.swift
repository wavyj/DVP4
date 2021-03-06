//
//  GamesViewController.swift
//  PerspecTV
//
//  Created by Justin Coleman on 3/12/17.
//  Copyright © 2017 Justin Coleman. All rights reserved.
//

import UIKit

class GamesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate {

    //MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activitySpinner: UIActivityIndicatorView!
    
    //MARK: - Variables
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var offset = 0
    var games = [Game]()
    var selectedGame: Game!
    var layout: UICollectionViewFlowLayout!
    var isMenuOpen = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if appDelegate.isPhone == false{
            self.splitViewController?.preferredDisplayMode = .primaryHidden
            
            layout = UICollectionViewFlowLayout()
            layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 10)
            layout.itemSize = CGSize(width: collectionView.frame.width / 2, height: collectionView.frame.height / 2.5)
            layout.minimumInteritemSpacing = 5
            layout.minimumLineSpacing = 10
            collectionView.collectionViewLayout = layout
        }else{
            layout = UICollectionViewFlowLayout()
            layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 10)
            layout.itemSize = CGSize(width: collectionView.frame.width / 2 - 20, height: collectionView.frame.height / 3)
            layout.minimumInteritemSpacing = 2
            layout.minimumLineSpacing = 10
            collectionView.collectionViewLayout = layout
        }
        downloadAndParse(urlString: "https://api.twitch.tv/kraken/games/top?limit=10&offset=\(offset)&client_id=\(appDelegate.consumerID)&\(appDelegate.apiVersion)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    @IBAction func back(for segue: UIStoryboardSegue){
        //do nothing
    }
    
    //MARK: - UICollectionView Delegate Callbacks
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return games.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! GameCollectionViewCell
        let currentGame = games[indexPath.row]
        if let image = currentGame.image{
            cell.gameImage.image = image
        }else{
            cell.gameLabel.text = currentGame.name
            cell.gameLabel.isHidden = false
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedGame = games[indexPath.row]
        performSegue(withIdentifier: "toSelectedGame", sender: self)
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
        }else if scrollOffset + scrollViewHeight == scrollViewContentSize && games.count == 10{
            //At the bottom
            offset += 10
            update()
        }
    }

    //MARK: - Methods
    func update(){
        games.removeAll()
        collectionView.reloadData()
        downloadAndParse(urlString: "https://api.twitch.tv/kraken/games/top?limit=10&offset=\(offset)&client_id=\(appDelegate.consumerID)&\(appDelegate.apiVersion)")
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let SGVC: SelectedGameViewController = segue.destination as! SelectedGameViewController
        SGVC.currentGame = selectedGame
    }

}
