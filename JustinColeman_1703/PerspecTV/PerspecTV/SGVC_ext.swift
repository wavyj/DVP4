//
//  SGVC_ext.swift
//  PerspecTV
//
//  Created by Justin Coleman on 3/12/17.
//  Copyright © 2017 Justin Coleman. All rights reserved.
//

import Foundation

extension SelectedGameViewController{
    
    func downloadAndParse(urlString: String){
        activitSpinner.startAnimating()
        
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
                    else{ print(error?.localizedDescription ?? "Unknown Error games"); return }
                
                do{
                    //De-serialize json data
                    if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]{
                        
                        //Parse json data
                        for firstLevelItem in json{
                            guard let objects = firstLevelItem.value as? [[String: Any]]
                                else{ print(firstLevelItem.value); continue }
                            
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
                    self.activitSpinner.stopAnimating()
                    self.collectionView.reloadData()
                }
            })
            task.resume()
        }
    }
}
