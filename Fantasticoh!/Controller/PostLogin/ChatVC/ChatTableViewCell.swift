//
//  ChatTableViewCell.swift
//  Fantasticoh!
//
//  Created by MAC on 3/23/17.
//  Copyright © 2017 AppInventiv. All rights reserved.
//

import Foundation



//MARK:- UITableVieCell
//MARK:-
class FromUserTextCell: UITableViewCell {
    
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var msgTextLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    //40
    @IBOutlet weak var timeLblHeightCons: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}


class FromUserImgCell: UITableViewCell {
    
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    //25
    @IBOutlet weak var timeLblHeightCons: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.postImageView.layer.cornerRadius = 3.0
        self.postImageView.layer.masksToBounds = true
        self.postImageView.clipsToBounds = true
        
        self.postImageView.layer.borderColor = UIColor.lightGray.cgColor
        self.postImageView.layer.borderWidth = 0.5
        
        self
            .postImageView.image = CONTAINERPLACEHOLDER
        self.postImageView.contentMode = .center
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self
            .postImageView.image = CONTAINERPLACEHOLDER
        self.postImageView.contentMode = .center
    }
}


class ToUserTextCell: UITableViewCell {
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var msgTextLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    //40
    @IBOutlet weak var userImgWidthCons: NSLayoutConstraint!
    //25
    @IBOutlet weak var timeLblHeightCons: NSLayoutConstraint!
    
    @IBOutlet weak var userProfileImageBtn: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.userImageView.layer.cornerRadius = 20
        self.userImageView.layer.masksToBounds = true
        self.userImageView.clipsToBounds = true
        //self.userImageView.backgroundColor = UIColor.blueColor()
        //self.msgTextLbl.textColor = UIColor.black.withAlphaComponent(1.0)
    }
}


class ToUserImgCell: UITableViewCell {
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var timeLbl: UILabel!
    //40
    @IBOutlet weak var userImgWidthCons: NSLayoutConstraint!
    //25
    @IBOutlet weak var timeLblHeightCons: NSLayoutConstraint!
    
    @IBOutlet weak var userProfileImageBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.userImageView.layer.cornerRadius = 20
        self.userImageView.layer.masksToBounds = true
        self.userImageView.clipsToBounds = true
        
        self.postImageView.layer.cornerRadius = 3.0
        self.postImageView.layer.masksToBounds = true
        self.postImageView.clipsToBounds = true
        
        //self.userImageView.backgroundColor = UIColor.blueColor()
        //self.bgImageView.backgroundColor = UIColor.redColor()
        //self.postImageView.backgroundColor = UIColor.greenColor()
        
        self.postImageView.layer.borderColor = UIColor.lightGray.cgColor
        self.postImageView.layer.borderWidth = 0.5
        
        self
            .postImageView.image = CONTAINERPLACEHOLDER
        self.postImageView.contentMode = .center

    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self
            .postImageView.image = CONTAINERPLACEHOLDER
        self.postImageView.contentMode = .center
    }
}



