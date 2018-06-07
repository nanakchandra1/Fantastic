//
//  NativeAdTableViewCell.swift
//  Fantasticoh!
//
//  Created by Arvind Rawat on 30/01/18.
//  Copyright © 2018 AppInventiv. All rights reserved.
//

import UIKit

class NativeAdTableViewCell: UITableViewCell {

    @IBOutlet weak var bannerView   : UIImageView!
    @IBOutlet weak var logoView     : UIImageView!
    @IBOutlet weak var text1        : UILabel!
    @IBOutlet weak var text2        : UILabel!
    @IBOutlet weak var adChoices    : UILabel!
    @IBOutlet weak var body         : UILabel!
    @IBOutlet weak var linkButton   : UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
