//
//  SelectedGameViewController.swift
//  PerspecTV
//
//  Created by Justin Coleman on 3/12/17.
//  Copyright © 2017 Justin Coleman. All rights reserved.
//

import UIKit

class SelectedGameViewController: UIViewController {

    //MARK: - Outlets
    @IBOutlet weak var backArrow: UIImageView!
    @IBOutlet weak var gameTitle: UILabel!
    
    //MARK: - Variables
    var currentGame: Game!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //Gesture Recognizer for back arrow
        backArrow.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.backTapped(_:))))
        gameTitle.text = currentGame.name
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
