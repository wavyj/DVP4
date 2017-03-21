//
//  Games_ext.swift
//  PerspecTV
//
//  Created by Justin Coleman on 3/12/17.
//  Copyright © 2017 Justin Coleman. All rights reserved.
//

import Foundation

extension GamesViewController{
    
    func downloadAndParse(urlString: String){
        activitySpinner.startAnimating()
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        //Check if the passed in url is valid
        if let validUrl = URL(string: urlString){
            //MARK: Default Task
            //Downloads each top game
            let task = session.dataTask(with: validUrl, completionHandler: { (data, response, error) in
                
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
                                guard let game = object["game"] as? [String: Any],
                                    let channels = object["channels"] as? Int,
                                    let viewers = object["viewers"] as? Int,
                                    let name = game["name"] as? String,
                                    let id = game["_id"] as? Int
                                    else{ print(object); continue }
                            
                                    //Seperate check for image url because it is possible it will be null
                                if let images = game["box"] as? [String: Any],
                                    let imageUrl = images["large"] as? String{
                                    self.games.append(Game(id: id, name: name, channels: channels, viewers: viewers, imageUrl: imageUrl))
                                }else{
                                    self.games.append(Game(id: id, name: name, channels: channels, viewers: viewers))
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
            })
            task.resume()
        }
    }
}
