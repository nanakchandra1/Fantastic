
//
//  AllTagVC.swift
//  Fantasticoh!
//
//  Created by Shubham on 8/2/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//(317.0, 46.0)

import UIKit
import SkeletonView
import FBAudienceNetwork

protocol AllTagVCDelegate : class {
    func beepDataReload()
    func fromBeepDetailDataReload(beepId: String, updateData: [String: AnyObject])
    func fromChannelDetailDataReload(updateData: [AnyObject])
}

enum SourctTypeEnum: String {
    
    case twitter    = "twitter"
    case facebook   = "facebook"
    case youtube    = "youtube"
    case vimeo      = "vimeo"
    case instagram  = "instagram"
    case pinterest  = "pinterest"
    case soundcloud = "soundcloud"
    case foursquare = "foursquare"
    case vine       = "vine"
    case twitch     = "twitch"
    case flickr     = "flickr"
    case tumblr     = "tumblr"
    case google     = "google"
    case gplus      = "gplus"
}



enum BeepContentType : String {
    case  Image = "image"
    case Vine = "vine"
    case Youtube = "youtube"
    case Twitch = "twitch"
    case Mp4 = "mp4"
    case FbVideo = "fbvideo"
    case Vimeo = "vimeo"
    case Soundcloud = "soundcloud"
}




/*
 enum BeepContentType : String {
 case  Image = "image", Vine = "vine", Youtube = "youtube", Twitch = "twitch", Mp4 = "mp4", FbVideo = "fbvideo",
 Vimeo = "vimeo", Soundcloud = "soundcloud"
 
 static let allValues = [Image, Vine, Youtube, Twitch, Mp4, FbVideo, Vimeo, Soundcloud]
 } */

class AllTagVC: UIViewController {
    
    //MARK:- IBOutlet & Propertie's
    //MARK:-
    @IBOutlet weak var dataTableView: UITableView!
    @IBOutlet weak var noDataLbl: UILabel!
    @IBOutlet weak var mesaggingBtn: UIButton!
    
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var unreadMsgCountLabel: UILabel!
    @IBOutlet weak var mesaggingBtnBottomCons: NSLayoutConstraint!
    @IBOutlet weak var searchLabel: UILabel!
    
    
    var refreshControl: UIRefreshControl!
    
    weak var delegate: TabBarDelegate!
    
    var userId = ""
    var featureChannel = [String: AnyObject]()
    var featureChannelsId = String()
    var descriptionText = [String]()
    
