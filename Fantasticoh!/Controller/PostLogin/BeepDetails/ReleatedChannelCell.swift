//
//  ReleatedChannelCell.swift
//  Fantasticoh!
//
//  Created by Appinventiv on 26/09/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import UIKit

class ReleatedChannelCell: UITableViewCell {

    
    @IBOutlet weak var mainImageVIew: UIImageView!
    @IBOutlet weak var imgContainerHeightCons: NSLayoutConstraint!
    
    @IBOutlet weak var imgContainerView: UIView!
    @IBOutlet weak var imgCollectionView: UICollectionView!
    @IBOutlet weak var tapView: UIView!

    @IBOutlet weak var channelDetailContainer: UIView!
    @IBOutlet weak var channelLogoContainer: UIView!
    @IBOutlet weak var channelImageView: UIImageView!
    @IBOutlet weak var channelNameLbl: UILabel!
    @IBOutlet weak var channelSourceImageView: UIImageView!
    @IBOutlet weak var grayDotView: UIView!
    @IBOutlet weak var timeStampImageView: UIImageView!
    @IBOutlet weak var postTimerLbl: UILabel!
    
    @IBOutlet weak var relatedLbl: UILabel!
    //30
    @IBOutlet weak var relatedLblHeightCons: NSLayoutConstraint!
    
    var imageArrayURl = [URL]()
    var moreCount = Int()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let imageViewCell = UINib(nibName: "ImageViewCell", bundle: nil)
        self.imgCollectionView.register(imageViewCell, forCellWithReuseIdentifier: "ImageViewCell")
        
        self.imgCollectionView.isScrollEnabled = false
        self.imgCollectionView.delegate = self
        self.imgCollectionView.dataSource = self
        self.imgCollectionView.backgroundColor = CommonColors.whiteColor()
        
        self.channelImageView.layer.cornerRadius = self.channelImageView.bounds.width / 2
        self.channelImageView.layer.masksToBounds = true
        
        self.channelSourceImageView.layer.cornerRadius = self.channelSourceImageView.bounds.width / 2
        self.channelSourceImageView.layer.masksToBounds = true
        
        self.grayDotView.layer.cornerRadius = self.grayDotView.bounds.width / 2
        self.grayDotView.layer.masksToBounds = true
        
    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        self.imgCollectionView.frame = CGRect(x:self.imgCollectionView.frame.origin.x,y: self.imgCollectionView.frame.origin.y,width: self.imgCollectionView.frame.size.width,height: self.imgCollectionView.frame.size.height)
        CATransaction.commit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let pathFirst = UIBezierPath(roundedRect:imgContainerView.bounds, byRoundingCorners:[UIRectCorner.topLeft,  UIRectCorner.topRight], cornerRadii: CGSize(width: 4,height: 4))
        let maskLayerFirst = CAShapeLayer()
        
        maskLayerFirst.path = pathFirst.cgPath
        
        self.imgContainerView.layer.mask = maskLayerFirst
        self.imgContainerView.layer.masksToBounds = true
        self.imgContainerView.clipsToBounds = true
        
        let pathSecond = UIBezierPath(roundedRect:channelDetailContainer.bounds, byRoundingCorners:[.bottomLeft, .bottomRight], cornerRadii: CGSize(width: 4,height: 4))
        let maskLayerSecond = CAShapeLayer()
        
        maskLayerSecond.path = pathSecond.cgPath
        self.channelDetailContainer.layer.mask = maskLayerSecond
        self.channelDetailContainer.layer.masksToBounds = true
        self.channelDetailContainer.clipsToBounds = true
    }
    
}




//MARK:- UICollectionView Delegate & DataSource
//MARK:-
extension ReleatedChannelCell: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if self.imageArrayURl.count < 5 {
            return self.imageArrayURl.count
        } else  {
            return 5
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageViewCell", for:  indexPath) as! ImageViewCell
        cell.backgroundColor = CommonColors.whiteColor()
        cell.tapView.isHidden = true
        cell.imageView.sd_setImage(with: self.imageArrayURl[indexPath.item], placeholderImage: CONTAINERPLACEHOLDER)
        
        self.setTrallingConstraints(indexPath: indexPath, cell: cell)
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        return self.setCellSize(indexPath: indexPath)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        //set HorizontalDistance
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        //return self.tagVerticalDistance
        return 2
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    private func setTrallingConstraints(indexPath: IndexPath, cell: ImageViewCell) {
        
        switch self.imageArrayURl.count {
            
        case 1,0:
            cell.tralingConstraints.constant = 0
            
        case 2:
            switch indexPath.item {
            case 0:
                cell.tralingConstraints.constant = 2
                
            case 1:
                cell.tralingConstraints.constant = 0
            default:
                fatalError("Inside AllTagVC collectionViewLayout method.")
                
            }
            
        case 3:
            switch indexPath.item {
            case 0:
                cell.tralingConstraints.constant = 0
                
            case 1:
                cell.tralingConstraints.constant = 2
                
            case 2:
                cell.tralingConstraints.constant = 0
                
            default:
                fatalError("Inside AllTagVC collectionViewLayout method.")
                
            }
        case 4:
            switch indexPath.item {
            case 0:
                cell.tralingConstraints.constant = 2
                
            case 1:
                cell.tralingConstraints.constant = 0
                
            case 2:
                cell.tralingConstraints.constant = 2
                
            case 3:
                cell.tralingConstraints.constant = 0
                
            default:
                fatalError("Inside AllTagVC collectionViewLayout method.")
                
            }
            
        default:
            switch indexPath.item {
            case 0:
                cell.tralingConstraints.constant = 2
                
            case 1:
                cell.tralingConstraints.constant = 0
                
            case 2:
                cell.tralingConstraints.constant = 2
                
            case 3:
                cell.tralingConstraints.constant = 2
                
            case 4:
                cell.tralingConstraints.constant = 0
                
            default:
                fatalError("Inside AllTagVC collectionViewLayout method.")
                
            }
        }
        
    }
    
    private func setCellSize(indexPath: IndexPath)-> CGSize {
        
        let cellSize: CGSize = CGSize(width: 0, height: 0)
        
        switch self.imageArrayURl.count {
        case 1,0:
            return CGSize(width: SCREEN_WIDTH, height: 182)
            
        case 2:
            return CGSize(width: ((SCREEN_WIDTH-24)/2), height: 182)
            
        case 3:
            switch indexPath.item {
            case 0:
                return CGSize(width:((SCREEN_WIDTH-24)), height: 182/2)
            case 1:
                return CGSize(width: ((SCREEN_WIDTH-24)/2), height: 182/2)
            case 2:
                return CGSize(width: ((SCREEN_WIDTH-24)/2), height: (182/2))
            default:
                fatalError("Inside AllTagVC collectionViewLayout method.")
            }
            
        case 4:
            return CGSize(width: ((SCREEN_WIDTH-24)/2), height: 182/2)
            
        default:
            switch indexPath.item {
            case 0:
                return CGSize(width: ((SCREEN_WIDTH-24)/2), height: 182/2)
                
            case 1:
                return CGSize(width: ((SCREEN_WIDTH-24)/2), height: 182/2)
                
            case 2:
                return CGSize(width: ((SCREEN_WIDTH-24)/3)-0.00001, height: 182/2)
                
            case 3:
                return CGSize(width: ((SCREEN_WIDTH-24)/3)-0.00001, height: 182/2)
                
            case 4:
                return CGSize(width: ((SCREEN_WIDTH-24)/3), height: 182/2)
                
            default:
                fatalError("Inside AllTagVC collectionViewLayout method.")
                
            }
        }
        return cellSize
    }
}
