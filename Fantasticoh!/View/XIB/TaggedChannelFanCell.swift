//
//  TaggedChannelFanCell.swift
//  Fantasticoh!
//
//  Created by Nanak on 09/04/18.
//  Copyright © 2018 AppInventiv. All rights reserved.
//

import UIKit

class TaggedChannelFanCell: UITableViewCell {

    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var fanCountLbl: UILabel!
    @IBOutlet weak var infoLbl: UILabel!
    @IBOutlet weak var infoBtn: UIButton!
    @IBOutlet weak var arrowImg: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.imgView.layer.cornerRadius = self.imgView.frame.height/2
        self.imgView.layer.masksToBounds = true
//        self.fanCountLbl.textColor = UIColor.black
//        self.infoLbl.textColor = UIColor.black

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
