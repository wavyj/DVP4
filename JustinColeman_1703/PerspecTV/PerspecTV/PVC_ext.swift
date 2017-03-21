//
//  PVC_ext.swift
//  PerspecTV
//
//  Created by Justin Coleman on 3/20/17.
//  Copyright © 2017 Justin Coleman. All rights reserved.
//

import Foundation
import UIKit

extension ProfileViewController{
    
    func downloadAndParse(urlString: String, downloadTask: String){
        activitySpinner.startAnimating()
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        //Check if the passed in url is valid
        if let validUrl = URL(string: urlString){
            //MARK: Default Task
            //Downloads the selected channel's profile info
            let task = session.dataTask(with: validUrl, completionHandler: { (data, response, error) in
                
                //Leave if an error occurs
                if error != nil { return }
                
                //Check response, data, and status code
                guard let response = response as? HTTPURLResponse,
                    response.statusCode == 200,
                    let data = data
                    else{ print(error?.localizedDescription ?? "Unknown Error profile"); return }
                
                do{
                    //De-serialize json data
                    if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]{
                        
                        //Parse json data
                        if let username = json["name"] as? String,
                            let views = json["views"] as? Int,
                            let followers = json["followers"] as? Int{
                            
                            //bio and profile pic can return null or empty so
                            //a seperate check to see if they are there
                            if let bio = json["bio"] as? String{
                                self.currentUser.bio = bio
                            }
                            
                            if let profileUrl = json["logo"] as? String{
                                self.currentUser.logoUrl = profileUrl
                            }
                            
                            if let bannerUrl = json["profile_banner"] as? String{
                                self.currentUser.bannerUrl = bannerUrl
                            }
                            
                            //Model object
                            self.currentUser.username = username
                            self.currentUser.views = views
                            self.currentUser.followers = followers
                            self.currentUser.downloadImage()
                            self.currentUser.downloadBanner()
                            
                        }else{ print(json) }
                    }
                }
                catch{
                    print(error.localizedDescription)
                }
                DispatchQueue.main.async {
                    self.update()
                }
                self.downloadAndParse(urlString: "https://api.twitch.tv/kraken/channels/\(self.currentID)/teams?client_id=\(self.appDelegate.consumerID)&\(self.appDelegate.apiVersion)", downloadTask: "team")
            })
            //MARK: Team Task
            //Downloads each team the current channel belongs to
            let teamTask = session.dataTask(with: validUrl, completionHandler: { (data, response, error) in
                
                //Leave if an error occurs
                if error != nil { return }
                
                //Check response, data, and status code
                guard let response = response as? HTTPURLResponse,
                    response.statusCode == 200,
                    let data = data
                    else{ print(error?.localizedDescription ?? "Unknown Error team"); return }
                
                do{
                    //De-serialize json data
                    if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]{

                        //Parse json data
                        for firstLevelItem in json{
                            
                        guard let t = firstLevelItem.value as? [[String: Any]]
                            else{ print(firstLevelItem); continue}
                            
                            for object in t{
                                guard let name = object["display_name"] as? String,
                                    let id = object["_id"] as? Int
                                    else{ print(object); continue }
                                
                                let team = Team(id: id, name: name)
                                
                                //Seperate check for possible null values
                                if let info = object["info"] as? String{
                                    team.info = info
                                }
                                
                                if let profileUrl = object["logo"] as? String{
                                    team.profilePicUrl = profileUrl
                                    team.downloadProfile()
                                }
                                
                                if let bannerUrl = object["banner"] as? String{
                                    team.bannerUrl = bannerUrl
                                    team.downloadBanner()
                                }
                                
                                self.teams.append(team)
                            }
                        }
                    }
                }
                catch{
                    print(error.localizedDescription)
                }
                DispatchQueue.main.async {
                    self.teamIcon.isUserInteractionEnabled = true
                    self.teamIcon.tintColor = UIColor(white: 1, alpha: 1)
                }
            })
            let vodsTask = session.dataTask(with: validUrl, completionHandler: { (data, response, error) in
                
                //Leave if an error occurs
                if error != nil { return }
                
                //Check response, data, and status code
                guard let response = response as? HTTPURLResponse,
                    response.statusCode == 200,
                    let data = data
                    else{ print(error?.localizedDescription ?? "Unknown Error vods"); return }
                
                do{
                    //De-serialize json data
                    if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]{
                        
                        //Parse json data
                        for firstLevelItem in json{
                            
                            guard let v = firstLevelItem.value as? [[String: Any]]
                                else{ print(firstLevelItem); continue}
                            
                            for object in v{
                                guard let vidID = object["_id"] as? String,
                                    let title = object["title"] as? String,
                                    let views = object["views"] as? Int,
                                    let game = object["game"] as? String,
                                    let preview = object["preview"] as? [String: Any],
                                    let previewUrl = preview["large"] as? String,
                                    let channel = object["channel"] as? [String: Any],
                                    let username = channel["display_name"] as? String,
                                    let id = channel["_id"] as? String
                                else{ print(object); continue }
                                var trimID = vidID
                                trimID = trimID.trimmingCharacters(in: CharacterSet.lowercaseLetters)
                                self.videos.append((type: "video", content: Channel(id: id, videoID: trimID, username: username, game: game, previewUrl: previewUrl, viewers: views, title: title)))
                            }
                        }
                    }
                }
                catch{
                    print(error.localizedDescription)
                }
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            })
            if downloadTask == "profile"{
                task.resume()
            }else if downloadTask == "team"{
                teamTask.resume()
            }else{
                vodsTask.resume()
            }
        }
    }
}
