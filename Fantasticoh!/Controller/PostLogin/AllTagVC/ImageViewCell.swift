//
//  ImageViewCell.swift
//  Fantasticoh!
//
//  Created by Shubham on 8/5/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import UIKit

class ImageViewCell: UICollectionViewCell {
    
    //MARK:- @IBOutlet & Propertie's
    //MARK:-
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tapView: UIView!
    @IBOutlet weak var youTubePlayerView: YTPlayerView!
    @IBOutlet weak var leadingConstraints: NSLayoutConstraint!
    @IBOutlet weak var tralingConstraints: NSLayoutConstraint!
    @IBOutlet var playimg: UIImageView!
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var loadingLbl: UILabel!
    @IBOutlet weak var mediaNotFoundLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.imageView.contentMode = .center
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.imageView.contentMode = .center
        self.imageView.image = nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override var bounds: CGRect {
        didSet {
            contentView.frame = bounds
        }
    }
}
