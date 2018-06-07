//
//  ChannelPhotosTableViewCell.swift
//  Fantasticoh!
//
//  Created by Arvind Rawat on 03/02/18.
//  Copyright © 2018 AppInventiv. All rights reserved.
//

import UIKit
//Arvind
enum Flow {
    case  None, Trending
}

class ChannelPhotosTableViewCell: UITableViewCell {
    
   
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var bottomBtn: UIButton!
    @IBOutlet weak var photosCollectionView: UICollectionView!
    
    @IBOutlet weak var bottomConstriant: NSLayoutConstraint!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    var flow = Flow.None
    var photos = [ChannelPhotosAndVideos]()
    var featureChannel = [AnyObject]()
     weak var pushControldelegate: PushController!
    

    override func awakeFromNib() {
        super.awakeFromNib()
       
        photosCollectionView.delegate   = self
        photosCollectionView.dataSource = self
        
        let photocell = UINib(nibName: "PhotosCollectionViewCell", bundle: nil)
        photosCollectionView.register(photocell, forCellWithReuseIdentifier: "PhotosCollectionViewCell")
        
    }
    override func prepareForReuse() {
        self.photosCollectionView.reloadData()
    }
}

extension ChannelPhotosTableViewCell:UICollectionViewDelegate,UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       if self.flow == .Trending {
            return featureChannel.count
            
        }else{
            return self.photos[section].beeps.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       
        guard let cell = photosCollectionView.dequeueReusableCell(withReuseIdentifier: "PhotosCollectionViewCell", for: indexPath) as? PhotosCollectionViewCell else{
            
            fatalError("Collection cell not found")
        }
        cell.photoImageView.layer.cornerRadius = 5
        cell.photoImageView.clipsToBounds = true
       
        cell.photoImageView.contentMode = .center

        if self.flow == .Trending{
            
             self.bottomConstriant.constant = -20
             self.topConstraint.constant = -20
            
            
            if let imgUrl =  featureChannel[indexPath.row]["imageURL"] as? String {
                
            if let url =  URL(string: imgUrl) {
                
                cell.photoImageView.sd_setImage(with: url, placeholderImage: CHANNELLOGOPLACEHOLDER, options: SDWebImageOptions(rawValue: 1), completed: { (image, error, type, url) in
                    
                    if error != nil{
                        cell.photoImageView.contentMode = .center

                    }else{
                        cell.photoImageView.contentMode = .scaleAspectFill

                    }
                })
                
            }else{
                
                cell.photoImageView.contentMode = .center

            }

        }
            return cell
            
        }else{
        
        
        if let imgUrl =  photos[indexPath.section].beeps[indexPath.item]["img1x"] as? String {
            
            if let url =  URL(string: imgUrl) {
                
                cell.photoImageView.sd_setImage(with: url, placeholderImage: CHANNELLOGOPLACEHOLDER, options: SDWebImageOptions(rawValue: 1), completed: { (image, error, type, url) in
                    
                    if error != nil{
                        cell.photoImageView.contentMode = .center
                        
                    }else{
                        cell.photoImageView.contentMode = .scaleAspectFill
                        
                    }
                })
                
            }else{
                cell.photoImageView.contentMode = .center

            }

            
//            cell.photoImageView.sd_setImage(with: URL(string: imgUrl), placeholderImage: CHANNELLOGOPLACEHOLDER)
            
        }
        return cell
        }
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        cell.contentView.layer.cornerRadius = 3.0
        cell.contentView.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        cell.contentView.layer.borderWidth = 0.5
        
        let border = CALayer()
        let width = CGFloat(0.6)
        border.borderColor = UIColor.darkGray.cgColor
        border.frame = CGRect(x: 0, y: cell.contentView.frame.size.height - width, width:  cell.contentView.frame.size.width, height: cell.contentView.frame.size.height)
        
        border.borderWidth = width
        cell.contentView.layer.addSublayer(border)
        cell.contentView.layer.masksToBounds = true
    }
}

extension ChannelPhotosTableViewCell : UICollectionViewDelegateFlowLayout{
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
            return UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 10)
        }
        
   
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            if flow == .Trending{
                let collectionViewWidth = collectionView.bounds.width
                return CGSize(width: collectionViewWidth/3, height: collectionViewWidth/3)
            }else{
                let collectionViewWidth = collectionView.bounds.width
                return CGSize(width: collectionViewWidth/2.8, height: collectionViewWidth/2.8)
            }
            
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
            return 2
        }
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
            return 5
        }
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            
            if flow == .Trending{
               self.pushControldelegate.pushHandleForTrending(indexPath: indexPath, videos: self.featureChannel)
            }else{
                self.pushControldelegate.pushHandleController(indexPath:indexPath, videos:  self.photos)
            }
           
            
        }
   
}