    var tags = [[String]]()
    var beepData = [AnyObject]()
    var AdDataCounter:Int = 0
    var beepCounter  :Int = 0
    var vcTag = ""
    var from = 0
    let size = 10
    var currentRow = 0
    var nextCount  = 1
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: .white)
    var beepIsVideo = false
    var beepDimention = [CGFloat]()
    var feedRequestComplete = false
    var channelRequestComplete = false
    let dateFormat = DateFormatter()
    var channelName:String = ""
    
    var nativeAd:FBNativeAd!
    var interView:FBInterstitialAd!
    
    
    //MARK:- View Life Cycle
    //MARK:-
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        interView = FBInterstitialAd(placementID: "406106493152859_407795332983975")
        interView.delegate = self
        
        //let id = FBAdSettings.testDeviceHash()
        // FBAdSettings.addTestDevice(id)
        if FB_AD == false {
            FB_AD = true
            // interView.load()
        }
        
        
        FBAdSettings.addTestDevice(FBAdSettings.testDeviceHash())
        
        ///*******************************************
        
        nativeAd = FBNativeAd(placementID: "1743818985846058_2097674140460539")
        nativeAd.delegate = self
        
        nativeAd.load()
        
        
        ALLTAGVCDELEGATE = self
        self.dataTableView.delegate = self
        self.dataTableView.dataSource = self
        self.dataTableView.isScrollEnabled = false
        if #available(iOS 10.0, *) {
            self.dataTableView.prefetchDataSource = self
        }
        dataTableView.layer.shouldRasterize = true;
        dataTableView.layer.rasterizationScale = UIScreen.main.scale;
        self.refreshControl = UIRefreshControl()
        self.dataTableView.addSubview(refreshControl)
        self.refreshControl.tintColor = CommonColors.globalRedColor()
        self.refreshControl.addTarget(self, action: #selector(AllTagVC.refresh(sender:)), for: UIControlEvents.valueChanged)
        
        self.spinner.color = CommonColors.globalRedColor()
        self.spinner.startAnimating()
        self.spinner.frame = CGRect(x:0,y: 0,width: SCREEN_WIDTH,height: 28)
        self.dataTableView.tableFooterView = spinner
        
        self.unreadMsgCountLabel.layer.cornerRadius = self.unreadMsgCountLabel.frame.size.height/2
        self.unreadMsgCountLabel.layer.borderColor = CommonColors.globalRedColor().cgColor
        self.unreadMsgCountLabel.textColor = CommonColors.globalRedColor()
        self.unreadMsgCountLabel.backgroundColor = UIColor.white
        self.unreadMsgCountLabel.layer.borderWidth = 1.0
        
        
        let userDataCell = UINib(nibName: "UserDataCell", bundle: nil)
        self.dataTableView.register(userDataCell, forCellReuseIdentifier: "UserDataCell")
        
        let fanClubeCell = UINib(nibName: "FanCellXIB", bundle: nil)
        self.dataTableView.register(fanClubeCell, forCellReuseIdentifier: "FanCellXIB")
        
        let seeAllCell = UINib(nibName: "SeeAllCell", bundle: nil)
        self.dataTableView.register(seeAllCell, forCellReuseIdentifier: "SeeAllCell")
        
        let UserDataPlaceholderCell = UINib(nibName: "UserDataPlaceholderCell", bundle: nil)
        self.dataTableView.register(UserDataPlaceholderCell, forCellReuseIdentifier: "UserDataPlaceholderCell")
        
        let nativeCell = UINib(nibName: "NativeAdTableViewCell", bundle: nil)
        self.dataTableView.register(nativeCell, forCellReuseIdentifier: "NativeAdTableViewCell")
        
        
        // CommonFunctions.showLoader() // nitin
        self.setInitData()
        
        if !self.vcTag.isEmpty {
            
            Globals.setScreenName(screenName: self.vcTag, screenClass: self.vcTag)
        }
        
        if CommonFunctions.checkLogin() {
            let _ = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(getUnreadMsgCount), userInfo: nil, repeats: true)
        }
        _ = self.is3DTouchAvailable()
        // nitin
        self.noDataLbl.text = CommonTexts.pleaseFollowChannels
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        APP_DELEGATE.statusBarStyle = UIStatusBarStyle.lightContent
        //self.setPopup()
        
        //self.messageBtnHideShow(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        print_debug(object: "not showing")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //self.messageBtnHideShow(false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.view.layoutIfNeeded()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.view.layoutIfNeeded()
    }
    
    //MARK:- IBAction, Selector &  Method
    //MARK:-
    
    func setInitData() {
        
        //        self.featureChannel.removeAll(keepingCapacity: false)
        //        self.featureChannelsId.removeAll(keepingCapacity: false)
        //        self.descriptionText.removeAll(keepingCapacity: false)
        //        self.beepDimention.removeAll(keepingCapacity: false)
        //        self.tags.removeAll(keepingCapacity: false)
        //        self.beepData.removeAll(keepingCapacity: false)
        
        //Get Feature channels
        self.getFeatureChannelList()
        
        //Get Beeps
        //        if let id = CurrentUser.userId {
        //
        //            if id.isEmpty {
        //                self.userId = ""
        //                self.getFeatureChannelId()
        //            } else {
        //                self.userId = id
        //
        //                var param : [String: AnyObject] = ["uid" : id as AnyObject]
        //                param["followingChannels"] = "" as AnyObject
        //                param["hashtags"] = self.vcTag as AnyObject
        //                param["from"] = 0 as AnyObject
        //                param["size"] = self.size as AnyObject
        //
        //                let url = WS_beeps + "user"
        //                self.getDashBoardData(url: url, param: param)
        //            }
        //
        //        } else {
        //
        //            self.userId = ""
        //            self.getFeatureChannelId()
        //        }
        
        self.getBeepData()
        
    }
    
    func getBeepData() {
        if let id = CurrentUser.userId {
            
            if id.isEmpty {
                self.userId = ""
                self.getFeatureChannelId()
            } else {
                self.userId = id
                
                var param : [String: AnyObject] = ["uid" : id as AnyObject]
                param["followingChannels"] = "" as AnyObject
                param["hashtags"] = self.vcTag as AnyObject
                param["from"] = 0 as AnyObject
                param["size"] = self.size as AnyObject
                self.beepCounter = 0
                let url = WS_beeps + "user"
                self.getDashBoardData(url: url, param: param)
            }
            
        } else {
            
            self.userId = ""
            self.getFeatureChannelId()
        }
    }
    
    func refresh(sender: AnyObject) {
        
        self.setInitData()
        
        if let re = sender as? UIRefreshControl {
            print_debug(object: re)
        }
    }
    
    func setPopup() {
        
        if let newUserFlag = UserDefaults.getBoolVal(key: NSUserDefaultKeys.ISNEWUSER) {
            if newUserFlag {
                CommonFunctions.delay(delay: 1, closure: {
                    
                    let alertPopup = self.storyboard?.instantiateViewController(withIdentifier:"WelcomePopupVC") as! WelcomePopupVC
                    let formSheet = MZFormSheetController(size: CGSize(width:SCREEN_WIDTH - ((SCREEN_WIDTH*110)/600),height: SCREEN_HEIGHT - ((SCREEN_HEIGHT*250)/600)), viewController: alertPopup)
                    formSheet.shouldCenterVertically = true
                    formSheet.transitionStyle = MZFormSheetTransitionStyle.dropDown
                    formSheet.shouldDismissOnBackgroundViewTap = false
                    formSheet.present(animated: true, completionHandler: { (vc: UIViewController) in
                        UserDefaults.setBoolVal(state: false, forKey: NSUserDefaultKeys.ISNEWUSER)
                    })
                })
            }
        }
        
    }
    
    func likeBtnTap(sender:UIButton) {
        
        guard CommonFunctions.checkLogin() else {
            CommonFunctions.showLoginAlert(vc: self)
            return
        }
        
        guard let currentIndexPath = sender.tableViewIndexPath(tableView: self.dataTableView) else { return }
        guard let cell = self.dataTableView.cellForRow(at: currentIndexPath as IndexPath) as? UserDataCell else { return }
        guard let beep = self.beepData[currentIndexPath.row]["beep"] as? [String : AnyObject] else { return }
        guard let meta = self.beepData[currentIndexPath.row]["meta"] as? [String : AnyObject] else { return }
        var beepid = ""
        if let id = beep["id"] as? String {
            beepid = id
        }
        
        if !sender.isSelected {
            let count = Int(cell.likeCountLbl.text!)
            cell.likeCountLbl.text = "\(count!+1)"
            
            //cell.likeBtn.likeBounce(0.0)
            cell.likeBtn.animate()
            
            sender.isSelected = true
            var data = [String:AnyObject]()
            var tempBeep = beep
            var tempMeta = meta
            if var countLikes = beep["countLikes"] as? Int {
                countLikes =  countLikes + 1
                tempBeep["countLikes"] = countLikes as AnyObject
                
                data["beep"] = tempBeep as AnyObject
                self.beepData[currentIndexPath.row] = data as AnyObject
            }
            if var isLike = meta["userLiked"] as? Bool {
                isLike = true
                tempMeta["userLiked"] = isLike as AnyObject
                
                data["meta"] = tempMeta as AnyObject
                self.beepData[currentIndexPath.row] = data as AnyObject
            }
            self.likeBeep(beepid: beepid, flag: true)
            /*if let source = beep["source"] as? [String : AnyObject] {
             if let sourceHost = source["user"] as? String, !sourceHost.isEmpty {
             self.showSharePopup(name: sourceHost)
             }
             else if let sourceHost = source["host"] as? String {
             var sourceData: (sourceName: String, sourceImg: UIImage, channelImage: UIImage)!
             sourceData = CommonFunctions.checkSourceType(str: sourceHost)
             self.showSharePopup(name: sourceData.sourceName)
             }
             }*/
        } else {
            let count = Int(cell.likeCountLbl.text!)
            cell.likeCountLbl.text = "\(count!-1)"
            
            sender.isSelected = false
            var data = [String:AnyObject]()
            var tempBeep = beep
            var tempMeta = meta
            if var countLikes = beep["countLikes"] as? Int {
                countLikes =  countLikes - 1
                tempBeep["countLikes"] = countLikes as AnyObject
                
                data["beep"] = tempBeep as AnyObject
                self.beepData[currentIndexPath.row] = data as AnyObject
            }
            if var isLike = meta["userLiked"] as? Bool {
                isLike = false
                tempMeta["userLiked"] = isLike as AnyObject
                
                data["meta"] = tempMeta as AnyObject
                self.beepData[currentIndexPath.row] = data as AnyObject
            }
            self.likeBeep(beepid: beepid, flag: false)
        }
        // CommonFunctions.delay(delay: 0.4) {
        self.dataTableView.reloadRows(at: [IndexPath(row: currentIndexPath.row, section: currentIndexPath.section)], with: .none)
        //}
        
        
    }
    
    func chatBtnTap(sender:UIButton) {
        
        guard CommonFunctions.checkLogin() else {
            CommonFunctions.showLoginAlert(vc: self)
            return
        }
        
        guard let currentIndexPath = sender.tableViewIndexPath(tableView: self.dataTableView) else { return }
        let row = currentIndexPath.row
        
        print_debug(object: row)
        print_debug(object: self.beepData[row])
        guard let beep = self.beepData[row]["beep"] as? [String : AnyObject] else { return }
        guard let channel = beep["channels"] as? [String] else { return }
        
        //Done By Arvind
        //==============
        if let channelID = channel.first {
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier:"OnlyCommentVC") as! OnlyCommentVC
            vc.channelId = channelID
            //       if let dele = self.tabBarDelegate {
            //           vc.delegate = dele
            //       }
            //     vc.channelViewFanVCState = ChannelViewFanVCState.None
            vc.channelId = channelID
            //      vc.isChat = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
  
        //Previous Code
        //===============
//        let channelID = channel.first!
//
//        let vc = self.storyboard?.instantiateViewController(withIdentifier:"ChannelViewFanVC") as! ChannelViewFanVC
//        vc.channelViewFanVCState = ChannelViewFanVCState.AllTagVCChatState
//        vc.allTagVCDelegate = self
//        if let dele = self.delegate {
//            vc.delegate = dele
//        }
//        vc.channelName = self.channelName
//        vc.channelId = channelID
//        //
//        self.currentRow = row
//        self.navigationController?.pushViewController(vc, animated: true)
//
//        self.unreadMsgCountLabel.isHidden = true
    
        
        //Already Commented
        //=================
        //        guard let beep = self.beepData[currentIndexPath.row]["beep"] as? [String : AnyObject] else { return }
        //        guard let id = beep["id"] as? String else { return }
        //        guard let countLikes = beep["countLikes"] as? Int else { return }
        //
        //        APP_DELEGATE.statusBarHidden = true
        //        let VC1 = self.storyboard!.instantiateViewController(withIdentifier:"BeepCommentVC") as! BeepCommentVC
        //        VC1.likes = countLikes
        //        VC1.beepId = id
        //        print_debug(object: VC1.beepId)
        //        let navController = UINavigationController(rootViewController: VC1)
        //        navController.navigationBar.isHidden = true
        //        self.present(navController, animated:true, completion: nil)
        
    }
    
    func shareBtnTap(sender:UIButton) {
        
        //        guard CommonFunctions.checkLogin() else {
        //            CommonFunctions.showLoginAlert(vc: self)
        //            return
        //        }
        
        guard let currentIndexPath = sender.tableViewIndexPath(tableView: self.dataTableView) else { return }
        let cell = self.dataTableView.cellForRow(at: currentIndexPath as IndexPath) as! UserDataCell
        if let beep = self.beepData[currentIndexPath.row]["beep"] as? [String : AnyObject] {
            
            if let id = beep["id"] as? String {
                
                let url =  SHARE_BEEP_URL + id
                self.displayShareSheet(shareContent: url, beepId: id, cell: cell, row: currentIndexPath.row)
                
            }
        }
        
    }
    
    func fanBtnTap(sender: UIButton) {
        
        guard CommonFunctions.checkLogin() else {
            CommonFunctions.showLoginAlert(vc: self)
            return
        }
        
        if let indexPath = sender.tableViewIndexPath(tableView: self.dataTableView) {
            
            let currentRow = indexPath.row
            
            if let result = self.featureChannel["results"] as? [AnyObject], result.count > 0{
                
                if let channelID = result[currentRow]["id"] as? String {
                    
                    if !sender.isSelected {
                        print_debug(object: "oN")
                        sender.isSelected = true
                        CommonFunctions.fanBtnOnFormatting(btn: sender)
                        self.followChannel(channelId: channelID, follow: true)
                        self.showSharePopup(name: result[currentRow]["name"]  as? String ?? "")
                    } else {
                        print_debug(object: "oFF")
                        sender.isSelected = false
                        CommonFunctions.fanBtnOffFormatting(btn: sender)
                        self.followChannel(channelId: channelID, follow: false)
                    }
                    
                }
            }
        }
        
    }
    
    func seeAllBtnTap(sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier:"SuggestedChannelsVC") as! SuggestedChannelsVC
        vc.allTagVCDelegate = self
        vc.suggestedChannelsVCState = SuggestedChannelsVCState.AllTagVCState
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func channelDetails(row: Int) {
        
        guard let result = self.featureChannel["results"] as? [AnyObject], result.count > 0 else { return }
        guard let channelID = result[row]["id"] as? String else { return }
        
        
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier:"ChannelViewFanVC") as! ChannelViewFanVC
        vc.channelViewFanVCState = ChannelViewFanVCState.AllTagVCChannelState
        vc.allTagVCDelegate = self
        if let nationality = result[row]["displayLabels"] as? [String], nationality.count > 0 {
            vc.displayLabel = nationality
        }
        
        if let dele = self.delegate {
            vc.delegate = dele
        } else  {
            vc.delegate = TABBARDELEGATE
        }
        vc.channelName = self.channelName
        vc.channelId = channelID
        self.navigationController?.pushViewController(vc, animated: true)
        
        
        /*if let result = self.featureChannel["results"] as? [AnyObject] {
         
         if let channelID = result[row]["avatarID"] as? String {
         
         let vc = self.storyboard?.instantiateViewController(withIdentifier:"ChannelViewFanVC") as! ChannelViewFanVC
         if let dele = self.delegate {
         vc.delegate = dele
         }
         
         vc.channelId = channelID
         self.navigationController?.pushViewController(vc, animated: true)
         
         }
         } */
    }
    
    func beepDetail(img: UIGestureRecognizer) {
        
        let currentIndexPath = img.view!.tableViewIndexPath(tableView: self.dataTableView)
        guard let row = currentIndexPath?.row else { return }
        self.showBeepDetailPage(row: row)
        
    }
    
    
    func showBeepDetailPage(row : Int) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier:"BeepDetailVC") as! BeepDetailVC
        vc.beepVCState = BeepVCState.AllTagVCState
        if let dele = self.delegate {
            vc.tabBarDelegate = dele
        }
        
        vc.delegte = self
        //vc.tagHeight = self.tagHeight(row)
        vc.hasTags = self.tags[row]
        //vc.isNotBeepDetail = false
        vc.beepData =  self.beepData[row]
        vc.from = row
        self.currentRow = row
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // nitin
    func tagHeight(row: Int) -> CGFloat{
        
        var tagWidth: CGFloat = 10 + 10
        var line  = 1
        let array = self.tags[row]
        
        _  = array.map({ (temp) in
            
            let frame = CommonFunctions.getTextHeightWdith(param: temp as? String ?? "", font : CommonFonts.SFUIText_Medium(setsize: 16.5))
            tagWidth = tagWidth + frame.width
            tagWidth = tagWidth + 10
            if tagWidth >= (SCREEN_WIDTH - 50)  {
                tagWidth = 10 + 10
                line = line + 1
            } else {
                let temp = line
                line = 0
                line = temp
                let tempW = tagWidth
                tagWidth = 0
                tagWidth = tempW
            }
        })
        let totalLineWidth = line * 24
        let totalLinseSpaceWidth = line * 8
        return CGFloat(totalLineWidth + totalLinseSpaceWidth)
    }
    
    // nitin
    func channelViewBtnTap(btn: UIButton) {
        
        let indexPath = btn.tableViewIndexPath(tableView: self.dataTableView)
        guard let row = indexPath?.row else { return }
        
        guard let beep = self.beepData[row]["beep"] as? [String : AnyObject] else { return }
        guard let meta = self.beepData[row]["meta"] as? [String : AnyObject]  else { return }
        guard let channel = beep["channels"] as? [String] else { return }
        guard let channelID = channel.first else { return }
        
        /*
         guard let tempBeepMedia = meta["beepMedia"] as? [AnyObject] else { return }
         
         var isFriend = false
         if let list = UserDefaults.getStringArrayVal(key: NSUserDefaultKeys.FRIENDSLIST) as? [String] {
         isFriend = list.contains(channelID)
         }
         
         let channelPreviewVC = self.storyboard?.instantiateViewController(withIdentifier:"ChannelFullPreviewVC") as! ChannelFullPreviewVC
         
         if isFriend {
         channelPreviewVC.msg = "Unfollow"
         } else {
         channelPreviewVC.msg = "Become a Fan"
         }
         
         channelPreviewVC.isFriend = isFriend
         channelPreviewVC.channelId = channelID
         channelPreviewVC.imgArrayObj = tempBeepMedia
         channelPreviewVC.allTagVCDelegate = self
         if let dele = self.delegate {
         channelPreviewVC.delegate = dele
         } else  {
         channelPreviewVC.delegate = TABBARDELEGATE
         }
         
         self.navigationController?.pushViewController(channelPreviewVC, animated: true)
         */
        
        /*
         let indexPath = btn.tableViewIndexPath(tableView: self.dataTableView)
         guard let row = indexPath?.row else { return }
         
         guard let beep = self.beepData[row]["beep"] as? [String : AnyObject] else { return }
         guard let channel = beep["channels"] as? [String] else { return }
         let channelID = channel.first!
         
         let vc = self.storyboard?.instantiateViewController(withIdentifier:"ChannelViewFanVC") as! ChannelViewFanVC
         vc.channelViewFanVCState = ChannelViewFanVCState.AllTagVCChannelState
         vc.allTagVCDelegate = self
         if let dele = self.delegate {
         vc.delegate = dele
         }
         vc.channelId = channelID
         self.currentRow = row
         self.navigationController?.pushViewController(vc, animated: true)*/
        
        let channelViewFanVC = self.storyboard?.instantiateViewController(withIdentifier:"ChannelViewFanVC") as! ChannelViewFanVC
        channelViewFanVC.channelId = channelID
        channelViewFanVC.channelName = self.channelName
        channelViewFanVC.channelViewFanVCState = ChannelViewFanVCState.ExploreChannelVC
        self.navigationController?.pushViewController(channelViewFanVC, animated: true)
    }
    
    
    func channelViewTap(img: UIGestureRecognizer) {
    }
    
    /*  func tapOnTag(str: String) {
     if let dele = self.delegate {
     dele.tagBtnTap(str, state: SetExploreVCDataState.Content)
     }
     } */
    
    func displayShareSheet(shareContent: String, beepId: String, cell: UserDataCell, row: Int) {
        
        let activityVC = UIActivityViewController(activityItems: [shareContent as NSString], applicationActivities: nil)
        
        activityVC.completionWithItemsHandler = { activity, success, items, error in
            
            if !success{
                print("cancelled")
                return
            } else {
                
                let count = Int(cell.shareCountLbl.text ?? "0")
                cell.shareCountLbl.text = "\(count ?? 0 + 1)"
                
                guard let beep = self.beepData[row]["beep"] as? [String : AnyObject] else { return }
                guard let meta = self.beepData[row]["meta"] as? [String : AnyObject] else { return }
                var tempBeep = beep
                if var countShares = beep["countShares"] as? Int {
                    countShares =  countShares + 1
                    tempBeep["countShares"] = countShares as AnyObject
                    var data = [String:AnyObject]()
                    data["beep"] = tempBeep as AnyObject
                    data["meta"] = meta as AnyObject
                    self.beepData[row] = data as AnyObject
                }
                self.shareBeep(beepId: beepId)
                
                self.dataTableView.reloadRows(at: [IndexPath(row: row, section: 1)], with: .none)
            }
            
            if activity == UIActivityType.copyToPasteboard {
                print("copy")
            }
            
            if activity == UIActivityType.postToTwitter {
                print("twitter")
            }
            
            if activity == UIActivityType.mail {
                print("mail")
            }
            
        }
        present(activityVC, animated: true) {
            
            print("compleatsef")
        }
        
    }
    
    
    @IBAction func mesaggingBtnTap(sender: UIButton) {
        guard CommonFunctions.checkLogin() else {
            CommonFunctions.showLoginAlert(vc: self)
            return
        }
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier:"UserChatListVC") as! UserChatListVC
        let navVC = UINavigationController(rootViewController: vc)
        navVC.navigationBar.isHidden = true
        
        self.present(navVC, animated: true, completion: nil)
        
    }
    
    
    func is3DTouchAvailable(btn: UIView) -> Bool {
        if #available(iOS 9, *) {
            if self.traitCollection.forceTouchCapability == UIForceTouchCapability.available {
                self.registerForPreviewing(with: self, sourceView: btn)
                print_debug(object: "is3DTouchAvailable")
                return true
            } else { return false }
        } else { return false}
    }
    
    func is3DTouchAvailable() -> Bool {
        if #available(iOS 9, *) {
            if self.traitCollection.forceTouchCapability == UIForceTouchCapability.available {
                self.registerForPreviewing(with: self, sourceView: self.dataTableView)
                return true
            } else { return false }
        } else { return false}
    }
    
    func flagBtnTap(sender: UIButton) {
        
        //        guard CommonFunctions.checkLogin() else {
        //            CommonFunctions.showLoginAlert(vc: self)
        //            return
        //        }
        
        guard let currentIndexPath = sender.tableViewIndexPath(tableView: self.dataTableView) else { return }
        guard let beep = self.beepData[currentIndexPath.row]["beep"] as? [String : AnyObject], let id = beep["id"] as? String else  { return}
        
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        
        let reportAction = UIAlertAction(title: "Report this content", style: .default, handler: {
            
            (alert: UIAlertAction!) -> Void in
            
            let optionMenu = UIAlertController(title: CommonTexts.FlagThisBeep, message: nil, preferredStyle: .alert)
            
            let yesAction = UIAlertAction(title: "Yes", style: .default, handler: {
                
                (alert: UIAlertAction!) -> Void in
                
                self.flagBeep(beepId: id, index: currentIndexPath.row)
                //self.reportUser(userId: uID)
            })
            
            let noAction = UIAlertAction(title: "No", style: .destructive, handler: {
                
                (alert: UIAlertAction!) -> Void in
                
            })
            optionMenu.addAction(yesAction)
            optionMenu.addAction(noAction)
            
            self.present(optionMenu, animated: true, completion: nil)
            
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            
            (alert: UIAlertAction!) -> Void in
            
            
        })
        
        
        optionMenu.addAction(reportAction)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
        
        
    }
    
    @IBAction func searchBtnTap(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier:"SearchChannelVC") as! SearchChannelVC
        vc.previoudDataIsAvalible = PrevioudDataIsAvalible.NotAvalible
        vc.searchChannelVCState = SearchChannelVCState.HomeVC
        let navVC = UINavigationController(rootViewController: vc)
        navVC.navigationBar.isHidden = true
        self.present(navVC, animated: true) {
            APP_DELEGATE.statusBarStyle = UIStatusBarStyle.default
        }
    }
    
    func showSharePopup(name: String) {
        
        let alertPopup = self.storyboard?.instantiateViewController(withIdentifier:"SharePopVC") as! SharePopVC
        alertPopup.shrarePostName = name
        alertPopup.delegate = self
        let formSheet = MZFormSheetController(size: CGSize(width: SCREEN_WIDTH - ((SCREEN_WIDTH*200)/600),height: SCREEN_HEIGHT - ((SCREEN_HEIGHT*450)/600)), viewController: alertPopup)
        formSheet.shouldCenterVertically = true
        formSheet.transitionStyle = MZFormSheetTransitionStyle.dropDown
        formSheet.shouldDismissOnBackgroundViewTap = false
        formSheet.present(animated: true, completionHandler: nil)
    }
}


