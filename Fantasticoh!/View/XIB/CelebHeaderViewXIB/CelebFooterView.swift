//
//  CelebFooterView.swift
//  Fantasticoh!
//
//  Created by MAC on 6/1/17.
//  Copyright © 2017 AppInventiv. All rights reserved.
//

import UIKit

class CelebFooterView: UIView {

    
    @IBOutlet weak var updateBtn: UIButton!
    @IBOutlet weak var chatBtn: UIButton!
    @IBOutlet weak var fansBtn: UIButton!
    @IBOutlet weak var movableSepratorLeadingCons: NSLayoutConstraint!
    @IBOutlet weak var scrollV: UIScrollView!

    
    //MARK:- Class Function
    //MARK:-
    class func instanciateFromNib() -> CelebFooterView {
        return UINib(nibName: "CelebHeaderViewXIB", bundle: nil).instantiate(withOwner: nil, options: nil)[1] as! CelebFooterView
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
}
