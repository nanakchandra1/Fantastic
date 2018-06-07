//
//  TagsCollectionCellXIB.swift
//  Fantasticoh!
//
//  Created by Appinventiv on 07/09/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import UIKit

class TagsCollectionCellXIB: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var lbl: UILabel!
    @IBOutlet weak var bgBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        self.imageView.layer.cornerRadius = self.imageView.frame.width/2
        self.imageView.layer.masksToBounds = true
        
        self.lbl.textColor = CommonColors.lblTextColor()

    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }
}
