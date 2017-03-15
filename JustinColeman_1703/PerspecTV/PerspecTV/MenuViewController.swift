//
//  MenuViewController.swift
//  PerspecTV
//
//  Created by Justin Coleman on 3/14/17.
//  Copyright © 2017 Justin Coleman. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    //MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var editBtn: UIButton!
    
    //MARK: - Variables
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var streams = [Channel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        streams = appDelegate.streams
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Storyboard Actions
    @IBAction func editTapped(_ sender: UIButton){
        //Enable/Disable Editing
        tableView.setEditing(!tableView.isEditing, animated: true)
        if tableView.isEditing{
            editBtn.imageView?.image = UIImage(named: "DoneIcon")
        }else{
            editBtn.imageView?.image = UIImage(named: "EditIcon")
        }
        
    }
    
    //MARK: - TableView callbacks
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return streams.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)as! StreamTableViewCell
        let currentChannel = streams[indexPath.row]
        
        cell.username.text = currentChannel.username
        cell.game.text = currentChannel.game
        cell.preview.image = currentChannel.previewImage
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
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
