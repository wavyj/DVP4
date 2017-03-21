//
//  Team.swift
//  PerspecTV
//
//  Created by Justin Coleman on 3/20/17.
//  Copyright © 2017 Justin Coleman. All rights reserved.
//

import Foundation
import UIKit

class Team{
    let id: Int
    let name: String
    let displayName: String
    var info: String
    var profilePicUrl: String
    var profilePic: UIImage!
    var bannerUrl: String
    var bannerImage: UIImage!
    var members = [(type: String, content: Channel)]()
    
    init(id: Int, name: String, displayName: String, info: String = "No info provided", profilePicUrl: String = "", bannerUrl: String = ""){
        self.id = id
        self.name = name
        self.displayName = displayName
        self.info = info
        self.profilePicUrl = profilePicUrl
        self.bannerUrl = bannerUrl
    }
    
    func downloadProfile(){
        if let url = URL(string: profilePicUrl){
            do{
                let data = try Data(contentsOf: url)
                profilePic = UIImage(data: data)
            }
            catch{
                print(error.localizedDescription)
            }
        }
    }
    
    func downloadBanner(){
        if let url = URL(string: bannerUrl){
            do{
                let data = try Data(contentsOf: url)
                bannerImage = UIImage(data: data)
            }
            catch{
                print(error.localizedDescription)
            }
        }
    }
}
