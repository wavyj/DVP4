//
//  User.swift
//  PerspecTV
//
//  Created by Justin Coleman on 3/8/17.
//  Copyright © 2017 Justin Coleman. All rights reserved.
//

import Foundation
import UIKit

class User{
    var authToken: String
    var username: String
    var id: String
    var bio: String
    var logoUrl: String
    var image: UIImage!
    var bannerUrl: String
    var banner: UIImage!
    var views: Int
    var followers: Int
    
    init(authToken: String = "", username: String = "", id: String = "", bio: String = "One day I will think of a clever bio...", logoUrl: String = "", bannerUrl: String = "", views: Int = 0, followers: Int = 0) {
        self.authToken = authToken
        self.username = username
        self.id = id
        self.bio = bio
        self.logoUrl = logoUrl
        self.bannerUrl = bannerUrl
        self.views = views
        self.followers = followers
    }
    
    func downloadImage(){
        if let url = URL(string: logoUrl){
            do{
                let data = try Data(contentsOf: url)
                image = UIImage(data: data)
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
                banner = UIImage(data: data)
            }
            catch{
                print(error.localizedDescription)
            }
        }
    }
}
