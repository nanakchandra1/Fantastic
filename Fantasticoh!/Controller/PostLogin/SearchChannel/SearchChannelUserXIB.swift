//
//  SearchChannelUserXIB.swift
//  Fantasticoh!
//
//  Created by Appinventiv on 13/09/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import UIKit

class SearchChannelUserXIB: UITableViewCell {

    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var textLbl: UILabel!
    @IBOutlet weak var tagLbl: UILabel!
    @IBOutlet weak var textLblTopCons: NSLayoutConstraint!
    
    @IBOutlet weak var infoBtn: UIButton!
    @IBOutlet weak var arrowImageView: UIImageView!
    
    
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var textLblTrailingCons: NSLayoutConstraint!
    @IBOutlet weak var textLblLeadingCons: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.imgView.layer.cornerRadius = self.imgView.frame.height/2
        self.imgView.layer.masksToBounds = true
    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
     func fanBtnSetup() {
        
        self.infoBtn.titleLabel?.font = self.infoBtn.titleLabel?.font.withSize(12)
        self.infoBtn.backgroundColor = UIColor.clear
        self.infoBtn.setTitleColor(CommonColors.lblTextColor(), for:  .normal)
        self.infoBtn.setTitle(" FAN", for:  .normal)
        self.infoBtn.setImage(UIImage(named: "plus"), for:  .normal)
        self.infoBtn.layer.borderWidth = 1.0
        self.infoBtn.layer.borderColor = CommonColors.globalRedColor().cgColor
        self.infoBtn.layer.cornerRadius = 2.0
        self.infoBtn.layer.masksToBounds = true
    }
}
