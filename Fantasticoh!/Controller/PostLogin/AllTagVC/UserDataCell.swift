//
//  UserDataCell.swift
//  Fantasticoh!
//
//  Created by Shubham on 8/8/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

enum BeepInnerType {
    case Image, Video, Youtube, MP4
}
// nitin
class UserDataCell: UITableViewCell {
    
    //MARK:- @IBOutlet & Propertie's
    //MARK:-
    //182
    @IBOutlet weak var imgCollectionViewHeightCons: NSLayoutConstraint!
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var imgCollectionView: UICollectionView!
    @IBOutlet weak var logoContainerView: UIView!
    @IBOutlet weak var logoImgeView: UIImageView!
    @IBOutlet weak var providerNameLbl: UILabel!
    @IBOutlet weak var newsTypeLogoImageView: UIImageView!
    @IBOutlet weak var firstDotView: UIView!
    @IBOutlet weak var clockImageView: UIImageView!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var tagContainerView: JCTagListView!
    @IBOutlet weak var likeCountLbl: UILabel!
    @IBOutlet weak var likeTextLbl: UILabel!
    @IBOutlet weak var seondDotView: UIView!
    @IBOutlet weak var shareCountLbl: UILabel!
    @IBOutlet weak var shareTextLbl: UILabel!
    @IBOutlet weak var providerDescContainerView: UIView!
    @IBOutlet weak var showlikeContainerView: UIView!
    @IBOutlet weak var btnContainerView: UIView!
    @IBOutlet weak var chatBtn: UIButton!
    @IBOutlet weak var likeBtn: SparkButton!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var tagContainerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var tapView: UIView!
    @IBOutlet weak var descDetailLbl: UILabel!
    @IBOutlet weak var pageController: UIPageControl!
    @IBOutlet weak var readMoreBtn: UIButton!
    
    @IBOutlet weak var bottomViewHeightConstant: NSLayoutConstraint!
    @IBOutlet weak var readMoreHostName: UILabel!
    
    //16
    @IBOutlet weak var likeContainerHeightCons: NSLayoutConstraint!
    //10
    @IBOutlet weak var likeContainerTopCons: NSLayoutConstraint!
    
    @IBOutlet weak var channelDescBtn: UIButton!
    
    @IBOutlet weak var tagsContainerTopConstraints: NSLayoutConstraint!
    
    @IBOutlet weak var viewsDotView: UIView!
    @IBOutlet weak var viewsCountLabel: UILabel!
    @IBOutlet weak var flagButton: UIButton!
    //var webV:UIWebView!
    var imageArrayURl = [URL]()
    var moreCount = Int()
    var tagData = NSMutableArray()
    var isNotBeepDetail = true
    
    var beepMedia = [AnyObject]()
    var isVideo = [false]
    var beepInnerType = [BeepInnerType.Image]
    var metaData = [String : AnyObject]()
    //Video Properties
    let player = AVPlayer()
    var playerLayer: AVPlayerLayer!
    
    var timeObserver: AnyObject!
    
    let invisivalButton = UIButton()
    let timeRemainingLabel = UILabel()
    
    let blurView = UIView()
    let seekSlider = UISlider()
    var playerRateBeforeSeek: Float = 0
    
    var blureViewFlag = true
    var videoLogoView: UIImageView!
    
    var imagesGallery = [SKPhoto]()
    
    var singleBeepHeightCons: CGFloat = ((SCREEN_WIDTH*75)/100) //SCREEN_WIDTH//182//(SCREEN_HEIGHT/SCREEN_WIDTH) * SCREEN_WIDTH
    
    var timer = Timer()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        var tempFrame = self.frame
        tempFrame.size.height = singleBeepHeightCons
        self.frame = tempFrame
        self.pageController.currentPageIndicatorTintColor = CommonColors.globalRedColor()
        self.pageController.pageIndicatorTintColor = UIColor.white
        self.pageController.currentPage = 0
        pageController.transform = CGAffineTransform(scaleX: 1.4, y: 1.4)
        self.updatePageControl()
        /*
         let imge: UIImage = UIImage(named: "video_play_button")!
         self.videoLogoView = UIImageView(image: imge)
         let org = self.tapView.frame.origin
         let height = self.tapView.frame.height
         self.videoLogoView.frame = CGRect(origin: org, size: CGSize(width: SCREEN_WIDTH, height: height))
         self.videoLogoView.contentMode = .Center
         self.tapView.addSubview(self.videoLogoView)
         */
        
        
        let imageViewCell = UINib(nibName: "ImageViewCell", bundle: nil)
        self.imgCollectionView.register(imageViewCell, forCellWithReuseIdentifier: "ImageViewCell")
        
        self.imgCollectionView.backgroundColor = CommonColors.whiteColor()
        
        self.logoContainerView.layer.cornerRadius = self.logoContainerView.bounds.width / 2
        self.logoContainerView.layer.masksToBounds = true
        self.logoContainerView.layer.shadowColor = UIColor(red: 163/255, green: 163/255, blue: 163/255, alpha: 0.5).cgColor
        self.logoContainerView.layer.shadowOffset = CGSize(width: 0, height:  2);
        self.logoContainerView.layer.shadowOpacity = 1;
        self.logoContainerView.layer.shadowRadius = 1;
        
        self.logoImgeView.layer.cornerRadius = self.logoImgeView.bounds.width / 2
        self.logoImgeView.layer.masksToBounds = true
        
        self.newsTypeLogoImageView.layer.cornerRadius = self.newsTypeLogoImageView.bounds.width / 2
        self.newsTypeLogoImageView.layer.masksToBounds = true
        
        self.firstDotView.layer.cornerRadius = self.firstDotView.bounds.width / 2
        self.firstDotView.layer.masksToBounds = true
        
