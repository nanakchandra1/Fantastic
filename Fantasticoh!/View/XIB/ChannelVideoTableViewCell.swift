//
//  ChannelVideoTableViewCell.swift
//  Fantasticoh!
//
//  Created by Arvind Rawat on 03/02/18.
//  Copyright © 2018 AppInventiv. All rights reserved.
//

import UIKit

protocol PushController: class {
    func pushHandleController(indexPath: IndexPath,videos:[ChannelPhotosAndVideos])
    func pushHandleForTrending(indexPath: IndexPath,videos:[AnyObject])
}



class ChannelVideoTableViewCell: UITableViewCell {
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var bottomBtn: UIButton!
    @IBOutlet weak var videoCollectionView: UICollectionView!
    weak var pushControllerdelegate: PushController!
    var videos = [ChannelPhotosAndVideos]()
    override func awakeFromNib() {
        super.awakeFromNib()
        
        videoCollectionView.delegate   = self
        videoCollectionView.dataSource = self
        
        let videocell = UINib(nibName: "ChannelVideoCollectionViewCell", bundle: nil)
        videoCollectionView.register(videocell, forCellWithReuseIdentifier: "ChannelVideoCollectionViewCell")
    }
//    func initEventListeners() {
//        let tapGestureRecognizer = UITapGestureRecognizer(target: self,
//                                                          action: #selector(handleController))
//    }
    
//    func handleController() {
//        pushControllerdelegate?.pushHandleController(indexPath: <#IndexPath#>)
//    }
}

extension ChannelVideoTableViewCell: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return videos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videos[section].beeps.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = videoCollectionView.dequeueReusableCell(withReuseIdentifier: "ChannelVideoCollectionViewCell", for: indexPath) as? ChannelVideoCollectionViewCell else{
            
            fatalError("Video Collection cell not found")
        }
        
        
        cell.videoPreview.layer.cornerRadius = 3
        cell.videoPreview.clipsToBounds = true
        cell.videoPreview.contentMode = .center

        if let imgUrl =  videos[indexPath.section].beeps[indexPath.item]["img1x"] as? String {
            
            cell.videoPreview.sd_setImage(with: URL(string: imgUrl), placeholderImage: AppIconPLACEHOLDER, options: SDWebImageOptions(rawValue: 1), completed: { (image, error, type, url) in
                
                if error != nil{
                    cell.videoPreview.contentMode = .center
                    
                }else{
                    cell.videoPreview.contentMode = .scaleAspectFill
                    
                }

            })
            
        }else{
            cell.videoPreview.contentMode = .center

        }
        
        if let timeLabel =  videos[indexPath.section].beeps[indexPath.item]["postTimeDisplay"] as? String {
            
            cell.timeLabel.text = timeLabel
            
        }
        
        if let contentLabel =  videos[indexPath.section].beeps[indexPath.item]["title"] as? String {
            
            cell.contentLabel.text = contentLabel
            
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        
        let numberOfCell: CGFloat = 2.5
        let cellWidth = SCREEN_WIDTH / numberOfCell
        
        return CGSize(width: cellWidth, height: 250)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
       
        cell.contentView.layer.cornerRadius = 3.0
        cell.contentView.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        cell.contentView.layer.borderWidth = 0.5

        let border = CALayer()
        let width = CGFloat(1)
        border.borderColor = UIColor.darkGray.cgColor
        border.frame = CGRect(x: 0, y: cell.contentView.frame.size.height - width, width:  cell.contentView.frame.size.width, height: cell.contentView.frame.size.height)
        
        border.borderWidth = width
        cell.contentView.layer.addSublayer(border)
        cell.contentView.layer.masksToBounds = true
        cell.contentView.clipsToBounds = true
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    // self.pushControllerdelegate.pushHandleController(indexPath:indexPath)
        self.pushControllerdelegate.pushHandleController(indexPath:indexPath,videos:self.videos)


    }
}
