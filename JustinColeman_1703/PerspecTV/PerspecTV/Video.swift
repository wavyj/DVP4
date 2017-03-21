//
//  Video.swift
//  PerspecTV
//
//  Created by Justin Coleman on 3/20/17.
//  Copyright © 2017 Justin Coleman. All rights reserved.
//

import Foundation
import UIKit

class Video{
    let id: String
    let username: String
    let title: String
    let previewUrl: String
    var previewImage: UIImage!
    let views: Int
    
    init(id: String, username: String, title: String, previewUrl: String, views: Int){
        self.id = id
        self.username = username
        self.title = title
        self.previewUrl = previewUrl
        self.views = views
        
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
