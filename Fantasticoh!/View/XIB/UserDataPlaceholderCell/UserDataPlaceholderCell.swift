//
//  UserDataPlaceholderCell.swift
//  Fantasticoh!
//
//  Created by Appinventiv on 15/11/17.
//  Copyright © 2017 AppInventiv. All rights reserved.
//

import UIKit

class UserDataPlaceholderCell: UITableViewCell {
    
    @IBOutlet weak var bannerImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.contentView.layoutIfNeeded()
        self.userImage.layer.cornerRadius = self.userImage.bounds.height / 2
        self.userImage.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
   
}
