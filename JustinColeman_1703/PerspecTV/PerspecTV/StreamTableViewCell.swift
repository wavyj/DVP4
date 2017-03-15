//
//  StreamTableViewCell.swift
//  PerspecTV
//
//  Created by Justin Coleman on 3/14/17.
//  Copyright © 2017 Justin Coleman. All rights reserved.
//

import UIKit

class StreamTableViewCell: UITableViewCell {

    //Outlets
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var game: UILabel!
    @IBOutlet weak var preview: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
