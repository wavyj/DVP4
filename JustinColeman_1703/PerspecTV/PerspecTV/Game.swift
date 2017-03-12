//
//  Game.swift
//  PerspecTV
//
//  Created by Justin Coleman on 3/12/17.
//  Copyright © 2017 Justin Coleman. All rights reserved.
//

import Foundation
import UIKit

class Game{
    let id: Int
    let name: String
    let channels: Int
    let viewers: Int
    let imageUrl: String
    var image: UIImage!
    
    init(id: Int, name: String, channels: Int, viewers: Int, imageUrl: String = ""){
        self.id = id
        self.name = name
        self.channels = channels
        self.viewers = viewers
        self.imageUrl = imageUrl
        
        if let url = URL(string: imageUrl){
            do{
                let data = try Data(contentsOf: url)
                image = UIImage(data: data)
            }
            catch{
                print(error.localizedDescription)
            }
        }
        
    }
}
