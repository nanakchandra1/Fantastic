//
//  SeeAllCell.swift
//  Fantasticoh!
//
//  Created by Appinventiv on 02/09/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import UIKit

class SeeAllCell: UITableViewCell {

    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var seeAllBtn: UIButton!
    @IBOutlet weak var btnLeadingCons: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //let somespace: CGFloat = 20
        
        //self.seeAllBtn.setImage(UIImage(named: "cross"), for:  UIControlState.normal)
        
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
