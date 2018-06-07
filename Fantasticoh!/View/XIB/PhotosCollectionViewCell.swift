//
//  PhotosCollectionViewCell.swift
//  Fantasticoh!
//
//  Created by Arvind Rawat on 03/02/18.
//  Copyright © 2018 AppInventiv. All rights reserved.
//

import UIKit

class PhotosCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var photoImageView: UIImageView!
    
    var featureChannel = [AnyObject]()

    
    override func awakeFromNib() {
        super.awakeFromNib()
      
        // Initialization code
    }
   
    override func prepareForReuse() {
        photoImageView.image = nil
    }
}
