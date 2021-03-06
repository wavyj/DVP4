//
//  Streamer.swift
//  PerspecTV
//
//  Created by Justin Coleman on 3/8/17.
//  Copyright © 2017 Justin Coleman. All rights reserved.
//

import Foundation
import UIKit

class Channel{
    let id: String
    let videoID: String
    let username: String
    let game: String
    let previewUrl: String
    let viewers: Int
    let title: String
    var previewImage: UIImage!
    
    init(id: String = "", videoID: String = "", username: String = "", game: String = "", previewUrl: String = "", viewers: Int = 0, title: String = ""){
        self.id = id
        self.videoID = videoID
        self.username = username
        self.game = game
        self.previewUrl = previewUrl
        self.viewers = viewers
        self.title = title
        
        if let url = URL(string: previewUrl){
            do{
                let data = try Data(contentsOf: url)
                previewImage = UIImage(data: data)

            }
            catch{
                print(error.localizedDescription)
            }
        }
    }
}
