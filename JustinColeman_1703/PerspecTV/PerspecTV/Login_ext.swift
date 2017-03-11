//
//  Login_ext.swift
//  PerspecTV
//
//  Created by Justin Coleman on 3/8/17.
//  Copyright © 2017 Justin Coleman. All rights reserved.
//

import Foundation

extension LoginViewController{
    
    func downloadandParse(urlString: String, downloadTask: String){
       
        activitySpinner.startAnimating()
        loginBtn.isHidden = true
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        //Check if the passed in url is valid
        if let validUrl = URL(string: urlString){
            let task = session.dataTask(with: validUrl, completionHandler: { (data, response, error) in
                
                //Leave if an error occurs
                if error != nil { return }
                
                //Check response, data, and status code
                guard let response = response as? HTTPURLResponse,
                    response.statusCode == 200,
                    let data = data
                    else{ print(error?.localizedDescription ?? "Unknown Error"); return }
                
                do{
                    //De-serialize json data
                    if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]{
                        
                        //Parse json data
                            if let id = json["_id"] as? String,
                                let username = json["name"] as? String{
                                
                                //bio and profile pic can return null or empty so 
                                //a seperate check to see if they are there
                                if let bio = json["bio"] as? String{
                                    self.currentUser.bio = bio
                                }
                                
                                if let profileUrl = json["logo"] as? String{
                                    self.currentUser.logoUrl = profileUrl
                                }
                                
                                //Model object
                                self.currentUser.id = id
                                self.currentUser.username = username
                                self.currentUser.downloadImage()
                                self.appDelegate.currentUser = self.currentUser
                                
                            }else{ print(json) }
                        }
                    }
                catch{
                    print(error.localizedDescription)
                }
                self.downloadandParse(urlString: "https://api.twitch.tv/kraken/channels/\(self.currentUser.id)?client_id=\(self.appDelegate.consumerID)&\(self.appDelegate.apiVersion)", downloadTask: "Channel")
            })
            //Downloads the extra data not provided in the User node
            let userChannelTask = session.dataTask(with: validUrl, completionHandler: { (data, response, error) in
                
                //Leave if an error occurs
                if error != nil { return }
                
                //Check response, data, and status code
                guard let response = response as? HTTPURLResponse,
                    response.statusCode == 200,
                    let data = data
                    else{ print(error?.localizedDescription ?? "Unknown Error"); return }
                
                do{
                    //De-serialize json data
                    if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]{
                        
                        //Parse json data
                        if let views = json["views"] as? Int,
                            let followers = json["followers"] as? Int{
                            
                            //profile banner can return null or empty so
                            //a seperate check to see if they are there
                            if let bannerUrl = json["profile_banner"] as? String{
                                self.currentUser.bannerUrl = bannerUrl
                            }
                            
                            //Model object
                            self.currentUser.views = views
                            self.currentUser.followers = followers
                            self.currentUser.downloadBanner()
                            self.appDelegate.currentUser = self.currentUser
                            
                        }else{ print(json) }
                    }
                }
                catch{
                    print(error.localizedDescription)
                }
                //Save User Defaults
                self.save()
                DispatchQueue.main.async {
                    self.activitySpinner.stopAnimating()
                    self.performSegue(withIdentifier: "toFollowing", sender: self)
                }
            })
            if downloadTask == "User"{
                task.resume()
            }else if downloadTask == "Channel"{
                userChannelTask.resume()
            }
        }
    }
}
