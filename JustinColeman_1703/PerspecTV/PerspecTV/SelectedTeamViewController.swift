//
//  SelectedTeamViewController.swift
//  PerspecTV
//
//  Created by Justin Coleman on 3/21/17.
//  Copyright © 2017 Justin Coleman. All rights reserved.
//

import UIKit

class SelectedTeamViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate {

    //MARK: - Outlets
    @IBOutlet weak var teamView: UIView!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var teamName: UILabel!
    @IBOutlet weak var membersCount: UILabel!
    @IBOutlet weak var backArrow: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    //MARK: - Variables
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var channels = [(type: String, content: Channel)]()
    var selectedChannel: (type: String, content: Channel)!
    var offset = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        backArrow.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.backTapped(_:))))
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Storyboard Actions
    
    
    //MARK: - Collection View Callbacks
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 0
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
