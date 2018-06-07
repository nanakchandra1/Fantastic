//
//  FanCellXIB.swift
//  Fantasticoh!
//
//  Created by Appinventiv on 31/08/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import UIKit

class FanCellXIB: UITableViewCell {

    @IBOutlet weak var featureImageWidthCons: NSLayoutConstraint!
    //182
    @IBOutlet weak var imgContainerHeightCons: NSLayoutConstraint!
    @IBOutlet weak var imgContainerWidthCons: NSLayoutConstraint!
    @IBOutlet weak var imgContainerView: UIView!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var counterLbl: UILabel!
    @IBOutlet weak var btn: UIButton!
    @IBOutlet weak var featureImageView: UIImageView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var grayDot: UIView!
    @IBOutlet weak var secondCounterLbl: UILabel!
    @IBOutlet weak var redDot: UIView!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.imgContainerView.layer.cornerRadius = self.imgContainerView.bounds.height / 2
        self.imgContainerView.layer.masksToBounds = true
        
        self.imgView.layer.cornerRadius = self.imgView.bounds.height / 2
        self.imgView.layer.masksToBounds = true
        
        self.nameLbl.textColor = CommonColors.lblTextColor()
        
        btn.backgroundColor = UIColor.clear
        btn.setTitleColor(CommonColors.fanlblTextColor(), for:  .normal)
        btn.setImage(UIImage(named: "plus"), for:  .normal)
        btn.setTitle(" FAN", for:  .normal)
        btn.layer.borderWidth = 1.0
        btn.layer.borderColor = CommonColors.globalRedColor().cgColor
        btn.layer.cornerRadius = 2.0
        btn.layer.masksToBounds = true
        
        self.bottomView.backgroundColor = CommonColors.sepratorColor()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