        // nitin
        self.tagContainerView.canSelectTags = true
        self.tagContainerView.tagTextFont = CommonFonts.SFUIText_Regular(setsize: 14)
        self.tagContainerView.tagTextColor = CommonColors.lightGrayColor()
        self.tagContainerView.tagStrokeColor = CommonColors.globalRedColor()
        
        self.seondDotView.layer.cornerRadius = self.seondDotView.bounds.width / 2
        self.seondDotView.layer.masksToBounds = true
        
        self.bottomView.layer.shadowColor = UIColor(red: 136/255, green: 136/255, blue: 136/255, alpha: 1).cgColor
        self.bottomView.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.bottomView.layer.shadowOpacity = 0.4
        self.bottomView.layer.shadowRadius = 3
        
        self.readMoreBtn.layer.cornerRadius = 3.0
        self.readMoreBtn.clipsToBounds      = true
        
        self.mainImageView.image = CONTAINERPLACEHOLDER
        self.mainImageView.contentMode = .center
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.mainImageView.image = nil
        self.readMoreHostName.text = "" // nitin
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(moveToNextPage), userInfo: nil, repeats: true)
        self.mainImageView.image = CONTAINERPLACEHOLDER
        self.mainImageView.contentMode = .center
        self.viewsDotView.isHidden = true
        self.viewsCountLabel.isHidden = true
    }
    
    func moveToNextPage (){
        
        let pageWidth:CGFloat = self.imgCollectionView.frame.width
        let count = self.collectionView(self.imgCollectionView, numberOfItemsInSection: 0)
        let maxWidth:CGFloat = pageWidth * CGFloat(count)
        let contentOffset:CGFloat = self.imgCollectionView.contentOffset.x
        
        var slideToX = contentOffset + pageWidth
        
        if  contentOffset + pageWidth == maxWidth
        {
            slideToX = 0
        }
        
        self.imgCollectionView.scrollRectToVisible(CGRect(x:slideToX, y:0, width:pageWidth, height:self.imgCollectionView.frame.height), animated: true)
        CommonFunctions.delay(delay: 0.3) {
            self.setPageControllerPageNo()
        }
        
        
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        self.imgCollectionView.frame = CGRect(x: self.imgCollectionView.frame.origin.x,y: self.imgCollectionView.frame.origin.y,width: self.imgCollectionView.frame.size.width,height: self.imgCollectionView.frame.size.height)
        self.imgCollectionView.layoutIfNeeded()
        CATransaction.commit()
    }
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        CATransaction.commit()
    }
    
    func isVideoContent(contentType: String)-> Bool {
        
        self.tapView.isUserInteractionEnabled = false
        switch contentType {
        case BeepContentType.Image.rawValue :
            return false
            
        case BeepContentType.Vine.rawValue :
            return  true
            
        case BeepContentType.Youtube.rawValue :
            return  true
            
        case BeepContentType.Twitch.rawValue :
            return  true
            
        case BeepContentType.Mp4.rawValue :
            return  true
            
        case BeepContentType.FbVideo.rawValue :
            return  true
            
        case BeepContentType.Vimeo.rawValue :
            return  true
            
        case BeepContentType.Soundcloud.rawValue :
            return  true
            
        default:
            return  false
        }
    }
    
    func galleryImgSetup() {
        
        for temp in self.beepMedia {
            if let contentType = temp["contentType"] as? String  {
                
                if !self.isVideoContent(contentType: contentType) {
                    if let contentURL = temp["contentURL"] as? String {
                        print_debug(object: contentURL)
                        if contentURL.characters.count > 0  {
                            let photo = SKPhoto.photoWithImageURL(contentURL)
                            photo.shouldCachePhotoURLImage = true // you can use image cache by true(NSCache)
                            self.imagesGallery.append(photo)
                        }
                    }
                }
            }
        }
        
    }
    
    func configureCellForBeepDetail() {
        if isNotBeepDetail{
            self.imgCollectionView.delegate = nil
            self.imgCollectionView.dataSource = nil
        } else {
            self.imgCollectionView.delegate = self
            self.imgCollectionView.dataSource = self
        }
    }
    
}


