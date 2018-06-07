//
//  CommentTxtCell.swift
//  Fantasticoh!
//
//  Created by Appinventiv on 15/09/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import UIKit

class CommentTxtCell: UITableViewCell {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var flagBtn: UIButton!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var grayDotView: UIView!
    @IBOutlet weak var showLikeLbl: UILabel!
    @IBOutlet weak var frstRedDotView: UIView!
    @IBOutlet weak var secondRedDotView: UIView!

    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var replayBtn: UIButton!
    @IBOutlet weak var viewAllBtn: UIButton!
    @IBOutlet weak var profileImageLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var profileImageButton: UIButton!
    @IBOutlet weak var viewAlBtnHeightCons: NSLayoutConstraint!
    @IBOutlet weak var likeBtnWitdhConstraint: NSLayoutConstraint!
    @IBOutlet weak var grayDotViewLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var grayDotTrailingConstraint: NSLayoutConstraint!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.width/2
        self.profileImageView.layer.masksToBounds = true
        self.profileImageView.clipsToBounds = true
        
        self.grayDotView.layer.cornerRadius = self.grayDotView.frame.width/2
        self.grayDotView.layer.masksToBounds = true
        self.grayDotView.clipsToBounds = true
        
        self.frstRedDotView.layer.cornerRadius = self.frstRedDotView.frame.width/2
        self.frstRedDotView.layer.masksToBounds = true
        self.frstRedDotView.clipsToBounds = true
        
        self.secondRedDotView.layer.cornerRadius = self.secondRedDotView.frame.width/2
        self.secondRedDotView.layer.masksToBounds = true
        self.secondRedDotView.clipsToBounds = true
        
        UITextView.appearance().linkTextAttributes = [ NSForegroundColorAttributeName: UIColor.blue ]
        
        self.viewAllBtn.setTitleColor(CommonColors.globalRedColor(), for: .normal)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
}
