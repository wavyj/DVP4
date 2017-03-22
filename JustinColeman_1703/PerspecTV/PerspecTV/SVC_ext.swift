//
//  SVC_ext.swift
//  PerspecTV
//
//  Created by Justin Coleman on 3/21/17.
//  Copyright © 2017 Justin Coleman. All rights reserved.
//

import Foundation

extension SearchViewController{
    
    func downloadAndParse(urlString: String, downloadTask: String){
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        if let validUrl = URL(string: urlString){
            //MARK: Stream Task
            //Downloads streams based on the search query
            let streamTask = session.dataTask(with: validUrl, completionHandler: { (data, response, error) in
                
                //Leave if an error occurs
                if error != nil { return }
                
                //Check response, data, and status code
                guard let response = response as? HTTPURLResponse,
                    response.statusCode == 200,
                    let data = data
                    else{ print(error?.localizedDescription ?? "Unknown Error streams"); return }
                
                do{
                    //De-serialize json data
                    if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]{
                        
                        //Parse json data
                        for firstLevelItem in json{
                            guard let objects = firstLevelItem.value as? [[String: Any]]
                                else{ print(firstLevelItem.value); continue }
                            
                            for object in objects{
                                guard let id = object["_id"] as? Int
                                    else{ print(object); continue }
                                self.channelsToDownload.append(id.description)
                            }
                        }
                    }
                }
                catch{
                    print(error.localizedDescription)
                }
                
                //Download channel
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
                self.downloadAndParse(urlString: "https://api.twitch.tv/kraken/streams/?channel=\(string)stream_type=live&client_id=\(self.appDelegate.consumerID)&\(self.appDelegate.apiVersion)", downloadTask: "Channel")
            })
            //MARK: Channel Task
            //Downloads channels for results
            let channelTask = session.dataTask(with: validUrl, completionHandler: { (data, response, error) in
                
                //Leave if an error occurs
                if error != nil { return }
                
                //Check response, data, and status code
                guard let response = response as? HTTPURLResponse,
                    response.statusCode == 200,
                    let data = data
                    else{ print(error?.localizedDescription ?? "Unknown Error channels"); return }
                
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
                                    self.channels.append((type: "stream" , content: Channel(id: id.description, username: username, game: game, previewUrl: previewUrl, viewers: viewers)))
                                }else{
                                    self.channels.append((type: "stream", content: Channel(id: id.description, username: username, game: game,viewers: viewers)))
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
                    self.streamCollectionView.reloadData()
                }
            })
            //MARK: Game Task
            //Downloads streams based on the search query
            let gameTask = session.dataTask(with: validUrl, completionHandler: { (data, response, error) in
                
                //Leave if an error occurs
                if error != nil { return }
                
                //Check response, data, and status code
                guard let response = response as? HTTPURLResponse,
                    response.statusCode == 200,
                    let data = data
                    else{ print(error?.localizedDescription ?? "Unknown Error games"); return }
                
                do{
                    //De-serialize json data
                    if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]{
                        
                        //Parse json data
                        for firstLevelItem in json{
                            guard let objects = firstLevelItem.value as? [[String: Any]]
                                else{ continue }
                            
                            for object in objects{
                                guard let name = object["name"] as? String,
                                    let id = object["_id"] as? Int
                                    else{ print(object); continue }
                                
                                //Seperate check for image url because it is possible it will be null
                                if let images = object["box"] as? [String: Any],
                                    let imageUrl = images["large"] as? String{
                                    self.games.append(Game(id: id, name: name, imageUrl: imageUrl))
                                }else{
                                    self.games.append(Game(id: id, name: name))
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
                    self.streamCollectionView.reloadData()
                }
            })
            if downloadTask == "Stream"{
                streamTask.resume()
            }else if downloadTask == "Game"{
                gameTask.resume()
            }else if downloadTask == "Channel"{
                channelTask.resume()
            }
        }
    }
}
