//
//  Following_ext.swift
//  PerspecTV
//
//  Created by Justin Coleman on 3/8/17.
//  Copyright © 2017 Justin Coleman. All rights reserved.
//

import Foundation

extension FollowingViewController{
    
    func downloadandParse(urlString: String, downloadTask: String){
        activitySpinner.startAnimating()
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        //Check if the passed in url is valid
        if let validUrl = URL(string: urlString){
            //MARK: Default Task
            //Downloads all followed channels that are live
            let task = session.dataTask(with: validUrl, completionHandler: { (data, response, error) in
                
                //Leave if an error occurs
                if error != nil { return }
                
                //Check response, data, and status code
                guard let response = response as? HTTPURLResponse,
                    response.statusCode == 200,
                    let data = data
                    else{ print(error?.localizedDescription ?? "Unknown Error 3"); return }
                
                do{
                    //De-serialize json data
                    if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]{
                        
                    //Parse json data
                        for firstLevelItem in json{
                            guard let objects = firstLevelItem.value as? [[String: Any]]
                                else{ continue }
                            
                            for object in objects{
                                guard let preview = object["preview"] as? [String: Any],
                                    let previewUrl = preview["large"] as? String,
                                    let channel = object["channel"] as? [String: Any],
                                    let id = channel["_id"] as? Int,
                                    let username = channel["display_name"] as? String,
                                    let game = channel["game"] as? String,
                                    let viewers = object["viewers"] as? Int
                                    else{ print(object); continue }
                                
                                self.channels.append(Channel(id: id.description, username: username, game: game, previewUrl: previewUrl, viewers: viewers))
                            }
                        }
                    }
                }
                catch{
                    print(error.localizedDescription)
                }
                DispatchQueue.main.async {

                    self.activitySpinner.stopAnimating()
                    self.collectionView.reloadData()
                }
            })
            //MARK: ChannelTask
            //Donwloads each channel's data using its ID
            let channelTask = session.dataTask(with: validUrl, completionHandler: { (data, response, error) in
                
                //Leave if an error occurs
                if error != nil { return }
                
                //Check response, data, and status code
                guard let response = response as? HTTPURLResponse,
                    response.statusCode == 200,
                    let data = data
                    else{ print(error?.localizedDescription ?? "Unknown Error 1"); return }
                
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
                                    self.channels.append(Channel(id: id.description, username: username, game: game, previewUrl: previewUrl, viewers: viewers))
                                }else{
                                    self.channels.append(Channel(id: id.description, username: username, game: game,viewers: viewers))
                                }
                    
                            }
                        }
                    }
                }
                catch{
                    print(error.localizedDescription)
                }
                DispatchQueue.main.async {
                    
                    self.activitySpinner.stopAnimating()
                    self.collectionView.reloadData()
                }
                return
            })
            //MARK: UserLoggedInTask
            //Downloads every channel the user follows
            let userLoggedInTask = session.dataTask(with: validUrl, completionHandler: { (data, response, error) in
                
                //Leave if an error occurs
                if error != nil { return }
                
                //Check response, data, and status code
                guard let response = response as? HTTPURLResponse,
                    response.statusCode == 200,
                    let data = data
                    else{ print(error?.localizedDescription ?? "Unknown Error 2"); return }
                
                do{
                    //De-serialize json data
                    if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]{
                        
                        //Parse json data
                        for firstLevelItem in json{
                            guard let objects = firstLevelItem.value as? [[String: Any]]
                                else{ continue }
                            
                            for object in objects{
                                guard let channel = object["channel"] as? [String: Any],
                                    let id = channel["_id"] as? String
                                    else{ print(object); continue }
                                
                                self.channelsToDownload.append(id)
                            }
                        }
                    }
                }
                catch{
                    print(error.localizedDescription)
                }
                //Downloads each channel using its ID
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
                self.downloadandParse(urlString: "https://api.twitch.tv/kraken/streams/?channel=\(string)&oauth_token=\(self.currentUser.authToken)&stream_type=live&client_id=\(self.appDelegate.consumerID)&\(self.appDelegate.apiVersion)", downloadTask: "Channel")
            })
            
            if downloadTask == "User Followed"{
                userLoggedInTask.resume()
            }else if downloadTask == "Followed Live"{
                task.resume()
            }else{
                channelTask.resume()
            }
        }
    }
}