//MARK:- FACEBOOK ADS DELEGATES
//=============================

extension AllTagVC:FBAdViewDelegate,FBNativeAdDelegate,FBInterstitialAdDelegate{
    
    func adViewDidLoad(_ adView: FBAdView) {
        
        print("Ad Loaded")
        
        
        
    }
    
    func adViewDidClick(_ adView: FBAdView) {
        
        print("Ad Clicked")
    }
    
    func adView(_ adView: FBAdView, didFailWithError error: Error) {
        
        print("Ad Error Failed to load")
    }
    
    
    func adViewDidFinishHandlingClick(_ adView: FBAdView) {
        
        print("Ad Finish launching")
    }
    
    func nativeAdDidLoad(_ nativeAd: FBNativeAd) {
        print("Ad NativeLoaded")
        
        
    }
    
    func nativeAd(_ nativeAd: FBNativeAd, didFailWithError error: Error) {
        
        print("Ad Nativefailure")
    }
    func nativeAdDidClick(_ nativeAd: FBNativeAd) {
        print("Ad NativeClicked")
    }
    
    func nativeAdDidFinishHandlingClick(_ nativeAd: FBNativeAd) {
        
        print("Ad NativeClicked Handling")
    }
    
    //******************
    
    func interstitialAdDidLoad(_ interstitialAd: FBInterstitialAd) {
        interstitialAd.show(fromRootViewController: self)
        print("Ads is loaded")
        
    }
    
