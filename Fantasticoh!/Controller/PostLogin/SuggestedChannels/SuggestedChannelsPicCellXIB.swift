//
//  SuggestedChannelsPicCellXIB.swift
//  Fantasticoh!
//
//  Created by Appinventiv on 05/09/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import UIKit

class SuggestedChannelsPicCellXIB: UITableViewCell {

    @IBOutlet weak var firstImageView: UIImageView!
    @IBOutlet weak var secondImageView: UIImageView!
    @IBOutlet weak var thirdImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.secondImageView.image = CONTAINERPLACEHOLDER
    }

    override func prepareForReuse() {
        super.prepareForReuse()
//        self.firstImageView.image = CONTAINERPLACEHOLDER
//        self.secondImageView.image = CONTAINERPLACEHOLDER
//        self.thirdImageView.image = CONTAINERPLACEHOLDER
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
