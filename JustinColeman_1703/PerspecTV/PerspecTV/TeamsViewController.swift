//
//  TeamsViewController.swift
//  PerspecTV
//
//  Created by Justin Coleman on 3/20/17.
//  Copyright © 2017 Justin Coleman. All rights reserved.
//

import UIKit

class TeamsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    //MARK: - Outlets
    @IBOutlet weak var channelLabel: UILabel!
    @IBOutlet weak var backIcon: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    //MARK: - Variables
    var teams = [Team]()
    var currentChannel = ""
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        channelLabel.text = "\(currentChannel)'s Teams"
        backIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.backTapped(_:))))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Collection View Callbacks
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return teams.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! TeamCollectionViewCell
        let current = teams[indexPath.row]
        
        if current.bannerImage != nil{
            cell.bannerImage.image = current.bannerImage
        }
        if current.profilePic != nil{
            cell.profilePic.image = current.profilePic
        }
        cell.teamName.text = current.name
        
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    //MARK: - Methods
    func backTapped(_ sender: UITapGestureRecognizer){
        performSegue(withIdentifier: "goBack", sender: self)
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