    func interstitialAdDidClose(_ interstitialAd: FBInterstitialAd) {
        print("Ads is did close")
        
    }
    func interstitialAdDidClick(_ interstitialAd: FBInterstitialAd) {
        print("Ads is clicked")
        
    }
    func interstitialAdWillClose(_ interstitialAd: FBInterstitialAd) {
        print("Ads is will close")
    }
    func interstitialAdWillLogImpression(_ interstitialAd: FBInterstitialAd) {
        print("Ads is logwillImpression")
        
        print("interstitialAd.isAdValid")
    }
    
    func interstitialAd(_ interstitialAd: FBInterstitialAd, didFailWithError error: Error) {
        print("Ads loading Error")
    }
    
    
}





//MARK:- UITableView Delegate & DataSource
//MARK:-
extension AllTagVC : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.feedRequestComplete == false || self.channelRequestComplete == false {
            return 2
        }
        if self.beepData.count > 0 { return 2 } else { return 0 }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.feedRequestComplete == false || self.channelRequestComplete == false {
            if section == 0 {
                return 3
            }
            return  Int(tableView.frame.size.height/310) + 1
        }
        
        if section == 0 {
            if let result = self.featureChannel["results"] as? [AnyObject], result.count > 0 {  return result.count >= 3 ? 4 : result.count }
            
            return 0
        } else if section == 1 {
            if self.beepData.count > 0 {
                
                return self.beepData.count
            } else {
                return 0
            }
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if self.feedRequestComplete == false || self.channelRequestComplete == false {
            if indexPath.section == 0 {
                return 75.0
            }
            
            return  310
        }
        
        if indexPath.section == 0 {
            if indexPath.row == 3 {
                return 35.0
            } else  {
                return 75.0
            }
            
        } else if indexPath.section == 1 {
            
            if self.beepData.count > 0 {
                //self.setTagHeight(indexPath.row)
                
                
                //ADD ONS BY ARVIND FOR GIVING THE DEFINATE HEIGHT FOR ADS
                if let adData = beepData[indexPath.row]["ad"] as? Int{
                    if adData == 1 {
                        return 300
                    }
                }
                
                let frame  = CommonFunctions.getTextHeightWdith(param: self.descriptionText[indexPath.row ], font : CommonFonts.SFUIText_Medium(setsize: 14.5))
                
                
                //Temporary changes on Description Text
                
                // *************************************
                let descriptionHeight   = frame.height
                //return 325 + 12 + descriptionHeight //+ self.finalHeight[indexPath.row]
                let height = 145 + self.beepDimention[indexPath.row] + 12 + descriptionHeight
                
                
                var counters = (like: 0, share: 0, views: 0)
                if let beep = self.beepData[indexPath.row]["beep"] as? [String : AnyObject] {
                    if let countLikes = beep["countLikes"] as? Int {
                        counters.like = countLikes
                    }
                    if let countShares = beep["countShares"] as? Int {
                        counters.share = countShares
                    }
                    
                    if let countViews = beep["countViews"] as? Int {
                        counters.views = countViews
                    }
                }
                if counters.like == 0 && counters.share == 0 && counters.views == 0 {
                    return height
                } else {
                    return height + 12
                }
                
            } else {
                return 0
            }
        } else {
            
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if self.feedRequestComplete == false || self.channelRequestComplete == false {
            if indexPath.section == 0 {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "FanCellXIB", for:  indexPath) as! FanCellXIB
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                cell.isUserInteractionEnabled = true
                cell.grayDot.isHidden = true
                cell.secondCounterLbl.isHidden = true
                cell.redDot.isHidden = true
                cell.showAnimatedGradientSkeleton()
                cell.btn.isHidden = true
                return cell
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "UserDataPlaceholderCell", for:  indexPath) as! UserDataPlaceholderCell
            cell.contentView.showAnimatedGradientSkeleton()
            
            return cell
        }
        self.dataTableView.isScrollEnabled = true
        switch indexPath.section {
        case 0:
            let result = self.featureChannel["results"] as? [AnyObject] ?? [AnyObject]()
            if  result.count >= 3 && indexPath.row == 3
            {
                
                return self.seeAllCellSetUp(tableView: tableView, indexPath: indexPath as IndexPath)
            } else  {
                return self.fanCellSetUp(tableView: tableView, indexPath: indexPath)
            }
            
        case 1:
            
            
            if self.beepData.count > 0 {
                
            
                if let adData = beepData[indexPath.row]["ad"] as? Int{
                    if adData == 1 {
                        
                        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NativeAdTableViewCell", for: indexPath) as? NativeAdTableViewCell else{
                            
                            fatalError("Cell1 not Found")
                            
                        }
                        
                        
                        
                        nativeAd.registerView(forInteraction: cell, with: self)
                        
                        cell.text1.text     = nativeAd.title
                        cell.text2.text      = nativeAd.subtitle
                        cell.body.text  = nativeAd.body
                        cell.adChoices.text  = nativeAd.adChoicesText
                        
                        
                        nativeAd.coverImage?.loadAsync(block: { (image) in
                            
                            cell.bannerView.image = image
                            
                        })
                        nativeAd.icon?.loadAsync(block: { (image) in
                            cell.logoView.image = image
                            
                        })
                        
                        return cell
                    }
                }
                return self.userDataCellSetUp(tableView: tableView, indexPath: indexPath)
            } else {
                
                
                return UITableViewCell()
            }
            
        default:
            fatalError("cellForRowAtIndexPath")
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if self.beepData.count-1 == indexPath.row {
            self.from = self.from+10
            var url = ""
            var param: [String: AnyObject] = [String: AnyObject]()
            
            if self.userId.isEmpty {
                
                param["channels"]           = self.featureChannelsId as AnyObject
                param["hashtags"]           = self.vcTag as AnyObject
                param["from"]               = self.from as AnyObject
                param["size"]               = self.size as AnyObject
                
                url = WS_beeps + "feed"
                
            } else {
                
                param["uid"]                = self.userId as AnyObject
                param["followingChannels"]  = "" as AnyObject
                param["hashtags"]           = self.vcTag as AnyObject
                param["from"]               = self.from as AnyObject
                param["size"]               = self.size as AnyObject
                
                url = WS_beeps + "user"
            }
            
            if self.nextCount != 0 {
                
                self.spinner.startAnimating()
                self.getDashBoardData(url: url, param: param)
            } else {
                
                self.spinner.stopAnimating()
            }
            
            
        }
        
        cell.clipsToBounds = true
        cell.contentView.layoutIfNeeded()
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.feedRequestComplete == false || self.channelRequestComplete == false {
            return
        }
        if indexPath.section == 0 {
            if indexPath.row < 3 {
                self.channelDetails(row: indexPath.row)
            } else  {
                print_debug(object: "could not perform any action.")
            }
        } else  {
            print_debug(object: "could not perform any action.")
        }
    }
    
    func seeAllCellSetUp(tableView: UITableView, indexPath: IndexPath) -> SeeAllCell  {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SeeAllCell", for:  indexPath) as! SeeAllCell
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.isUserInteractionEnabled = true
        cell.seeAllBtn.addTarget(self, action: #selector(AllTagVC.seeAllBtnTap(sender:)), for: UIControlEvents.touchUpInside)
        
        //cell.seeAllBtn.imageEdgeInsets = UIEdgeInsetsMake(0, cell.seeAllBtn.frame.size.width - (cell.seeAllBtn.frame.size.width + 15), 0, 0)
        //cell.seeAllBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, cell.seeAllBtn.frame.size.width)
        
        
        //        let somespace: CGFloat = 0
        //        cell.seeAllBtn.imageEdgeInsets = UIEdgeInsetsMake(0, cell.seeAllBtn.frame.size.width - (somespace) , 0, 0)
        //        cell.seeAllBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 0 + somespace, 0, 30 )
        
        //cell.seeAllBtn.addTarget(self, action: "seeAllBtnTap:", for: .touchUpInside)
        return cell
    }
    
    func fanCellSetUp(tableView: UITableView, indexPath: IndexPath) -> FanCellXIB  {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FanCellXIB", for:  indexPath) as! FanCellXIB
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.isUserInteractionEnabled = true
        cell.grayDot.isHidden = true
        cell.secondCounterLbl.isHidden = true
        cell.redDot.isHidden = true
        
        cell.nameLbl.stopSkeletonAnimation()
        cell.counterLbl.stopSkeletonAnimation()
        cell.imgContainerView.stopSkeletonAnimation()
        cell.contentView.hideSkeleton()
        cell.btn.isHidden = false
        
        _ = is3DTouchAvailable(btn: cell.contentView)
        if indexPath.row == 3 {
            cell.bottomView.isHidden = true
        } else {
            cell.bottomView.isHidden = false
        }
        cell.btn.addTarget(self, action: #selector(AllTagVC.fanBtnTap(sender:)), for: .touchUpInside)
        
        CommonFunctions.fanBtnOffFormatting(btn: cell.btn)
        cell.btn.isSelected = false
        if let result = self.featureChannel["results"] as? [AnyObject], result.count > 0 {
            print_debug(object: result)
            cell.nameLbl.text = result[indexPath.row]["name"]  as? String ?? ""
            
            if let nationality = result[indexPath.row]["displayLabels"] as? [String], nationality.count > 0 {
                cell.descriptionLabel.text = nationality.joined(separator: ",") as? String ?? ""
            }
            
            if let imgUrl = result[indexPath.row]["avatarURLLarge"] as? String {
                
                cell.imgView.sd_setImage(with: URL(string: imgUrl), placeholderImage: CHANNELLOGOPLACEHOLDER)
                
            } else {
                
                cell.imgView.image = CHANNELLOGOPLACEHOLDER
            }
            
            if let currentCellFanId  = result[indexPath.row]["id"]  as? String {
                if let list = UserDefaults.getStringArrayVal(key: NSUserDefaultKeys.FRIENDSLIST) as? [String] {
                    for temp in list{
                        if temp == currentCellFanId {
                            CommonFunctions.fanBtnOnFormatting(btn: cell.btn)
                            cell.btn.isSelected = true
                            break
                        } else {
                            CommonFunctions.fanBtnOffFormatting(btn: cell.btn)
                            cell.btn.isSelected = false
                        }
                    }
                    
                } else {
                    CommonFunctions.fanBtnOffFormatting(btn: cell.btn)
                    cell.btn.isSelected = false
                }
                
            } else {
                CommonFunctions.fanBtnOffFormatting(btn: cell.btn)
                cell.btn.isSelected = false
                
            }
            if let status = result[indexPath.row]["isUserFan"] as? Bool, status == true {
                CommonFunctions.fanBtnOnFormatting(btn: cell.btn)
                cell.btn.isSelected = true
            }
        } else {
            CommonFunctions.fanBtnOffFormatting(btn: cell.btn)
            cell.btn.isSelected = false
            
        }
        
        cell.counterLbl.text = "Featured"
        cell.featureImageView.image = UIImage(named: "featured")
        return cell
    }
    
    func userDataCellSetUp(tableView: UITableView, indexPath: IndexPath) -> UserDataCell  {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserDataCell", for:  indexPath) as! UserDataCell
        cell.contentView.hideSkeleton()
        cell.isUserInteractionEnabled = true
        cell.selectionStyle = .none
        cell.pageController.isHidden = true
        cell.tagContainerViewHeightConstraint.constant = 0 //self.finalHeight[indexPath.row]
        
        //self.setTableViewData(cell, indexPath: indexPath)
        cell.likeBtn.addTarget(self, action: #selector(AllTagVC.likeBtnTap(sender:)), for: UIControlEvents.touchUpInside)
        cell.chatBtn.addTarget(self, action: #selector(AllTagVC.chatBtnTap(sender:)), for: UIControlEvents.touchUpInside)
        cell.flagButton.addTarget(self, action: #selector(AllTagVC.flagBtnTap(sender:)), for: UIControlEvents.touchUpInside)
        
        
        cell.shareBtn.addTarget(self, action: #selector(AllTagVC.shareBtnTap(sender:)), for: UIControlEvents.touchUpInside)
        
        let imageViewTap = UITapGestureRecognizer(target:self, action:#selector(AllTagVC.beepDetail(img:)))
        cell.tapView.isUserInteractionEnabled = true
        cell.tapView.addGestureRecognizer(imageViewTap)
        
        let descriptionViewTap = UITapGestureRecognizer(target:self, action:#selector(AllTagVC.beepDetail(img:)))
        cell.descriptionLbl.isUserInteractionEnabled = true
        cell.descriptionLbl.addGestureRecognizer(descriptionViewTap)
        
        //channelDetails
        let channelViewTap = UITapGestureRecognizer(target:self, action:#selector(AllTagVC.channelViewTap(img:)))
        cell.providerDescContainerView.isUserInteractionEnabled = true
        cell.providerDescContainerView.addGestureRecognizer(channelViewTap)
        cell.channelDescBtn.isHidden = false
        _ = self.is3DTouchAvailable(btn: cell.channelDescBtn)
        cell.channelDescBtn.addTarget(self, action: #selector(self.channelViewBtnTap(btn:)), for: .touchUpInside)
        
        cell.imgCollectionViewHeightCons.constant =  self.beepDimention.count > indexPath.row ? self.beepDimention[indexPath.row] : 180
        cell.imgCollectionView.isHidden   = true
        cell.pageController.isHidden      = true
        self.setTableViewData(cell: cell, indexPath: indexPath)
        cell.contentView.layoutIfNeeded()
        return cell
    }
    
    func setTableViewData(cell: UserDataCell, indexPath: IndexPath) {
        
        var sourceData: (sourceName: String, sourceImg: UIImage, channelImage: UIImage)!
        
        guard indexPath.row <= self.beepData.count - 1 else{return}
        if let meta = self.beepData[indexPath.row]["meta"] as? [String : AnyObject] {
            if let userLiked = meta["userLiked"] as? Bool {
                cell.likeBtn.isSelected = userLiked
            }
            
            if let tempBeepMedia = meta["beepMedia"] as? [AnyObject] {
                
                if  tempBeepMedia.count == 0 {
                    cell.mainImageView.image = CONTAINERPLACEHOLDER
                } else {
                    if let beepMedia = tempBeepMedia.first {
                        
                        if let urls = beepMedia["imgURLs"] as? [String : AnyObject] {
                            if let url = urls["img1x"] as? String {
                                cell.imageArrayURl = [NSURL(string: url)! as URL]
                                cell.metaData = meta
                                weak var weakCell = cell
                                weakCell?.mainImageView.sd_setIndicatorStyle(.gray)
                                weakCell?.mainImageView.sd_setShowActivityIndicatorView(true)
                                //cell.mainImageView.sd_setImage(with: URL(string: url), placeholderImage: nil)
                                
                                weakCell?.mainImageView.sd_setImage(with: URL(string: url), completed: {  (image, err, tempcatch, url) in
                                    if image == nil {
                                        weakCell?.mainImageView.image = CONTAINERPLACEHOLDER
                                        
                                    } else {
                                        weakCell?.mainImageView.image = image
                                        weakCell?.mainImageView.contentMode = .scaleAspectFill
                                    }
                                })
                            } else {
                                cell.mainImageView.image = CONTAINERPLACEHOLDER
                            }
                        } else {
                            cell.mainImageView.image = CONTAINERPLACEHOLDER
                        }
                        cell.moreCount = 1
                    }
                }
                
            }
            
            if let summary = meta["summary"] as? String {
                cell.descriptionLbl.text = summary
            }
        }
        
        if let beep = self.beepData[indexPath.row]["beep"] as? [String : AnyObject] {
            
            if let source = beep["source"] as? [String : AnyObject] {
                
                if let sourceHost = source["host"] as? String {
                    
                    sourceData = CommonFunctions.checkSourceType(str: sourceHost)
                }
                
                if let sourceUser = source["user"] as? String {
                    if sourceUser.isEmpty {
                        
                        cell.logoImgeView.image = sourceData.channelImage
                        cell.newsTypeLogoImageView.image = sourceData.sourceImg
                        if let hostName = source["host"] as? String, !hostName.isEmpty  {
                            cell.providerNameLbl.text = sourceData.sourceName
                        } else {
                            cell.providerNameLbl.text = sourceData.sourceName
                        }
                    } else {
                        cell.providerNameLbl.text = sourceUser
                        cell.newsTypeLogoImageView.image = sourceData.sourceImg
                        if let sourceAvatar = source["avatar"] as? String {
                            cell.logoImgeView.sd_setImage(with: URL(string: sourceAvatar), placeholderImage: CHANNELLOGOPLACEHOLDER)
                        }
                    }
                }
            }
            
            /*
             if let text = beep["text"] as? String {
             cell.descriptionLbl.text = text
             }
             
             if let text = beep["title"] as? String {
             cell.descriptionLbl.text = text
             } */
            
            
            var counters = (like: 0, share: 0, views: 0)
            if let countLikes = beep["countLikes"] as? Int {
                counters.like = countLikes
            }
            
            if let countShares = beep["countShares"] as? Int {
                counters.share = countShares
            }
            
            if let countViews = beep["countViews"] as? Int {
                counters.views = countViews
            }
            
            if counters.like == 0 && counters.share == 0 && counters.views == 0 {
                cell.likeContainerHeightCons.constant   = 0
                cell.shareTextLbl.text = ""
                cell.likeTextLbl.text = ""
                cell.showlikeContainerView.isHidden = true
                cell.viewsDotView.isHidden = true
                cell.viewsCountLabel.text = ""
            } else {
                
                cell.likeContainerHeightCons.constant = 16
                cell.seondDotView.isHidden = true
                cell.showlikeContainerView.isHidden = false
                cell.viewsDotView.isHidden = true
                
                
                if counters.like == 0 && counters.share == 0 && counters.views != 0{
                    
                    cell.likeTextLbl.text = counters.views > 1 ? "Views" : "View"
                    cell.likeCountLbl.text = "\( counters.views )"
                    
                    cell.shareTextLbl.text = ""
                    cell.shareCountLbl.text = ""
                    
                }
                    
                else if counters.like == 0 && counters.share != 0 && counters.views == 0{
                    
                    cell.likeTextLbl.text = counters.share > 1 ? "Shares" : "Share"
                    cell.likeCountLbl.text = "\( counters.share )"
                    
                    cell.shareTextLbl.text = ""
                    cell.shareCountLbl.text = ""
                    
                } else if counters.like != 0 && counters.share == 0 && counters.views == 0{
                    
                    cell.likeTextLbl.text = counters.like > 1 ? "Likes" : "Like"
                    cell.likeCountLbl.text = "\( counters.like )"
                    
                    cell.shareTextLbl.text = ""
                    cell.shareCountLbl.text = ""
                    
                }else if counters.like != 0 && counters.share != 0 && counters.views == 0{
                    cell.seondDotView.isHidden = false
                    cell.likeTextLbl.text = counters.like > 1 ? "Likes" : "Like"
                    cell.likeCountLbl.text = "\( counters.like )"
                    
                    cell.shareTextLbl.text = counters.share > 1 ? "Shares" : "Share"
                    cell.shareCountLbl.text = "\( counters.share )"
                    
                }else if counters.like != 0 && counters.share == 0 && counters.views != 0{
                    cell.seondDotView.isHidden = false
                    cell.likeTextLbl.text = counters.like > 1 ? "Likes" : "Like"
                    cell.likeCountLbl.text = "\( counters.like )"
                    
                    cell.shareTextLbl.text = counters.views > 1 ? "Views" : "View"
                    cell.shareCountLbl.text = "\( counters.views )"
                    
                }else if counters.like == 0 && counters.share != 0 && counters.views != 0{
                    cell.seondDotView.isHidden = false
                    cell.likeTextLbl.text = counters.share > 1 ? "Shares" : "Share"
                    cell.likeCountLbl.text = "\( counters.share )"
                    
                    cell.shareTextLbl.text = counters.views > 1 ? "Views" : "View"
                    cell.shareCountLbl.text = "\( counters.views )"
                    
                }else {
                    
                    cell.viewsDotView.isHidden = false
                    cell.viewsCountLabel.isHidden = false
                    cell.seondDotView.isHidden = false
                    
                    cell.likeTextLbl.text = counters.like > 1 ? "Likes" : "Like"
                    cell.likeCountLbl.text = "\( counters.like )"
                    
                    cell.shareTextLbl.text = counters.share > 1 ? "Shares" : "Share"
                    cell.shareCountLbl.text = "\( counters.share )"
                    
                    cell.viewsCountLabel.text = "\( counters.views ) \(counters.views > 1 ? "Views" : "View")"
                    cell.viewsDotView.isHidden = false
                    
                    
                }
                
            }
            
            
            if let postTime = beep["postTime"] as? String   {
                
                
                dateFormat.timeZone = TimeZone(identifier: "UTC")
                dateFormat.dateFormat =  "yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"
                
                if let preConvertedDate = dateFormat.date(from: postTime) {
                    dateFormat.dateFormat = "dd/MM/yyyy hh:mm a"
                    dateFormat.timeZone = TimeZone.current
                    dateFormat.locale = NSLocale.current
                    
                    let convertedDateString = dateFormat.string(from: preConvertedDate)
                    let convertedDate = dateFormat.date(from: convertedDateString)
                    let days = CommonFunctions.calculateDateTime(dateToCompare: convertedDate! as NSDate)
                    cell.timeLbl.text = days + " ago"
                }
            }
            
        }
        
    }
    
    func messageBtnHideShow(isShow: Bool) {
        
        if self.mesaggingBtnBottomCons.constant != 20 {
            UIView.animate(withDuration: 0.5, animations: {
                self.mesaggingBtnBottomCons.constant = -80
                self.mesaggingBtn.layoutIfNeeded()
            })
        } else {
            UIView.animate(withDuration: 0.5, animations: {
                self.mesaggingBtnBottomCons.constant = 20
                self.mesaggingBtn.layoutIfNeeded()
            })
        }
        
    }
    
    
    
    //indexPath: IndexPath
    /*  func setTagHeight(row: Int) {
     
     var tagWidth: CGFloat = 10 + 10
     var line  = 1
     var finalHeight: CGFloat = 0
     
     /*
     self.minimumInteritemSpacing = 5.0f;
     self.minimumLineSpacing = 10.0f;
     self.sectionInset = UIEdgeInsetsMake(10.0f, 10.0f, 0.0f, 10.0f);
     top, left, bottom, right
     */
     let array = self.tags[row]
     _  = array.map({ (temp: AnyObject) in
     
     let frame = CommonFunctions.getTextHeightWdith(temp as! String)
     tagWidth = tagWidth + frame.width
     tagWidth = tagWidth + 10
     if tagWidth >= SCREEN_WIDTH {
     tagWidth = 10 + 10
     line = line + 1
     } else {
     let temp = line
     line = 0
     line = temp
     let tempW = tagWidth
     tagWidth = 0
     tagWidth = tempW
     }
     })
     
     
     let totalLineWidth = line * 20
     let totalLinseSpaceWidth = line * 10
     finalHeight = CGFloat(totalLineWidth + totalLinseSpaceWidth)
     self.finalHeight.append(finalHeight)
     } */
}

//MARK:- WebService method's
//MARK:-
extension AllTagVC {
    
    func getDashBoardData(url: String, param: [ String : AnyObject]) {
        
        WebServiceController.getDashboradFeed(url: url, parameters: param) { (sucess, errorMessage, data) in
            
            if sucess {
                
                if let from = param["from"] as? Int, from == 0 {
                    self.descriptionText.removeAll(keepingCapacity: false)
                    self.beepDimention.removeAll(keepingCapacity: false)
                    self.tags.removeAll(keepingCapacity: false)
                    self.beepData.removeAll(keepingCapacity: false)
                }
                
                
                if let beepData = data  {
                    
                    
                    //self.nextCount = beepData.count
                    if beepData.count < 10 || beepData.count == 0 {
                        self.nextCount = 0
                        self.spinner.stopAnimating()
                    }
                    self.spinner.stopAnimating()
                    for beepss in beepData {
                        
                        if let beep = beepss["beep"] as? [String : AnyObject] {
                            
                            if let hashtags = beep["hashtags"] as? [String] {
                                print_debug(object: "__________________________")
                                print_debug(object: hashtags)
                                var arr = [String]()
                                _ = hashtags.map({ (temp: String) in
                                    //let attStr = NSAttributedString(string: temp, attributes: [NSAttributedF])
                                    if !temp.hasPrefix("_") {
                                        arr.append("#\(temp)")
                                    }
                                    
                                })
                                
                                
                                self.tags.append(arr)
                            }
                            
                        }
                        
                        if let meta = beepss["meta"] as? [String : AnyObject] {
                            
                            
                            if let summary = meta["summary"] as? String {
                                // AllTagData(data: summary)
                                self.descriptionText.append(summary)
                            }
                            
                            if let tempBeepMedia = meta["beepMedia"] as? [AnyObject] {
                                
                                if tempBeepMedia.count == 0 {
                                    self.beepDimention.append(180)
                                } else {
                                    if let beepMedia = tempBeepMedia.first {
                                        guard let urls = beepMedia["imgURLs"] as? [String : AnyObject] else { return }
                                        print_debug(object: urls)
                                        if  let img2xH = urls["img2xH"] as? Int {
                                            if let img2xW = urls["img2xW"] as? Int {
                                                let ratio = (CGFloat(img2xH)/CGFloat(img2xW)) * SCREEN_WIDTH
                                                if ratio <= 10 {
                                                    self.beepDimention.append(180)
                                                } else {
                                                    
                                                    if ratio.isNaN {
                                                        self.beepDimention.append(180)
                                                    } else {
                                                        self.beepDimention.append(ratio)
                                                    }                                                }
                                            } else {
                                                self.beepDimention.append(180)
                                            }
                                        } else {
                                            self.beepDimention.append(180)
                                        }
                                        
                                        print_debug(object: self.beepDimention)
                                    }
                                }
                                
                            }
                        }
                    }
                    
                    if let beeps = data {
                        self.beepData.append(contentsOf: beeps)
                    }

                    
                    if self.beepData.isEmpty {
                        
                        self.beepData.removeAll(keepingCapacity: false)
                        self.refreshControl.endRefreshing()
                        
                        self.dataTableView.reloadData()
                        
                        CommonFunctions.hideLoader()
                        
                        self.noDataLbl.isHidden = false
                        self.searchButton.isHidden = false
                        self.searchLabel.isHidden = false
                        self.dataTableView.isHidden = true
                        
                    } else  {
                        
                        if let beeps = data {
                            self.beepCounter    = self.beepCounter + (beeps.count)/2
                            // self.AdDataCounter  = beeps.count
                            
                            let adData: AnyObject =  ["ad" : true] as AnyObject;
//                            self.beepData.append(contentsOf: beeps)
                            
                            self.beepData.insert(adData, at: self.beepCounter)
                            
                            // Done Extra changes by Arvind because indexPath is increasease after adding Ad key so we have to increase another array index who are using indexpath.row
                            self.beepDimention.insert(0, at: self.beepCounter)
                            
                            //Done By Arvind for increase the array Element
                            self.descriptionText.insert("", at: self.beepCounter)
                            
                        }

                        self.noDataLbl.isHidden = true
                        self.searchButton.isHidden = true
                        self.searchLabel.isHidden = true
                        self.refreshControl.endRefreshing()
                        self.dataTableView.reloadData()
                    }
                    
                } else {
                    
                    self.refreshControl.endRefreshing()
                    //self.noDataLbl.isHidden = false
                    //self.dataTableView.isHidden = true
                }
                
            } else {
                
                print_debug(object: errorMessage)
                self.refreshControl.endRefreshing()
                //self.noDataLbl.isHidden = false
                //self.dataTableView.isHidden = true
            }
            CommonFunctions.delay(delay: 0.8, closure: {
                CommonFunctions.hideLoader()
            })
            self.feedRequestComplete = true
            self.dataTableView.reloadData()
        }
    }
    
    func getFeatureChannelList() {
        
        //CommonFunctions.showLoader()
        let params = ["from" : 0, "size" : 3 ]
        WebServiceController.getFeatureChannelList(parameters: params as [String : AnyObject]) { (success, errorMessage, data) in
            
            if success {
                self.featureChannel.removeAll(keepingCapacity: false)
                if let channels = data {
                    
                    if !channels.isEmpty {
                        
                        self.featureChannel = channels
                        self.dataTableView.reloadData()
                        //self.dataTableView.reloadSections(NSIndexSet(index: 0), with: .None)
                        /*self.dataTableView.reloadData()
                         let indexPath = IndexPath(row: 0, inSection: 0)
                         
                         self.dataTableView.beginUpdates()
                         self.dataTableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.Automatic)
                         self.dataTableView.endUpdates()*/
                        
                    } else {
                        self.noDataLbl.isHidden = false
                        self.searchButton.isHidden = false
                        self.searchLabel.isHidden = false
                        self.dataTableView.isHidden = true
                        CommonFunctions.hideLoader()
                    }
                    
                } else {
                    print_debug(object: errorMessage)
                    self.noDataLbl.isHidden = false
                    self.searchButton.isHidden = false
                    self.searchLabel.isHidden = false
                    self.dataTableView.isHidden = true
                    CommonFunctions.hideLoader()
                }
                
            } else {
                print_debug(object: errorMessage)
                self.noDataLbl.isHidden = false
                self.searchButton.isHidden = false
                self.dataTableView.isHidden = true
                CommonFunctions.hideLoader()
            }
            //CommonFunctions.hideLoader()
            self.channelRequestComplete = true
            self.dataTableView.reloadData()
        }
        
    }
    
    func getFeatureChannelId() {
        
        //CommonFunctions.showLoader()
        let params = ["from" : 0, "size" : 50 ]
        WebServiceController.getFeatureChannelList(parameters: params as [String : AnyObject]) { (success, errorMessage, data) in
            
            if success {
                self.featureChannelsId.removeAll(keepingCapacity: false)
                if let channels = data {
                    print_debug(object: channels)
                    if let result = channels["results"] as? [AnyObject] {
                        
                        var ids = ""
                        for data in result {
                            
                            if let id = data["id"] as? String {
                                
                                ids += id + ","
                                
                            }
                            
                        }
                        self.featureChannelsId = ids
                        
                        var param: [String : AnyObject]    = ["channels" : self.featureChannelsId as AnyObject]
                        param["hashtags"]                  = self.vcTag  as AnyObject
                        param["from"]                      = 0 as AnyObject
                        param["size"]                      = self.size as AnyObject
                        
                        let url = WS_beeps + "feed"
                        self.getDashBoardData(url: url, param: param)
                        print_debug(object: ids)
                        
                    }
                } else {
                    print_debug(object: errorMessage)
                }
                
            } else {
                print_debug(object: errorMessage)
            }
        }
        
    }
    
    func followChannel(channelId: String, follow: Bool) {
        
        let params: [String: AnyObject] = ["channelID" : channelId as AnyObject, "virtualChannel" : false as AnyObject, "follow": follow as AnyObject]
        
        WebServiceController.follwUnfollowChannel(parameters: params) { (sucess, errorMessage, data) in
            
            if sucess {
                print_debug(object: "You click on follow btn.")
                if let dele = self.delegate {
                    dele.sideMenuUpdate()
                }
                CommonFunctions.delay(delay: 0.8, closure: {
                    if follow {
                        
                        //Save NSUserDefault
                        if let list = UserDefaults.getStringArrayVal(key: NSUserDefaultKeys.FRIENDSLIST) as? [String] {
                            var tempList = list
                            print_debug(object: "Old Data : \(tempList)")
                            if !channelId.isEmpty {
                                tempList.append(channelId)
                                UserDefaults.setStringVal(value: tempList as AnyObject, forKey: NSUserDefaultKeys.FRIENDSLIST)
                            }
                        } else {
                            let id: [String] = [channelId]
                            UserDefaults.setStringVal(value: id as AnyObject, forKey: NSUserDefaultKeys.FRIENDSLIST)
                            print_debug(object: " After \(String(describing: UserDefaults.getStringArrayVal(key: NSUserDefaultKeys.FRIENDSLIST) as? [String]))")
                        }
                    } else {
                        //Remove NSUserDefault
                        if let list = UserDefaults.getStringArrayVal(key: NSUserDefaultKeys.FRIENDSLIST) as? [String], list.count > 0 {
                            var tempList = list
                            var index = 0
                            for tempChannelId in tempList {
                                if tempChannelId == channelId {
                                    break
                                }
                                index = index + 1
                            }
                            print_debug(object: "Index no : \(index)")
                            print_debug(object: "Before remove : \(tempList)")
                            tempList.remove(at: index)
                            print_debug(object: "After remove : \(tempList)")
                            UserDefaults.setStringVal(value: tempList as AnyObject, forKey: NSUserDefaultKeys.FRIENDSLIST)
                        }
                    }
                    self.getBeepData()
                })
                
            } else {
                print_debug(object: errorMessage)
            }
            
        }
    }
    
    func likeBeep(beepid: String, flag: Bool) {
        
        var url = WS_LikeBeep + "/" + beepid + "?"
        url.append("index=bb-beeps-feed")
        url.append("&like=\(flag)")
        
        //let param: [String: AnyObject] = ["index" : "bb-beeps-feed", "like" : flag]
        
        WebServiceController.beep_Share_Like(url: url, parameters: [String: AnyObject]()) { (sucess, DataHeaderResponse, DataResultResponse) in
            
            if sucess {
                print_debug(object: "Beep like sucessfully.")
            } else {
                print_debug(object: "Beep not like.")
            }
        }
        
    }
    
    func shareBeep(beepId: String) {
        
        var url = WS_ShareBeep + "/" + beepId + "?"
        url.append("index=bb-beeps-feed")
        url.append("&flag=true")
        
        //let param: [String : AnyObject] = ["index" : "bb-beeps-feed", "flag" : true]
        print_debug(object: url)
        
        WebServiceController.beep_Share_Like(url: url, parameters: [String : AnyObject]()) { (sucess, DataHeaderResponse, DataResultResponse) in
            
            if sucess {
                print_debug(object: "Beep Share sucessfully.")
            } else {
                print_debug(object: "Beep not Share.")
            }
        }
    }
    
    func getUnreadMsgCount() {
        let backgroundQueue = DispatchQueue(label: "queuename", attributes: .concurrent)
        backgroundQueue.async(execute: {
            WebServiceController.getUnreadMessageCount { (sucess, message, DataResultResponse) in
                
                print_debug(object: DataResultResponse)
                if sucess {
                    DispatchQueue.main.async {
                        if let count = DataResultResponse?["unreadCount"] as? Int, count > 0 {
                            print_debug(object: count)
                            
                            self.unreadMsgCountLabel.text = "\(count > 99 ? "99+" : "\(count)")"
                            self.unreadMsgCountLabel.isHidden = false
                        } else {
                            self.unreadMsgCountLabel.isHidden = true
                        }
                    }
                }
                
                
            }
        }) 
    }
    
    func flagBeep(beepId : String, index : Int) {
        
        CommonFunctions.showLoader()
        let url = WS_ReportBeep + "\(beepId)?index=\(index)&flag=true"
        
        WebServiceController.ReportBeep(url: url, parameters: [String:AnyObject]()) { (sucess, msg, DataResultResponse) in
            CommonFunctions.hideLoader()
            if sucess {
                CommonFunctions.showAlertSucess(title: CommonTexts.Success, msg: CommonTexts.Reported_SuccessFully) // nitin
                
            } else {
                //CommonFunctions.showAlertWarning(msg: "Detail is not update.")
            }
            
        }
        
    }
    
}

//MARK:- AllTagVCdelegate
//MARK:-
extension AllTagVC: AllTagVCDelegate {
    
    
    func fromBeepDetailDataReload(beepId: String, updateData: [String: AnyObject]) {
        
        guard let tempBeepData = self.beepData as? [AnyObject] else { return }
        var row = 0
        for temp in tempBeepData  {
            guard let tempBeep = temp["beep"] as? [String : AnyObject] else { return }
            let id = tempBeep["id"] as? String
            if id == beepId {
                break
            }
            row = row + 1
        }
    }
    
    
    func fromChannelDetailDataReload(updateData: [AnyObject]) {
        
        var newDatas = updateData
        
        print_debug(object: newDatas)
        
        var index = 0
        for oldBeeps in self.beepData {
            
            guard let oldBeep = oldBeeps["beep"] as? [String: AnyObject] else { return }
            guard let oldBeepId = oldBeep["id"] as? String else { return }
            print_debug(object: oldBeepId)
            var internalIndex = 0
            for newData in newDatas {
                guard let newBeep = newData["beep"] as? [String: AnyObject] else { return }
                guard let newBeepId = newBeep["id"] as? String else { return }
                
                if oldBeepId == newBeepId {
                    self.beepData[index] = newData
                    self.dataTableView.reloadRows(at: [IndexPath(row: index, section: 1)], with: .none)
                    newDatas.remove(at: internalIndex)
                    internalIndex = internalIndex + 1
                    index = 0
                }
            }
            index = index + 1
        }
    }
    
    
    func beepDataReload() {
        
        print_debug(object: "Delegate run")
        
        self.setInitData()
    }
    
}



//MARK:- UIViewControllerPreviewingDelegate methods
//MARK:-
extension  AllTagVC: UIViewControllerPreviewingDelegate {
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        guard CommonFunctions.checkLogin() else {
            //CommonFunctions.showLoginAlert(vc: self)
            return nil
        }
        
        guard #available(iOS 9.0, *) else { return nil }
        
        guard let indexPath = previewingContext.sourceView.tableViewIndexPath(tableView: self.dataTableView) else { return nil }
        
        if indexPath.section == 1 {
            
            guard let beep = self.beepData[indexPath.row]["beep"] as? [String : AnyObject] else { return nil }
            guard let meta = self.beepData[indexPath.row]["meta"] as? [String : AnyObject]  else { return nil }
            guard let channel = beep["channels"] as? [String] else { return nil }
            guard let channelID = channel.first else { return nil }
            guard let tempBeepMedia = meta["beepMedia"] as? [AnyObject] else { return nil }
            
            var isFriend = false
            if let list = UserDefaults.getStringArrayVal(key:  NSUserDefaultKeys.FRIENDSLIST) as? [String] {
                isFriend = list.contains(channelID)
            }
            
            let channelPreviewVC = self.storyboard?.instantiateViewController(withIdentifier:"ChannelFullPreviewVC") as! ChannelFullPreviewVC
            
            if isFriend {
                channelPreviewVC.msg = "Unfollow"
            } else {
                channelPreviewVC.msg = "Become a Fan"
            }
            
            channelPreviewVC.isFriend = isFriend
            channelPreviewVC.channelId = channelID
            channelPreviewVC.imgArrayObj = tempBeepMedia
            channelPreviewVC.allTagVCDelegate = self
            if let dele = self.delegate {
                channelPreviewVC.delegate = dele
            } else  {
                channelPreviewVC.delegate = TABBARDELEGATE
            }
            channelPreviewVC.previousNav = self.navigationController
            channelPreviewVC.preferredContentSize = CGSize(width: SCREEN_WIDTH, height: 500)
            
            //previewingContext.sourceRect = cell.frame
            
            return channelPreviewVC
        } else {
            
            guard let featureChannels = self.featureChannel["results"] as? [AnyObject], featureChannels.count > 0 else {
                return nil
            }
            
            guard let channelID = featureChannels[indexPath.row]["id"] as? String else { return nil }
            
            var isFriend = false
            if let list = UserDefaults.getStringArrayVal(key: NSUserDefaultKeys.FRIENDSLIST) as? [String] {
                isFriend = list.contains(channelID)
            }
            
            let channelPreviewVC = self.storyboard?.instantiateViewController(withIdentifier:"ChannelPreviewVC") as! ChannelPreviewVC
            
            if let avatarURL = featureChannels[indexPath.row]["avatarURL"] as? String {
                channelPreviewVC.channelImgUrl = avatarURL
            }
            
            if isFriend {
                channelPreviewVC.msg = "Unfollow"
            } else {
                channelPreviewVC.msg = "Become a Fan"
            }
            
            if let name = featureChannels[indexPath.row]["name"] as? String {
                self.channelName = name
                channelPreviewVC.channelName = name
                
            }
            
            channelPreviewVC.isFriend = isFriend
            channelPreviewVC.channelId = channelID
            channelPreviewVC.indexPath = indexPath
            channelPreviewVC.ChannelPreviewVCDelegate = self
            var height = 185.0
            if let desc = featureChannels[indexPath.row]["desc"] as? String {
                channelPreviewVC.channelDesc = desc
                let descheight = CommonFunctions.getTextHeightWdith(param: desc, font : CommonFonts.SFUIText_Regular(setsize: 14.0)).height
                height = height + Double(min(descheight, 100.0)) + 20.0
            }
            
            /*
             //MARK: set channel detail
             if let dele = self.tabBarDelegate {
             channelPreviewVC.delegate = dele
             }
             channelPreviewVC.channelViewFanVCState = ChannelViewFanVCState.BeepDetailVC
             channelPreviewVC.channelId = channelID
             */
            
            channelPreviewVC.preferredContentSize = CGSize(width: SCREEN_WIDTH, height: CGFloat(height))
            
            //previewingContext.sourceRect = cell.frame
            
            return channelPreviewVC
        }
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        guard let indexPath = previewingContext.sourceView.tableViewIndexPath(tableView: self.dataTableView) else { return  }
        print( indexPath)
        if indexPath.section == 1 {
            self.showBeepDetailPage(row: indexPath.row)
        } else {
            self.showChannelDetail(index: indexPath)
        }
    }
    
}


extension AllTagVC : ChannelPreviewVCDelegate {
    func showChannelDetail(index: IndexPath) {
        
        
        guard let result = self.featureChannel["results"] as? [AnyObject], result.count > 0 else { return }
        guard let channelID = result[index.row]["avatarID"] as? String else { return }
        let vc = self.storyboard?.instantiateViewController(withIdentifier:"ChannelViewFanVC") as! ChannelViewFanVC
        vc.channelViewFanVCState = ChannelViewFanVCState.AllTagVCChannelState
        vc.allTagVCDelegate = self
        if let dele = self.delegate {
            vc.delegate = dele
        } else  {
            vc.delegate = TABBARDELEGATE
        }
        vc.channelName = self.channelName
        vc.channelId = channelID
        self.navigationController?.pushViewController(vc, animated: true)
    }
}


extension AllTagVC : UITableViewDataSourcePrefetching {
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        if self.feedRequestComplete == true || self.channelRequestComplete == true {
            for indexPath in indexPaths {
                if indexPath.section == 1, self.beepData.count > 0 {
                    self.userDataCellSetUp(tableView: tableView, indexPath: indexPath)
                }
                //let _ =   self.tableView(tableView, cellForRowAt: indexPath)
            }
        }
    }
}

extension AllTagVC : shareDelegate {
    func shareData() {
        CommonFunctions.displayShareSheet(shareContent: SHARE_Fantasticoh_URL, viewController: self)
    }
}

