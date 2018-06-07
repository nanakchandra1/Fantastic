//
//  UserChatListXIB.swift
//  Fantasticoh!
//
//  Created by MAC on 5/29/17.
//  Copyright © 2017 AppInventiv. All rights reserved.
//

import UIKit

class UserChatListXIB: UITableViewCell {

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var userProfileImageBtn: UIButton!
    @IBOutlet weak var redDotView: UIView!
    @IBOutlet weak var flagButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.userImageView.layer.cornerRadius = self.userImageView.frame.size.height/2
        self.userImageView.clipsToBounds = true
        
        self.redDotView.layer.cornerRadius = self.redDotView.frame.size.height/2
        self.redDotView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
