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
    @IBOutlet weak var doneBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    
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
    @IBAction func backTapped(){
        if appDelegate.isPhone == true{
            performSegue(withIdentifier: "toMenu", sender: self)
        }else{
            performSegue(withIdentifier: "toDetail", sender: self)
        }
    }
    
    @IBAction func editTapped(_ sender: UIButton){
        //Enable/Disable Editing
        tableView.setEditing(!tableView.isEditing, animated: true)
        if tableView.isEditing{
            doneBtn.isHidden = false
            editBtn.isHidden = true
            if streams.count > 1{
                deleteBtn.isHidden = false
            }
        }else{
            doneBtn.isHidden = true
            editBtn.isHidden = false
            deleteBtn.isHidden = true
        }
    }
    
    @IBAction func clear(_ sender: UIButton){
        //Alert
        let alert = UIAlertController(title: "Remove All?", message: "Are you sure you want to remove all streams?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .destructive) { (YesAction) in
            //Remove all
            self.streams.removeAll()
            self.tableView.reloadData()
        }
        let noAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        alert.addAction(yesAction)
        alert.addAction(noAction)
        present(alert, animated: true, completion: nil)
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
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        //Delete Channel
        if editingStyle == .delete{
            streams.remove(at: indexPath.row)
            appDelegate.streams = streams
            //Update tableView
            tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        //Move Channels in tableview and array
        let itemToMove = streams[sourceIndexPath.row]
        streams.remove(at: sourceIndexPath.row)
        streams.insert(itemToMove, at: destinationIndexPath.row)
        appDelegate.streams = streams
        tableView.moveRow(at: sourceIndexPath, to: destinationIndexPath)
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if streams.count <= 1 {
            return false
        }else{
            return true
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "toDetail"{
            let nav = segue.destination as! UINavigationController
            let DVC = nav.viewControllers.first as! DetailViewController
            DVC.segueTo = "ipadToWatch"
        }
    }

}
