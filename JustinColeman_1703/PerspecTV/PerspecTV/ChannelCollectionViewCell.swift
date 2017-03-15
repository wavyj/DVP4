//
//  StreamCollectionViewCell.swift
//  PerspecTV
//
//  Created by Justin Coleman on 3/8/17.
//  Copyright © 2017 Justin Coleman. All rights reserved.
//

import UIKit

class ChannelCollectionViewCell: UICollectionViewCell {
    
    //Outlets
    @IBOutlet weak var previewImage: UIImageView!
    @IBOutlet weak var streamerName: UILabel!
    @IBOutlet weak var gameTitle: UILabel!
    @IBOutlet weak var viewerCount: UILabel!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var watchBtn: UIButton!
    @IBOutlet weak var watchLabel: UILabel!
    @IBOutlet weak var viewersIcon: UIImageView!
    @IBOutlet weak var addLabel: UILabel!
    
    //Variables
    var isFlipped: Bool!
    
}
