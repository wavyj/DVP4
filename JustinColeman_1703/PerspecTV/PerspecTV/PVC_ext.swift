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
                        if let username = json["display_name"] as? String,
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
                                guard let name = object["name"] as? String,
                                    let displayName = object["display_name"] as? String,
                                    let id = object["_id"] as? Int
                                    else{ print(object); continue }
                                
                                let team = Team(id: id, name: name, displayName: displayName)
                                
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
                //download team info
                self.tempTeams = self.teams
                self.iterator = 0
                for t in self.tempTeams{
                    self.downloadAndParse(urlString: "https://api.twitch.tv/kraken/teams/\(t.name)?client_id=\(self.appDelegate.consumerID)&\(self.appDelegate.apiVersion)", downloadTask: "members")
                }
            })
            //MARK: Team Members Task
            //Downloads each team's members
            let memberTask = session.dataTask(with: validUrl, completionHandler: { (data, response, error) in
                
                //Leave if an error occurs
                if error != nil {print("error"); return }
        
                //Check response, data, and status code
                guard let response = response as? HTTPURLResponse,
                    response.statusCode == 200,
                    let data = data
                    else{ print(error?.localizedDescription ?? "Unknown Error team"); return }
                
                do{
                    //De-serialize json data
                    if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]{
                        
                        //Parse json data
                        guard let users = json["users"] as? [[String: Any]]
                            else{self.tempTeams.remove(at: self.iterator); return}
                        
                        for u in users{
                            guard let id = u["_id"] as? String
                                else {print(u); continue}
                            self.channelsToDownload.append(id)
                        }
                    }
                }
                catch{
                    print(error.localizedDescription)
                }
                DispatchQueue.main.async {
                    if self.iterator == self.teams.count - 1 && self.tempTeams.count != 0{
                        self.teams = self.tempTeams
                        self.iterator = 0
                        var string = ""
                        var index = 0
                        for c in self.channelsToDownload{
                            if index < self.channelsToDownload.count{
                                string += "\(c),"
                            }else{
                                string += "\(c)"
                            }
                            index += 1
                        }
                        //Clears after use
                        self.channelsToDownload.removeAll()
                        
                        //Downloads each Channel's info for each channel ID
                        self.downloadAndParse(urlString: "https://api.twitch.tv/kraken/streams/?channel=\(string)&oauth_token=\(self.currentUser.authToken)&stream_type=live&client_id=\(self.appDelegate.consumerID)&\(self.appDelegate.apiVersion)", downloadTask: "channel")
                    }else if self.tempTeams.count == 0{
                        self.activitySpinner.stopAnimating()
                        return
                    }else{
                    self.iterator += 1
                    }
                }
            })
            //MARK: Channel Task
            //Downloads each team member's channel data
            let channelTask = session.dataTask(with: validUrl, completionHandler: { (data, response, error) in
                
                //Leave if an error occurs
                if error != nil {print("error"); return }
                
                //Check response, data, and status code
                guard let response = response as? HTTPURLResponse,
                    response.statusCode == 200,
                    let data = data
                    else{ print(error?.localizedDescription ?? "Unknown Error channel"); return }
                
                do{
                    //De-serialize json data
                    if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]{
                        
                        //Parse json data
                        for firstLevelItem in json{
                            guard let objects = firstLevelItem.value as? [[String: Any]]
                                else{ continue }
                            
                            for object in objects{
                                guard let channel = object["channel"] as? [String: Any],
                                    let id = channel["_id"] as? Int,
                                    let username = channel["display_name"] as? String,
                                    let game = channel["game"] as? String,
                                    let viewers = object["viewers"] as? Int
                                    else{ print(object); continue }
                                if let preview = object["preview"] as? [String: Any],
                                    let previewUrl = preview["large"] as? String{
                                    self.teams[self.iterator].members.append((type: "stream" , content: Channel(id: id.description, username: username, game: game, previewUrl: previewUrl, viewers: viewers)))
                                }else{
                                    self.teams[self.iterator].members.append((type: "stream", content: Channel(id: id.description, username: username, game: game,viewers: viewers)))
                                }
                            }
                        }
                    }
                }
                catch{
                    print(error.localizedDescription)
                }
                DispatchQueue.main.async {
                    if self.iterator == self.teams.count - 1{
                        self.teamIcon.isUserInteractionEnabled = true
                        self.teamIcon.tintColor = UIColor(white: 1, alpha: 1)
                        self.activitySpinner.stopAnimating()
                    }
                    
                    self.iterator += 1
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
                    if self.videos.count == 0{
                        self.collectionView.isHidden = true
                        self.warningView.isHidden = false
                        self.videoIcon.isHidden = true
                    }else{
                        self.warningView.isHidden = true
                        self.videoIcon.isHidden = false
                        self.collectionView.isHidden = false
                        self.collectionView.reloadData()
                    }
                }
            })
            if downloadTask == "profile"{
                task.resume()
            }else if downloadTask == "team"{
                teamTask.resume()
            }else if downloadTask == "members"{
                memberTask.resume()
            }else if downloadTask == "channel"{
                channelTask.resume()
            }else{
                vodsTask.resume()
            }
        }
    }
}