//MARK:- UICollectionView Delegate & DataSource
//MARK:-
extension UserDataCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        print_debug(object: self.isNotBeepDetail)
        print_debug(object: self.moreCount)
        
        guard self.isNotBeepDetail else  {
            if self.moreCount == 0 {
                return 1
            }
            
            print_debug(object: self.isVideo)
            print_debug(object: self.beepInnerType)
            
            self.isVideo        = [Bool](repeating: false, count: self.moreCount)
            self.beepInnerType  = [BeepInnerType](repeating: BeepInnerType.Image, count: self.moreCount)
            
            print_debug(object: self.isVideo)
            print_debug(object: self.beepInnerType)
            return self.moreCount
        }
        
        if self.imageArrayURl.count < 5 {
            return self.imageArrayURl.count
        } else  {
            return 5
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageViewCell", for:  indexPath) as! ImageViewCell
        cell.loadingLbl.isHidden = false; cell.activityIndicator.isHidden = false; cell.mediaNotFoundLbl.isHidden = true
        cell.layoutIfNeeded() // nitin
        //cell.webView.contentMode = .Center
        cell.backgroundColor = CommonColors.whiteColor()
        cell.tralingConstraints.constant = 0
        if  self.isNotBeepDetail {
            cell.tapView.isHidden = true
            
            if self.moreCount == 0 {
                cell.imageView.image = CONTAINERPLACEHOLDER
            } else {
                if self.isImageHeightIsNan() {
                    cell.imageView.image = CONTAINERPLACEHOLDER
                } else {
                    cell.imageView.sd_setImage(with: self.imageArrayURl[indexPath.item], completed: { [weak self](image, error, cacheType, url) in
                        guard self != nil else {return}
                        if let newImage = image {
                            cell.imageView.image = newImage
                            cell.imageView.contentMode = .scaleAspectFill
                        } else {
                            cell.imageView.image = CONTAINERPLACEHOLDER
                        }
                    })
                }
                //cell.imageView.sd_setImage(with: self.imageArrayURl[indexPath.item], placeholderImage: CONTAINERPLACEHOLDER)
            }
            self.setTrallingConstraints(indexPath: indexPath, cell: cell)
        } else  {
            
            if self.moreCount == 0 {
                cell.tapView.isHidden = true
                cell.imageView.image = AppIconPLACEHOLDER
                cell.loadingLbl.isHidden = true; cell.activityIndicator.isHidden = true; cell.mediaNotFoundLbl.isHidden = true;
                cell.webView.isHidden = true
                cell.youTubePlayerView.isHidden = true
                cell.imageView.isHidden = false
                cell.imageView.contentMode = .center
                //cell.imageView.image = CONTAINERPLACEHOLDER
            } else {
                //TODO ::
                //self.pageController.numberOfPages = self.moreCount
                //self.pageController.currentPage = indexPath.row
                self.cellContentSetUP(indexPath: indexPath, cell: cell)
            }
            cell.youTubePlayerView.delegate = self
        }
        cell.layoutIfNeeded() // nitin
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.clipsToBounds = true
        cell.contentView.layoutIfNeeded()
        cell.layoutSubviews() // nitin
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        
        print_debug(object:  self.singleBeepHeightCons)
        return CGSize(width: SCREEN_WIDTH, height: self.singleBeepHeightCons)
        
        //return CGSize(width: SCREEN_WIDTH, height: 182)
        /*
         if isNotBeepDetail {
         return self.setCellSize(indexPath)
         } else  {
         return CGSize(width: SCREEN_WIDTH, height: 182)
         }*/
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        //set HorizontalDistance
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        //return self.tagVerticalDistance
        return 0.0000
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    func setTrallingConstraints(indexPath: IndexPath, cell: ImageViewCell) {
        
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
    
    func setCellSize(indexPath: IndexPath)-> CGSize {
        
        let cellSize: CGSize = CGSize(width: 0, height: 0)
        
        switch self.imageArrayURl.count {
        case 1,0:
            return CGSize(width: SCREEN_WIDTH, height: 182)
            
        case 2:
            return CGSize(width: (SCREEN_WIDTH/2), height: 182)
            
        case 3:
            switch indexPath.item {
            case 0:
                return CGSize(width:(SCREEN_WIDTH), height: 182/2)
            case 1:
                return CGSize(width: (SCREEN_WIDTH/2), height: 182/2)
            case 2:
                return CGSize(width: (SCREEN_WIDTH/2), height: (182/2))
            default:
                fatalError("Inside AllTagVC collectionViewLayout method.")
            }
            
        case 4:
            return CGSize(width: (SCREEN_WIDTH/2), height: 182/2)
            
        default:
            switch indexPath.item {
            case 0:
                return CGSize(width: (SCREEN_WIDTH/2), height: 182/2)
                
            case 1:
                return CGSize(width: (SCREEN_WIDTH/2), height: 182/2)
                
            case 2:
                return CGSize(width: (SCREEN_WIDTH/3)-0.00001, height: 182/2)
                
            case 3:
                return CGSize(width: (SCREEN_WIDTH/3)-0.00001, height: 182/2)
                
            case 4:
                return CGSize(width: (SCREEN_WIDTH/3), height: 182/2)
                
            default:
                fatalError("Inside AllTagVC collectionViewLayout method.")
                
            }
        }
        return cellSize
    }
    
    func cellContentSetUP(indexPath: IndexPath, cell: ImageViewCell) {
        //Creash//
        guard indexPath.item < self.beepMedia.count else {  return }
        
        if let contentType = self.beepMedia[indexPath.item]["contentType"] as? String {
            self.tapView.isUserInteractionEnabled = false
            switch contentType {
            case BeepContentType.Image.rawValue :
                self.isVideo[indexPath.row] = false
                self.beepInnerType[indexPath.row] = BeepInnerType.Image
                self.setImage(indexPath: indexPath, cell: cell)
                
            case BeepContentType.Vine.rawValue :
                self.isVideo[indexPath.row] = true
                self.beepInnerType[indexPath.row] = BeepInnerType.Video
                
            case BeepContentType.Youtube.rawValue :
                self.isVideo[indexPath.row] = true
                self.beepInnerType[indexPath.row] = BeepInnerType.Youtube
                
            case BeepContentType.Twitch.rawValue :
                self.isVideo[indexPath.row] = true
                self.beepInnerType[indexPath.row] = BeepInnerType.Video
                
            case BeepContentType.Mp4.rawValue :
                self.isVideo[indexPath.row] = true
                self.beepInnerType[indexPath.row] = BeepInnerType.MP4
                
            case BeepContentType.FbVideo.rawValue :
                self.isVideo[indexPath.row] = true
                self.beepInnerType[indexPath.row] = BeepInnerType.Video
                
            case BeepContentType.Vimeo.rawValue :
                self.isVideo[indexPath.row] = true
                self.beepInnerType[indexPath.row] = BeepInnerType.Video
                
            case BeepContentType.Soundcloud.rawValue :
                self.isVideo[indexPath.row] = true
                self.beepInnerType[indexPath.row] = BeepInnerType.Video
                
            default:
                self.isVideo[indexPath.row] = false
                self.beepInnerType[indexPath.row] = BeepInnerType.Image
                self.setImage(indexPath: indexPath, cell: cell)
                
            }
            
            
            cell.tapView.isUserInteractionEnabled = true
            
            let placeImg = UIImageView(frame: cell.tapView.frame)
            placeImg.tag = 100
            if let imageView = cell.tapView.viewWithTag(100) {
                imageView.removeFromSuperview()
            }
            
            if let imgURLs = beepMedia[indexPath.row]["imgURLs"] as? [String: AnyObject] {
                if let imgurl = imgURLs["img2x"] as? String {
                    if imgurl.isEmpty {
                        cell.playimg.isHidden = false
                        placeImg.backgroundColor = UIColor.gray
                    } else {
                        if let url = URL(string: imgurl) {
                            //placeImg.sd_setImage(with: url, completed: nil)
                            
                            placeImg.sd_setImage(with: url, placeholderImage: loadingPLACEHOLDER, options: .progressiveDownload, completed: { [weak self] (image, error, cacheType, imageURL) in
                                guard self != nil else {return}
                                // Perform operation.
                                if let img = image {
                                    placeImg.contentMode = .scaleToFill
                                }
                                // placeImg.contentMode = .scaleToFill
                                placeImg.layoutIfNeeded()
                                cell.layoutIfNeeded()
                            })
                            
                            cell.playimg.isHidden = true
                            placeImg.backgroundColor = UIColor.white
                        } else {
                            cell.playimg.isHidden = false
                            placeImg.backgroundColor = UIColor.gray
                        }
                    }
                }
            }
            //placeImg.image = UIImage(named: "c1")
            //placeImg.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: "content_placeholder"))
            
            cell.tapView.addSubview(placeImg)
            cell.tapView.bringSubview(toFront: cell.playimg)
            // placeImg.contentMode = .scaleToFill
            cell.layoutIfNeeded()
            
            let imageViewTap = UITapGestureRecognizer(target:self, action:#selector(UserDataCell.playVideo(img:)))
            cell.tapView.addGestureRecognizer(imageViewTap)
            
            switch self.beepInnerType[indexPath.row] {
            case BeepInnerType.Video :
                cell.tapView.isHidden = true
                cell.webView.isHidden = false
                cell.webView.delegate = self
                cell.webView.allowsInlineMediaPlayback = true
                cell.webView.scrollView.bounces = false
                cell.youTubePlayerView.isHidden = true
                cell.loadingLbl.isHidden = false
                cell.activityIndicator.isHidden = false
                cell.activityIndicator.startAnimating()
                guard let contentType = self.beepMedia[indexPath.row]["contentType"] as? String else { return }
                guard let id = self.beepMedia[indexPath.row]["id"] as? String else { return }
                self.setUrlVideo(contentType: contentType, id: id, webV: cell.webView, height: cell.webView.frame.height, row: indexPath.row)
                
            case BeepInnerType.Youtube:
                print_debug(object: "Youtube Video")
                cell.tapView.isHidden = false
                cell.webView.isHidden = true
                cell.activityIndicator.isHidden = true
                cell.loadingLbl.isHidden = true
                cell.youTubePlayerView.isHidden = false
                
                if let id = self.beepMedia[indexPath.row]["id"] as? String {
                    cell.youTubePlayerView.load(withVideoId: id)
                } else {
                    if let contentURL = self.beepMedia[indexPath.row]["contentURL"] as? String {
                        cell.youTubePlayerView.loadVideo(byURL: contentURL, startSeconds: 1.0, suggestedQuality: .auto)
                    }
                }
                
                cell.loadingLbl.isHidden = true
                cell.activityIndicator.isHidden = true
                cell.activityIndicator.startAnimating()
                
            case BeepInnerType.MP4:
                print_debug(object: "MP4 Video")
                cell.tapView.isHidden = false
                cell.youTubePlayerView.isHidden = true
                cell.webView.isHidden = true
                cell.loadingLbl.isHidden = true
                cell.activityIndicator.isHidden = true
                
            default:
                cell.tapView.isHidden = false
                cell.webView.isHidden = true
                cell.activityIndicator.isHidden = true
                cell.loadingLbl.isHidden = true
                cell.youTubePlayerView.isHidden = true
            }
            /*
             if self.isVideo[indexPath.row] {
             cell.tapView.isHidden = true
             cell.webView.isHidden = false
             cell.webView.delegate = self
             cell.webView.allowsInlineMediaPlayback = true
             cell.webView.scrollView.bounces = false
             cell.activityIndicator.startAnimating()
             guard let contentType = self.beepMedia[indexPath.row]["contentType"] as? String else { return }
             guard let id = self.beepMedia[indexPath.row]["id"] as? String else { return }
             self.setUrlVideo(contentType, id: id, webV: cell.webView, height: cell.webView.frame.height, row: indexPath.row)
             } else {
             cell.tapView.isHidden = false
             cell.webView.isHidden = true
             cell.activityIndicator.isHidden = true
             cell.loadingLbl.isHidden = true
             }*/
        }
        
    }
    
    func setImage(indexPath: IndexPath, cell: ImageViewCell) {
        
        
        
        if self.isImageHeightIsNan() {
            cell.imageView.image = CONTAINERPLACEHOLDER
            cell.imageView.contentMode = .center
        }else {
            if let imgURLs = self.beepMedia[indexPath.row]["imgURLs"] as? [String: AnyObject] {
                if let url = imgURLs["img2x"] as? String {
                    
                    //cell.imageView.sd_setImage(with: , placeholderImage: CONTAINERPLACEHOLDER)
                    cell.imageView.sd_setImage(with: URL(string: url), placeholderImage: loadingPLACEHOLDER, options: .continueInBackground, completed: { [weak self] (img, error, tempCatch, url) in
                        guard self != nil else {return}
                        if  let img2xH = imgURLs["img2xH"] as? Int {
                            if let img2xW = imgURLs["img2xW"] as? Int {
                                let ratio = (CGFloat(img2xH)/CGFloat(img2xW)) * (SCREEN_WIDTH)
                                if ratio <= 180 {
                                    cell.imageView.contentMode = .scaleToFill //240
                                } else {
                                    //return ratio
                                    if ratio.isNaN {
                                        cell.imageView.contentMode = .scaleToFill
                                    } else {
                                        cell.imageView.contentMode = .scaleAspectFill
                                    }
                                    
                                }
                            }
                        }
                        
                    })
                } else {
                    cell.imageView.image = CONTAINERPLACEHOLDER
                    cell.imageView.contentMode = .center
                }
            } else {
                cell.imageView.image = CONTAINERPLACEHOLDER
                cell.imageView.contentMode = .center
            }
        }
    }
    
    func youtubePlayerSetup(indexPath: IndexPath, cell: ImageViewCell) {
        
    }
    
    func playVideo(img: UIGestureRecognizer) {
        
        guard let currentIndexPath = img.view?.collectionViewIndexPath(collectionView: self.imgCollectionView) else { return }
        
        guard let cell = self.imgCollectionView.cellForItem(at: currentIndexPath)as? ImageViewCell else { return }
        
        guard let contentType = self.beepMedia[currentIndexPath.item]["contentType"] as? String else {return}
        
        var beepType = BeepInnerType.Image
        
        self.tapView.isUserInteractionEnabled = false
        switch contentType {
        case BeepContentType.Image.rawValue :
            beepType = BeepInnerType.Image
            
        case BeepContentType.Vine.rawValue :
            beepType = BeepInnerType.Video
            
        case BeepContentType.Youtube.rawValue :
            
            beepType = BeepInnerType.Youtube
            
        case BeepContentType.Twitch.rawValue :
            beepType = BeepInnerType.Video
            
        case BeepContentType.Mp4.rawValue :
            beepType = BeepInnerType.MP4
            
        case BeepContentType.FbVideo.rawValue :
            
            beepType = BeepInnerType.Video
            
        case BeepContentType.Vimeo.rawValue :
            beepType = BeepInnerType.Video
            
        case BeepContentType.Soundcloud.rawValue :
            beepType = BeepInnerType.Video
            
        default:
            beepType = BeepInnerType.Image
            
        }
        
        
        
        switch beepType {
        case .MP4:
            print_debug(object: "MP4 Video")
            if let contentURL = self.beepMedia[currentIndexPath.row]["contentURL"] as? String {
                if CommonFunctions.verifyUrl(urlString: contentURL) {
                    let url = URL(string: contentURL)
                    let player = AVPlayer(url: url!)
                    let playerController = AVPlayerViewController()
                    playerController.player = player
                    
                    self.topMostController().present(playerController, animated: true, completion: {
                        player.play()
                    })
                }
                
            }
            
        case .Youtube:
            print_debug(object: "Youtube player")
            return
            
        case .Video:
            print_debug(object: "Normal player")
            return
            
        default:
            cell.webView.isHidden = true
            var images = [SKPhoto]()
            for temp in self.beepMedia {
                if let contentType = temp["contentType"] as? String  {
                    
                    if !self.isVideoContent(contentType: contentType) {
                        if let contentURL = temp["contentURL"] as? String {
                            print_debug(object: contentURL)
                            if !contentURL.isEmpty  {
                                let photo = SKPhoto.photoWithImageURL(contentURL)
                                photo.shouldCachePhotoURLImage = true // you can use image cache by true(NSCache)
                                images.append(photo)
                            }
                        }
                    }
                }
            }
            
            if images.count > 0 {
                
                let browser = SKPhotoBrowser(photos: images)
                browser.delegate = self
                browser.initializePageIndex(currentIndexPath.row)
                self.topMostController().present(browser, animated: true, completion: {
                    
                    APP_DELEGATE.setStatusBarHidden(true, with: .slide)
                })
            }
        }
        
        /* if self.isVideo[currentIndexPath.row] {
         print_debug(object: "this is video")
         
         
         //cell.webView.isHidden = false
         //cell.webView.delegate = self
         //cell.webView.allowsInlineMediaPlayback = true
         //cell.webView.scrollView.bounces = false
         
         
         
         //            let org = cell.tapView.frame.origin
         //            let height = cell.tapView.frame.height
         //            let rec = CGRect(origin: org, size: CGSize(width: SCREEN_WIDTH, height: height))
         
         //            var webV:UIWebView!
         //            webV = UIWebView(frame: rec)
         //            webV.allowsInlineMediaPlayback = true
         //            webV.scrollView.bounces = false
         //            //webV.delegate = self
         //            cell.tapView.addSubview(webV)
         
         //guard let contentType = self.beepMedia[currentIndexPath.row]["contentType"] as? String else { return }
         //guard let id = self.beepMedia[currentIndexPath.row]["id"] as? String else { return }
         //self.setUrlVideo(contentType, id: id, webV: webV, height: height, row: currentIndexPath.row)
         
         //self.setUrlVideo(contentType, id: id, webV: cell.webView, height: cell.tapView.frame.height, row: currentIndexPath.row)
         
         } else {
         
         cell.webView.isHidden = true
         var images = [SKPhoto]()
         for temp in self.beepMedia {
         if let contentType = temp["contentType"] as? String  {
         
         if !self.isVideoContent(contentType) {
         if let contentURL = temp["contentURL"] as? String {
         print_debug(object: contentURL)
         if contentURL.characters.count > 0  {
         let photo = SKPhoto.photoWithImageURL(contentURL)
         photo.shouldCachePhotoURLImage = true // you can use image cache by true(NSCache)
         images.append(photo)
         }
         }
         }
         }
         }
         
         
         if images.count > 0 {
         let browser = SKPhotoBrowser(photos: images)
         browser.delegate = self
         browser.initializePageIndex(currentIndexPath.row)
         SHARED_APP_DELEGATE.window?.rootViewController?.present(browser, animated: true, completion: {
         
         APP_DELEGATE.setStatusBarHidden(true, withAnimation: .Slide)
         })
         }
         
         
         } */
    }
    
    func openGallery(img: UIGestureRecognizer) {
        
        print_debug(object: "Open Gallery")
    }
    
    func setUrlVideo(contentType: String, id: String, webV: UIWebView, height: CGFloat, row: Int) {
        
        var htmlString = ""
        
        switch contentType {
        case BeepContentType.Image.rawValue :
            break
            
        case BeepContentType.Vine.rawValue :
            //Vine demo video id = 5jDKEZL3glP
            let videoUrl = " https://vine.co/v/\(id)/card?mute=1"
            htmlString = " <div class=\"video\" style=\"width: \(SCREEN_WIDTH-16); height: \(height-16); overflow: hidden; position: relative;\"> <iframe \\class=  \"vine-embed\"  src=\(videoUrl) frameborder=\"0\"> </iframe> "
            
        case BeepContentType.Youtube.rawValue :
            //Youtube demo video id = iMx5FH3FupB
            let videoUrl = "https://www.youtube.com/embed/\(id)?rel=0&amp;fs=0&amp;showinfo=0&origin=https://www.fantasticoh.com"
            htmlString = "<iframe width = \(SCREEN_WIDTH-16) height = \(height-16) src = \" \(videoUrl)/playsinline=1 \" frameborder = \"0\" allowfullscreen=\"false\" \" ></iframe>"
            //htmlString = "<iframe width = \(SCREEN_WIDTH-16) width = \("100%") height = \("100%") src = \" \(videoUrl)/playsinline=1 \" frameborder = \"0\" allowfullscreen=\"false\" \" ></iframe>"
            
        case BeepContentType.Twitch.rawValue :
            //Twitch demo video id = 98909286
            let videoUrl = "http://player.twitch.tv/?video=\(id)"
            htmlString = " <iframe src=\"\(videoUrl)\" width = \(SCREEN_WIDTH-16) height = \(height-16) frameborder=\"0\" allowTransparency=\"true\" scrolling=\"no\" allowfullscreen=\"true\"></iframe> "
            
        case BeepContentType.Mp4.rawValue :
            //demo video url : https://content.jwplatform.com/manifests/vM7nH0Kl.m3u8
            
            var imgUrl = ""
            guard let contentURL = self.beepMedia[row]["contentURL"] as? String else { return }
            if let imgURLs = self.beepMedia[row]["imgURLs"] as? [String : AnyObject] {
                if let img2x = imgURLs["img2x"] as? String {
                    imgUrl = img2x
                }
            }
            
            htmlString = " <video style=\"border: 0px solid rgba(0,0,0,.05)\" width=\(SCREEN_WIDTH-16) height=\(height-16) poster=\(imgUrl) preload controls><source src=\(contentURL)></video> "
            
            
        case BeepContentType.FbVideo.rawValue :
            
            //Client fb app id = 1743818985846058
            //fb demo video id = 10154021746253553
            let videoUrl = "https://www.facebook.com/plugins/video.php?href=https%3A%2F%2Fwww.facebook.com%2Fbrightside%2Fvideos%2F\(id)%2F&show_text=0&appId=1743818985846058"
            htmlString = " <iframe src=\"\(videoUrl)\" width=\"\(SCREEN_WIDTH-16)\" height= \"\(height-16)\" style=\"border:none;overflow:hidden\" scrolling=\"no\" frameborder=\"0\" allowTransparency=\"true\" allowFullScreen=\"true\"></iframe> "
            
        case BeepContentType.Vimeo.rawValue :
            //Vimeo demo video id = 187772116
            let videoUrl = "https://player.vimeo.com/video/\(id)?autoplay=1&quality=auto"
            htmlString = " <iframe src=\"\(videoUrl)\" width= \(SCREEN_WIDTH-16) height=\(height-16) frameborder=\"0\" allowTransparency=\"true\" scrolling=\"no\" allowfullscreen=\"true\"></iframe> "
            
        case BeepContentType.Soundcloud.rawValue :
            //Soundcloud demo audio id = 280186218
            let audioUrl = " https://w.soundcloud.com/player/?url=https%3A//api.soundcloud.com/tracks/\(id)&amp;auto_play=false&amp;hide_related=false&amp;show_comments=true&amp;show_user=true&amp;show_reposts=false&amp;visual=true "
            htmlString = " <iframe width = \(SCREEN_WIDTH-16) height = \(height-16) scrolling=\"no\" frameborder=\"no\" src=\(audioUrl) liking=\"false\" sharing=\"false\" show_playcount=\"true\" show_user=\"true\" ></iframe> "
            
            
        default:
            break
            
        }
        //let tempId = "280186218"
        //let audioUrl = " https://w.soundcloud.com/player/?url=https%3A//api.soundcloud.com/tracks/\(tempId)&amp;auto_play=false&amp;hide_related=false&amp;show_comments=true&amp;show_user=true&amp;show_reposts=false&amp;visual=true "
        //htmlString = " <iframe width = \(SCREEN_WIDTH-16) height = \(height-16) scrolling=\"no\" frameborder=\"no\" src=\(audioUrl) liking=\"false\" sharing=\"false\" show_playcount=\"true\" show_user=\"true\" ></iframe> "
        
        
        webV.loadHTMLString(htmlString, baseURL: nil)
        
        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.setPageControllerPageNo()
    }
    
    func setPageControllerPageNo() {
        var visibleRect = CGRect()
        
        visibleRect.origin = self.imgCollectionView.contentOffset
        visibleRect.size = self.imgCollectionView.bounds.size
        
        let visiblePoint = CGPoint(x: visibleRect.midX,y: visibleRect.midY)
        
        let visibleIndexPath: IndexPath = self.imgCollectionView.indexPathForItem(at: visiblePoint) ?? IndexPath(row: 0, section: 0)
        
        
        self.pageController.currentPage = visibleIndexPath.row
        self.updatePageControl()
    }
    
    
    
}


//MARK:- SKPhotoBrowserDelegate
//MARK:-
extension UserDataCell :  SKPhotoBrowserDelegate {
    
    func didDismissAtPageIndex(_ index: Int) {
        
        APP_DELEGATE.setStatusBarHidden(false, with: .slide)
        
    }
    
    
}


//MARK:- UIWebViewDelegate
//MARK:-
extension UserDataCell: UIWebViewDelegate {
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        
        
        guard let currentIndexPath = webView.collectionViewIndexPath(collectionView: self.imgCollectionView) else { return }
        
        guard let cell = self.imgCollectionView.cellForItem(at: currentIndexPath)as? ImageViewCell else { return }
        
        CommonFunctions.delay(delay: 1.2, closure: {
            cell.activityIndicator.isHidden = true
            cell.loadingLbl.isHidden = true
        })
        
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        
    }
}

//MARK:- Video setup method's
//MARK:-
extension UserDataCell {
    
    internal func setUpVideo() {
        
        player.isMuted = true
        self.invisivalButton.isHidden = true
        
        //self.tapView.backgroundColor = UIColor.clear
        //self.tapView.clipsToBounds = true
        
        self.playerLayer = AVPlayerLayer(player: player)
        self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        
        self.playerLayer.needsDisplayOnBoundsChange = true
        
        //self.tapView.layer.insertSublayer(self.playerLayer, atIndex: 0)
        
        let viewTap = UITapGestureRecognizer(target:self, action:#selector(UserDataCell.blurViewTap(sender:)))
        self.blurView.isUserInteractionEnabled = true
        self.blurView.addGestureRecognizer(viewTap)
        //self.tapView.addSubview(self.blurView)
        
        
        //self.tapView.addSubview(self.invisivalButton)
        self.invisivalButton.addTarget(self, action: #selector(UserDataCell.invisibleButtonTapped(sender:)), for: .touchUpInside)
        
        
        self.timeRemainingLabel.textColor = .white
        self.timeRemainingLabel.text = "00:00"
        self.timeRemainingLabel.clipsToBounds = true
        //self.tapView.addSubview(timeRemainingLabel)
        
        
        self.seekSlider.minimumTrackTintColor = UIColor.red
        self.seekSlider.maximumTrackTintColor = UIColor.white
        self.seekSlider.thumbTintColor = UIColor.lightGray
        self.seekSlider.setThumbImage(UIImage(named: "seector"), for:  .highlighted)
        self.seekSlider.setThumbImage(UIImage(named: "seector"), for:  .normal)
        //self.tapView.addSubview(self.seekSlider)
        self.seekSlider.addTarget(self, action: #selector(UserDataCell.sliderBeganTracking(slider:)), for: .touchUpInside)
        self.seekSlider.addTarget(self, action: #selector(UserDataCell.sliderEndedTracking(slider:)), for: [.touchUpInside, .touchUpOutside])
        self.seekSlider.addTarget(self, action: #selector(UserDataCell.sliderValueChanged(slider:)), for: .valueChanged)
        
        let url = URL(string: "https://content.jwplatform.com/manifests/vM7nH0Kl.m3u8")
        
        let playerItem = AVPlayerItem(url: url!)
        player.replaceCurrentItem(with: playerItem)
        
        let timeInterval: CMTime = CMTimeMakeWithSeconds(1.0, 50)
        timeObserver = player.addPeriodicTimeObserver(forInterval: timeInterval, queue: DispatchQueue.main, using: { (elapsedTime: CMTime) -> Void in
            
            self.observeTime(elapsedTime: elapsedTime)
        }) as AnyObject
        
        //TO DO :: set image in bg.
        self.setContainerFrame()
        self.player.play()
    }
    
    func setContainerFrame() {
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        //self.tapView.backgroundColor = UIColor.lightTextColor()
        //let pHeight = self.tapView.bounds.size.height
        //let pWidth = SCREEN_WIDTH//self.tapView.bounds.size.width
        //let pOrigin = self.tapView.bounds.origin
        
        //self.playerLayer.frame = CGRect(origin: pOrigin, size: CGSize(width: pWidth, height: pHeight))
        
        //Paush & play button formate
        let originX: CGFloat = (SCREEN_WIDTH/2) - 25
        let originY: CGFloat = ((182/2) - 25)
        self.invisivalButton.frame = CGRect(x: originX, y: originY, width: 50, height: 50)
        self.invisivalButton.clipsToBounds = true
        
        //Remain time label frame
        //let controlsHeight: CGFloat = 25
        
        //let controlsY: CGFloat = self.tapView.bounds.size.height - 25 //view.bounds.size.height - controlsHeight
        //timeRemainingLabel.frame = CGRect(x: (SCREEN_WIDTH-50), y: controlsY, width: 60, height: controlsHeight)
        //self.timeRemainingLabel.clipsToBounds = true
        
        //SeekSlide frame
        //let x: CGFloat = 15
        //let y: CGFloat = controlsY
        //let sWidth: CGFloat = SCREEN_WIDTH - (85)//view.bounds.size.width - (100)
        //let sHeight: CGFloat = controlsHeight
        //seekSlider.frame = CGRect(x: x, y: y, width: sWidth, height: sHeight)
        //self.seekSlider.clipsToBounds = true
        
        //self.blurView.frame = self.tapView.bounds
        self.blurView.clipsToBounds = true
        CATransaction.commit()
    }
    
    //Timer Update
    func observeTime(elapsedTime: CMTime) {
        let duration = CMTimeGetSeconds(player.currentItem!.duration)
        let infinity = Double.infinity
        
        if duration < infinity  {
            let elapsedTime = CMTimeGetSeconds(elapsedTime)
            updateTimeLabel(elapsedTime: elapsedTime, duration: duration)
        }
    }
    
    func blurViewTap(sender: UIGestureRecognizer) {
        
        _ = player.rate > 0
        
        if self.blureViewFlag {
            self.invisivalButton.isHidden = false
            self.showController()
        } else {
            self.invisivalButton.isHidden = true
            self.hideController()
        }
        blureViewFlag = !blureViewFlag
        
    }
    
    
    //Video play & pause
    func invisibleButtonTapped(sender: UIButton) {
        
        let playerIsPlaying = player.rate > 0
        if playerIsPlaying {
            
            player.pause()
            self.blureViewFlag = !self.blureViewFlag
            self.showController()
        } else  {
            player.play()
            self.hideController()
        }
        
    }
    
    func updateTimeLabel(elapsedTime: Float64, duration: Float64) {
        let timeRemaining: Float64 = CMTimeGetSeconds(player.currentItem!.duration) - elapsedTime
        
        if timeRemaining > 0 {
            timeRemainingLabel.text = String(format: "%02d:%02d", ((lround(timeRemaining) / 60) % 60), lround(timeRemaining) % 60)
        }
        
    }
    
    //Slide time Observer
    func sliderBeganTracking(slider: UISlider) {
        
        playerRateBeforeSeek = player.rate
    }
    
    func sliderEndedTracking(slider: UISlider) {
        
        let videoDuration = CMTimeGetSeconds(player.currentItem!.duration)
        let elapsedTime: Float64 = videoDuration * Float64(seekSlider.value)
        updateTimeLabel(elapsedTime: elapsedTime, duration: videoDuration)
        
        player.seek(to: CMTimeMakeWithSeconds(elapsedTime, 100)) { (completed: Bool) -> Void in
            
            if self.playerRateBeforeSeek > 0 {
                self.player.play()
            }
        }
        
    }
    
    func sliderValueChanged(slider: UISlider) {
        
        let videoDuration = CMTimeGetSeconds(player.currentItem!.duration)
        let elapsedTime: Float64 = videoDuration * Float64(seekSlider.value)
        updateTimeLabel(elapsedTime: elapsedTime, duration: videoDuration)
        
        if videoDuration == elapsedTime {
            
            print("Video end.")
            timeRemainingLabel.text = "00:00"
            seekSlider.value = 0
        } else if elapsedTime == 1 {
            
            
        }
        
        print(elapsedTime)
    }
    
    func hideController() {
        
        self.invisivalButton.setImage(UIImage(), for: .normal)
        self.blurView.backgroundColor = UIColor.clear
        self.timeRemainingLabel.isHidden = true
        self.seekSlider.isHidden = true
        
    }
    
    func showController() {
        
        self.invisivalButton.setImage(UIImage(named: "video_play_button"), for:  .normal)
        self.blurView.backgroundColor = UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 0.5)
        self.timeRemainingLabel.isHidden = false
        self.seekSlider.isHidden = false
    }
    
    func topMostController() -> UIViewController {
        var topController: UIViewController = (SHARED_APP_DELEGATE.window?.rootViewController)!
        while (topController.presentedViewController != nil) {
            topController = topController.presentedViewController!
        }
        return topController
    }
    
    
    func updatePageControl() {
        
        for (_, dot) in self.pageController.subviews.enumerated() {
            
            var dotFrame = dot.frame
            //            dotFrame.origin.x = -6
            //            dotFrame.origin.y = -6
            dotFrame.size.height = 12
            dotFrame.size.width = 12
            dot.frame = dotFrame
            dot.layer.cornerRadius = 7
            dot.clipsToBounds = true
        }
    }
    
    
    func isImageHeightIsNan()-> Bool {
        
        if let meta = self.metaData["meta"] as? [String : AnyObject] {
            if let tempBeepMedia = meta["beepMedia"] as? [AnyObject] {
                
                if tempBeepMedia.count == 0 {
                    return false
                } else {
                    if let beepMedia = tempBeepMedia.first {
                        guard let urls = beepMedia["imgURLs"] as? [String : AnyObject] else { return  false }
                        print_debug(object: urls)
                        if  let img2xH = urls["img2xH"] as? Int {
                            if let img2xW = urls["img2xW"] as? Int {
                                let ratio = (CGFloat(img2xH)/CGFloat(img2xW)) * SCREEN_WIDTH
                                
                                if ratio.isNaN {
                                    return true
                                }
                            }
                        }
                    }
                }
            }
        }
        return false
    }
    
    
    
    
}

extension UserDataCell : YTPlayerViewDelegate {
    func playerView(_ playerView: YTPlayerView, receivedError error: YTPlayerError) {
        print_debug(object: "playerView receivedError")
        print_debug(object: error)
        self.imgCollectionView.reloadData()
    }
    
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        print_debug(object: "playerViewDidBecomeReady")
    }
    
    func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerState) {
        print_debug(object: "playerView didChangeTo State")
        print_debug(object: state)
    }
}
