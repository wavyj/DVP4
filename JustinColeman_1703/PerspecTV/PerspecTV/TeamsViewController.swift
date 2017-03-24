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
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var teams = [Team]()
    var currentChannel = ""
    var selectedTeam: Team!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if appDelegate.isPhone == false{
            let layout = UICollectionViewFlowLayout()
            layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 10)
            layout.itemSize = CGSize(width: collectionView.frame.width / 1 - 20, height: collectionView.frame.height / 3)
            layout.minimumInteritemSpacing = 5
            layout.minimumLineSpacing = 10
            collectionView.collectionViewLayout = layout
        }else{
            let layout = UICollectionViewFlowLayout()
            layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 10)
            layout.itemSize = CGSize(width: view.frame.width - 20, height: collectionView.frame.height / 3)
            layout.minimumInteritemSpacing = 5
            layout.minimumLineSpacing = 10
            collectionView.collectionViewLayout = layout
        }
        
        channelLabel.text = "\(currentChannel)'s Teams"
        backIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.backTapped(_:))))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Storyboard Actions
    @IBAction func teamBack(_ segue: UIStoryboardSegue){
        //do nothing
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
        }else{
            cell.bannerImage.backgroundColor = UIColor.black
        }
        
        if current.profilePic != nil{
            cell.profilePic.image = current.profilePic
            cell.profilePic.layer.cornerRadius = 10
            cell.profilePic.layer.borderWidth = 3.0
            cell.profilePic.layer.borderColor = UIColor.white.cgColor
            cell.profilePic.clipsToBounds = true
        }else{
            cell.profilePic.backgroundColor = UIColor.white
        }
        cell.teamName.text = current.displayName
        cell.layer.cornerRadius = 6
        
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedTeam = teams[indexPath.row]
        performSegue(withIdentifier: "toSelectedTeam", sender: self)
    }
    
    //MARK: - Methods
    func backTapped(_ sender: UITapGestureRecognizer){
        performSegue(withIdentifier: "goBack", sender: self)
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "toSelectedTeam"{
            let STVC = segue.destination as! SelectedTeamViewController
            STVC.selectedTeam = selectedTeam
        }
    }
    

}
