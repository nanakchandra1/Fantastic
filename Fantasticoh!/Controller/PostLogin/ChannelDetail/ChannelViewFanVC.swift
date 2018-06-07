//
//  ChannelViewVC.swift
//  Fantasticoh!
//
//  Created by Appinventiv on 07/09/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//
//TODO : Hastag WS

import UIKit
import SafariServices
import SwiftyJSON
import GoogleMobileAds
//import IQKeyboardManager

protocol ChannelViewFanVCDelegate : class {
    func moveToChat()
}

enum ChannelViewFanVCState {
    case None, AllTagVCState, ExploreContentVC, ExploreChannelVC, ProfileVCState, SideMenuState, AllTagVCChannelState, SuggestedChannelVCState, ProfileUserLikes, BeepDetailVC, TrendingTabVC, SearchChannelVC, ProfileFansVCState, SelfVCState, AllTagVCChatState
}

class ChannelViewFanVC: UIViewController {
    
    //MARK:- @IBOutlet & Propertie's
    //MARK:-
    @IBOutlet weak var userNameLbl: UILabel!
    //    @IBOutlet weak var bgImageView: UIImageView!
    //    @IBOutlet weak var profileImageView: UIImageView!
    //    @IBOutlet weak var blurMiddleView: FXBlurView!
    //    @IBOutlet weak var nameLbl: UILabel!
    //    @IBOutlet weak var countLbl: UILabel!
    //    @IBOutlet weak var fanBtn: UIButton!
    //    @IBOutlet weak var updateBtn: UIButton!
    //    @IBOutlet weak var chatBtn: UIButton!
    //    @IBOutlet weak var fansBtn: UIButton!
    
    @IBOutlet weak var scrollV: MXScrollView!
    //    @IBOutlet weak var tagsCollectionView: UICollectionView!
    //
    //    @IBOutlet weak var movableSepratorLeadingCons: NSLayoutConstraint!
    //    @IBOutlet weak var collectionViewHeightcCons: NSLayoutConstraint!
    
    var celebFooterView: CelebFooterView!
    var celebHeaderViewXIB: CelebHeaderViewXIB!
    
    weak var delegate: TabBarDelegate!
    weak var allTagVCDelegate: AllTagVCDelegate!
    weak var likesVCDelegate: LikesVCDelegate!
    weak var suggestedChannelVCDelegate: SuggestedChannelVCDelegate!
    weak var fansVCDelegate: FansVCDelegate!
    
    
    var channelViewFanVCState = ChannelViewFanVCState.None
    var channelId = ""
    var currentCounter: Int32 = 0
    var channelName:String = ""
    var blankRowCount = [Int]()
    var chData:ChannelUserData?
    var channelPhotos = [ChannelPhotosAndVideos]()
    var channelVideos = [ChannelPhotosAndVideos]()
    var updatesVC: ChannelUpdatesVC!
    var chatVC: CommentVC!
    var channelPhotoVC: ChannelPhotosVC!
    var channelVideoVC: ChannelVideoVC!
    var fansVC: FansVC!
    var nowIsFan = false
    var previousSelectedIndex = 0
    var releatedChannels = [AnyObject]()
    var releatedChannelFrom = 0
    var releatedChannelsize = 10
    var isChat = false
    var releatedTag = ""
    var webViewText = ""
    var avtarUrl = ""
    var userName:String = ""
    var chname:String = ""
    var displayLabel = [String]()
    
      var rewardBasedVideo: GADRewardBasedVideoAd?
    //MARK:- View Life Cycle
    //MARK:-
    override func viewDidLoad() {
        super.viewDidLoad()
        
 
        rewardBasedVideo = GADRewardBasedVideoAd.sharedInstance()
    
        rewardBasedVideo?.load(GADRequest(),
                               withAdUnitID: "ca-app-pub-3940256099942544/1712485313")

//        if GADRewardBasedVideoAd.sharedInstance().isReady == true {
//            GADRewardBasedVideoAd.sharedInstance().present(fromRootViewController: self)
//        }
        self.initSetup()
        self.scrollViewSetup()
       
        self.setChannelDetail()
        Globals.setScreenName(screenName: "ChannelDetail", screenClass: "ChannelDetail")
        NotificationCenter.default.addObserver(self, selector: #selector(self.setParalexHeight(notification:)), name: NSNotification.Name("setHeightNotification"), object: nil)
    }
    
    // nitin
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.view.endEditing(true)
        
        self.view.layoutIfNeeded()
        
        self.view.updateConstraintsIfNeeded()
        
        //if APP_DELEGATE.applicationState == .active {
        
        var vcFrame: CGFloat       = 160
        
        var statusBarHeight =  (APP_DELEGATE.statusBarFrame.height - 20)
        
        
        if self.navigationController?.view.frame.size.height == SCREEN_HEIGHT {
            
            statusBarHeight = CGFloat(0)
            
        }
        
        if !IsShowTap {
            
            vcFrame       = 110
            
            //statusBarHeight = APP_DELEGATE.statusBarFrame.height
        }
        
        vcFrame = vcFrame - statusBarHeight
        self.scrollV.frame = CGRect(x:0,y: 64,width: SCREEN_WIDTH,height: SCREEN_HEIGHT - statusBarHeight)
        self.scrollV.contentSize = self.scrollV.frame.size
        self.celebFooterView.frame = CGRect(x:0,y: 0,width: SCREEN_WIDTH,height: self.scrollV.frame.height - statusBarHeight)
        self.updatesVC.view.frame = CGRect(x:0,y: 0,width: SCREEN_WIDTH,height: self.celebFooterView.frame.size.height-vcFrame)
        self.channelPhotoVC.view.frame = CGRect(x:SCREEN_WIDTH,y: 0,width: SCREEN_WIDTH,height: self.celebFooterView.frame.size.height-vcFrame)
        self.channelVideoVC.view.frame = CGRect(x: SCREEN_WIDTH*2,y: 0,width: SCREEN_WIDTH,height: self.celebFooterView.frame.size.height-vcFrame)
        self.scrollV.backgroundColor = UIColor.black
        
        //  }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
        
        APP_DELEGATE.statusBarStyle = UIStatusBarStyle.lightContent
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.view.layoutIfNeeded()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK:- @IBAction, Selector &  method's
    //MARK:-
    
    func initSetup() {
        
        self.viewChannelDetails(channelId: self.channelId)
       
        self.celebFooterView    = CelebFooterView.instanciateFromNib()
        self.celebHeaderViewXIB = CelebHeaderViewXIB.instanciateFromNib()
        self.celebFooterView.updateBtn.addTarget(self, action: #selector(self.updatesBtnTap(sender:)), for: UIControlEvents.touchUpInside)
        
        //Arvind Rawat
        //*********************************************
        self.celebFooterView.chatBtn.addTarget(self, action: #selector(self.chatsBtnTap(sender:)), for: UIControlEvents.touchUpInside)
        self.celebFooterView.fansBtn.addTarget(self, action: #selector(self.fansBtnTap(sender:)), for: UIControlEvents.touchUpInside)
        
        //**********************************************
        
        
        // self.celebFooterView.chatBtn.addTarget(self, action: #selector(self.chatsBtnTap(sender:)), for: UIControlEvents.touchUpInside)
        // self.celebFooterView.fansBtn.addTarget(self, action: #selector(self.fansBtnTap(sender:)), for: UIControlEvents.touchUpInside)
        //Arvind
        self.celebHeaderViewXIB.fanBtn.addTarget(self, action: #selector(self.fanBtnTap(sender:)), for: UIControlEvents.touchUpInside)
        
        self.celebHeaderViewXIB.chatBtn.addTarget(self, action: #selector(self.chatsBtnTap(sender:)), for: UIControlEvents.touchUpInside)
        
        self.celebHeaderViewXIB.countLbl.isHidden = true
        
        //Arvind
        self.celebHeaderViewXIB.countBtn.addTarget(self, action: #selector(self.fansBtnTap(sender:)), for: UIControlEvents.touchUpInside)
        
        self.scrollV.frame = CGRect(x:0,y: 64,width: SCREEN_WIDTH,height: SCREEN_HEIGHT)
        self.celebHeaderViewXIB.frame = CGRect(x:0,y: 0,width: SCREEN_WIDTH,height: 140)
        self.celebFooterView.frame = CGRect(x:0,y: 0,width: SCREEN_WIDTH,height: self.scrollV.frame.height)
        
        self.scrollV.parallaxHeader.view    = self.celebHeaderViewXIB
        self.scrollV.parallaxHeader.mode    = MXParallaxHeaderMode.fill
        self.scrollV.isScrollEnabled = true
        self.scrollV.bounces = false
        
        //self.scrollV.parallaxHeader.height  = 155
        
        //Arvind*******
        self.scrollV.parallaxHeader.height  = 420
        //*************
        self.scrollV.parallaxHeader.minimumHeight = 0
        self.scrollV.addSubview(self.celebFooterView)
        
        self.celebHeaderViewXIB.tagsCollectionView.delegate = self
        self.celebHeaderViewXIB.tagsCollectionView.dataSource = self
        
        self.celebFooterView.scrollV.showsHorizontalScrollIndicator = false
        
        let tagsCollectionCellXIB = UINib(nibName: "TagsCollectionCellXIB", bundle: nil)
        self.celebHeaderViewXIB.tagsCollectionView.register(tagsCollectionCellXIB, forCellWithReuseIdentifier: "TagsCollectionCellXIB")
        
        self.celebHeaderViewXIB.nameLbl.textColor = CommonColors.lblTextColor()
        self.celebHeaderViewXIB.profileImageView.layer.cornerRadius = self.celebHeaderViewXIB.profileImageView.frame.width/2
        self.celebHeaderViewXIB.profileImageView.layer.masksToBounds = true
        //self.celebHeaderViewXIB.blurMiddleView.blurRadius = 10
        
        self.celebHeaderViewXIB.profileImageView.image = PROFILEPLACEHOLDER
        self.celebHeaderViewXIB.nameLbl.text = ""
        
        self.celebHeaderViewXIB.delegate = self
        self.celebHeaderViewXIB.displayLabel = self.displayLabel
        self.celebHeaderViewXIB.collectionView.reloadData()
        
        //Arvind
        self.celebHeaderViewXIB.countBtn.setTitle("NO FAN", for:  .normal)
        self.celebHeaderViewXIB.countBtn.setTitleColor(#colorLiteral(red: 0.2663406923, green: 0.6735604378, blue: 0.2969806151, alpha: 1), for:  .normal)
        
        //self.celebHeaderViewXIB.countLbl.text = "Be the first fan"
        
        
        self.celebHeaderViewXIB.fanBtn.backgroundColor = UIColor.clear
        self.celebHeaderViewXIB.fanBtn.setTitleColor(CommonColors.lblTextColor(), for:  .normal)
        self.celebHeaderViewXIB.fanBtn.setTitle(" FAN", for:  .normal)
        self.celebHeaderViewXIB.fanBtn.setImage(UIImage(named: "plus"), for:  .normal)
        self.celebHeaderViewXIB.fanBtn.layer.borderWidth = 1.0
        self.celebHeaderViewXIB.fanBtn.layer.borderColor = CommonColors.globalRedColor().cgColor
        self.celebHeaderViewXIB.fanBtn.layer.cornerRadius = 2.0
        self.celebHeaderViewXIB.fanBtn.layer.masksToBounds = true
        
        //Arvind
        self.celebHeaderViewXIB.chatBtn.backgroundColor = CommonColors.fanGreenBtnColor()
        self.celebHeaderViewXIB.chatBtn.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for:  .normal)
        self.celebHeaderViewXIB.chatBtn.setTitle(" CHAT", for:  .normal)
        self.celebHeaderViewXIB.chatBtn.setImage(UIImage(named: "ic_chat"), for:  .normal)
        self.celebHeaderViewXIB.chatBtn.layer.borderWidth = 0.0
        // self.celebHeaderViewXIB.chatBtn.layer.borderColor = CommonColors.globalRedColor().cgColor
        self.celebHeaderViewXIB.chatBtn.layer.cornerRadius = 2.0
        self.celebHeaderViewXIB.chatBtn.layer.masksToBounds = true
        //////
        
        //self.updateBtn.setTitleColor(CommonColors.btnTitleColor(), for:  .normal)
        self.celebHeaderViewXIB.collectionViewHeightcCons.constant = 75
        self.selectBtn(sender: self.celebFooterView.updateBtn)
        
        self.celebFooterView.scrollV.isScrollEnabled = false
        
        let chatUserNameTap = UITapGestureRecognizer(target:self, action:#selector(self.channelAvtarTap(img:)))
        celebHeaderViewXIB.profileImageView.isUserInteractionEnabled = true
        celebHeaderViewXIB.profileImageView.addGestureRecognizer(chatUserNameTap)
        
    }
    
    func setParalexHeight(notification: Notification){

        let info = notification.userInfo as? [String: Any]
        let key = info!["key"] as! Int
        
        switch key {
            
        case 0:
            self.setHeight(with: 0)
        case 1:
            self.setHeight(with: 1)
        case 2:
            self.setHeight(with: 2)

        case 3:
            self.setHeight(with: 3)

        case 4:
            self.setHeight(with: 4)

        case 5:
            self.setHeight(with: 5)
        default:
            print("")
        }
    }
    
    
    func setHeight(with row : Int){
        
        let height = self.scrollV.parallaxHeader.height

        if !self.blankRowCount.contains(row){
            self.scrollV.parallaxHeader.height = height - CGFloat(30)
            self.blankRowCount.append(row)
        }

    }
    
    func scrollViewXIBSetup () {
        
    }
    
    
    func scrollViewSetup() {
        
        self.celebFooterView.scrollV.delegate = self
        
        updatesVC = self.storyboard!.instantiateViewController(withIdentifier:"ChannelUpdatesVC") as! ChannelUpdatesVC
        if let dele = self.allTagVCDelegate {
            updatesVC.alltagVCDelegate = dele
        }
        
        if let dele = self.delegate {
            updatesVC.delegate = dele
        }
        if let dele = self.likesVCDelegate {
            updatesVC.likesVCDelegate = dele
        }
        updatesVC.channelViewFanVCDelegate = self
        updatesVC.channelId = self.channelId
        self.celebHeaderViewXIB.displayLabel = self.displayLabel
        
//        updatesVC.display
        self.addChildViewController(updatesVC)
        self.celebFooterView.scrollV.addSubview(updatesVC.view)
        updatesVC.didMove(toParentViewController: self)
        updatesVC.view.frame = CGRect(x:0,y: 0,width: SCREEN_WIDTH,height: self.celebFooterView.scrollV.frame.size.height-120)
        
        
        //Arvind Rawat
        //====================================================================================================
        
        channelPhotoVC = self.storyboard!.instantiateViewController(withIdentifier:"ChannelPhotosVC") as! ChannelPhotosVC
        channelPhotoVC.channelId = self.channelId
        self.addChildViewController(channelPhotoVC)
        self.celebFooterView.scrollV.addSubview(channelPhotoVC.view)
        channelPhotoVC.didMove(toParentViewController: self)
        channelPhotoVC.view.frame = CGRect(x:0,y: SCREEN_WIDTH,width: SCREEN_WIDTH,height: self.celebFooterView.scrollV.frame.size.height-120)
        
        //====================================================================================================
        
        
        /*Previous
         //===============================================================================================
         
         chatVC = self.storyboard!.instantiateViewController(withIdentifier:"CommentVC") as! CommentVC
         chatVC.channelId = self.channelId
         self.addChildViewController(chatVC)
         self.celebFooterView.scrollV.addSubview(chatVC.view)
         chatVC.didMove(toParentViewController: self)
         chatVC.view.frame = CGRect(x:0,y: SCREEN_WIDTH,width: SCREEN_WIDTH,height: self.celebFooterView.scrollV.frame.size.height-120)
         //===============================================================================================
         */
        
        
        
        
        //Arvind Rawat
        //====================================================================================================
        channelVideoVC = self.storyboard!.instantiateViewController(withIdentifier:"ChannelVideoVC") as! ChannelVideoVC
        
        channelVideoVC.channelId = channelId
        channelVideoVC.avtarUrl = self.avtarUrl
        let navigationController = SHARED_APP_DELEGATE.window?.rootViewController
        //fansVC.temExploreVC = navigationController
        self.addChildViewController(channelVideoVC)
        self.celebFooterView.scrollV.addSubview(channelVideoVC.view)
        channelVideoVC.didMove(toParentViewController: self)
        channelVideoVC.view.frame = CGRect(x:0,y: SCREEN_WIDTH*2,width: SCREEN_WIDTH,height: self.celebFooterView.scrollV.frame.size.height-120)
        
        self.celebFooterView.scrollV.contentSize = CGSize(width: SCREEN_WIDTH * 3, height: 0)
        
        //====================================================================================================
        
        //*******************************************
        //Previous
        
        //        fansVC = self.storyboard!.instantiateViewController(withIdentifier:"FansVC") as! FansVC
        //        if let dele = self.delegate {
        //            fansVC.tabBarDelegate = dele
        //        }
        //        fansVC.vCState = VCState.Channel
        //        fansVC.channelId = self.channelId
        //
        //
        //        let navigationController = SHARED_APP_DELEGATE.window?.rootViewController
        //        print_debug(object: navigationController)
        //        fansVC.temExploreVC = navigationController
        //        self.addChildViewController(fansVC)
        //        self.celebFooterView.scrollV.addSubview(fansVC.view)
        //        fansVC.didMove(toParentViewController: self)
        //        fansVC.view.frame = CGRect(x:0,y: SCREEN_WIDTH*2,width: SCREEN_WIDTH,height: self.celebFooterView.scrollV.frame.size.height-120)
        //
        //        self.celebFooterView.scrollV.contentSize = CGSize(width: SCREEN_WIDTH * 3, height: 0)
    }
    
    func setScrollViewPostion()  {
        self.selectBtn(sender: self.celebFooterView.chatBtn)
    }
    
    @IBAction func backBtnTap(sender: UIButton) {
        
        CommonFunctions.endAllEditing()
        
        switch self.channelViewFanVCState {
            
        case .ExploreContentVC :
            //USE
            if let dele = self.delegate {
                dele.backToExploreVC(state: SetExploreVCDataState.Content)
            }
            
        case .AllTagVCChannelState, .AllTagVCChatState :
            //USE
            if self.nowIsFan {
                self.navigationController?.popViewController(animated: true)
                if let dele = ALLTAGVCDELEGATE {
                    print_debug(object: "Delegate found")
                    dele.beepDataReload()
                } else {
                    print_debug(object: "Delegate not found")
                }
            } else {
                self.updatesVC.allTagVcUpdate()
            }
            
        case .SideMenuState :
            //USE
            if self.nowIsFan {
                self.navigationController?.popViewController(animated: true)
                if let dele = ALLTAGVCDELEGATE {
                    dele.beepDataReload()
                }
                
            } else {
                self.updatesVC.allTagVcUpdate()
            }
        case .ExploreChannelVC :
            self.navigationController?.popViewController(animated: true)
            
        case .SuggestedChannelVCState :
            if let dele = self.suggestedChannelVCDelegate {
                dele.dataUpdate(index: self.previousSelectedIndex)
            }
            self.navigationController?.popViewController(animated: true)
            
        case .ProfileUserLikes :
            self.updateFansAndLike()
            
        case .ProfileFansVCState :
            self.updateFansAndLike()
            
        case .BeepDetailVC :
            self.navigationController?.popViewController(animated: true)
            if self.nowIsFan {
                if let dele = ALLTAGVCDELEGATE {
                    dele.beepDataReload()
                }
            }
            
        case .SelfVCState :
            self.navigationController?.popViewController(animated: true)
            
        case .TrendingTabVC:
            self.navigationController?.popViewController(animated: true)
            
        default :
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func infoBtnTap(sender: UIButton) {
        CommonFunctions.endAllEditing()
        
        print_debug(object: self.webViewText)
        
        //        if self.webViewText.isEmpty {
        //            CommonFunctions.showInfoAlert(title: "", msg: CommonTexts.NO_INTOF_AVALIBLE)
        //            return
        //        }
        
        let webViewVC = self.storyboard?.instantiateViewController(withIdentifier:"WebViewVC") as! WebViewVC
        //webViewVC.text = self.webViewText
        //        webViewVC.urlString = "https://www.fantasticoh.com/channel?id=\(self.channelId)&src=ios-app"
        webViewVC.urlString = "https://www.fantasticoh.com/channel/profile?id=\(self.channelId)"
        self.present(webViewVC, animated: true, completion: nil)
        
        // https://www.fantasticoh.com/channel?id=<channelID>&src=ios-app
        
        
    }
    
    @IBAction func searchBtnTap(sender: UIButton) {
        CommonFunctions.endAllEditing()
        let vc = self.storyboard?.instantiateViewController(withIdentifier:"SearchChannelVC") as! SearchChannelVC
        vc.previoudDataIsAvalible = PrevioudDataIsAvalible.NotAvalible
        vc.searchChannelVCState = SearchChannelVCState.HomeVC
        let navVC = UINavigationController(rootViewController: vc)
        navVC.navigationBar.isHidden = true
        self.present(navVC, animated: true) {
            APP_DELEGATE.statusBarStyle = UIStatusBarStyle.default
        }
    }
    
    func fanBtnTap(sender: UIButton) {
        CommonFunctions.endAllEditing()
        guard CommonFunctions.checkLogin() else {
            CommonFunctions.showLoginAlert(vc: self)
            return
        }
        self.nowIsFan = true
        if !sender.isSelected {
            print_debug(object: "oN")
            //            CommonFunctions.fanBtnOnFormatting(btn: sender)
            //            self.currentCounter = self.currentCounter+1
            //            if self.currentCounter == 0 {
            //                self.celebHeaderViewXIB.countLbl.text = "1 Fan"
            //            } else {
            //                self.celebHeaderViewXIB.countLbl.text = "\(self.currentCounter) Fans"
            //            }
            self.followChannel(channelId: self.channelId, follow: true)
            self.showSharePopup(name: self.userNameLbl.text ?? "")
            //self.FansVC.
        } else {
            print_debug(object: "oFF")
            //            CommonFunctions.fanBtnOffFormatting(btn: sender)
            //            self.currentCounter = self.currentCounter-1
            //            if self.currentCounter == 1 || self.currentCounter == 2 {
            //                self.celebHeaderViewXIB.countLbl.text = "\(self.currentCounter) Fan"
            //            } else {
            //                self.celebHeaderViewXIB.countLbl.text = "\(self.currentCounter) Fans"
            //            }
            self.followChannel(channelId: self.channelId, follow: false)
        }
        
        
    }
    
    func updatesBtnTap(sender: UIButton) {
        CommonFunctions.endAllEditing()
        self.selectBtn(sender: sender)
    }
    
    func chatsBtnTap(sender: UIButton) {
        
        CommonFunctions.endAllEditing()
        sender.tag = 1
        self.selectBtn(sender: sender)
    }
    
    
    func fansBtnTap(sender: UIButton) {
        CommonFunctions.endAllEditing()
        self.selectBtn(sender: sender)
    }
    
    func selectBtn(sender: UIButton) {
        
        sender.setTitleColor(CommonColors.globalRedColor(), for:  .normal)
        self.celebFooterView.updateBtn.setTitleColor(CommonColors.btnTitleColor(), for:  .normal)
        self.celebFooterView.chatBtn.setTitleColor(CommonColors.btnTitleColor(), for:  .normal)
        self.celebFooterView.fansBtn.setTitleColor(CommonColors.btnTitleColor(), for:  .normal)
        
        
        
        switch sender {
            
        case self.celebFooterView.updateBtn:
             sender.setTitleColor(#colorLiteral(red: 1, green: 0.1215686275, blue: 0.2392156863, alpha: 1), for:  .normal)
            print_debug(object: "updateBtn")

            self.celebFooterView.scrollV.setContentOffset(CGPoint(x:0,y: 0), animated: true)
            self.celebFooterView.movableSepratorLeadingCons.constant = 0
            
            
            //ARVind*********************************                                                               **
            
        case self.celebHeaderViewXIB.chatBtn:
            print_debug(object: "chatBtn")
            sender.setTitleColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for:  .normal)

            guard CommonFunctions.checkLogin() else {
                CommonFunctions.showLoginAlert(vc: self)
                return
            }

            
            let vc = self.storyboard?.instantiateViewController(withIdentifier:"OnlyCommentVC") as! OnlyCommentVC
            vc.channelId = self.channelId
            
            self.navigationController?.pushViewController(vc, animated: true)
            
            
        case self.celebFooterView.chatBtn:
            
             sender.setTitleColor(#colorLiteral(red: 1, green: 0.1215686275, blue: 0.2392156863, alpha: 1), for:  .normal)
            if self.celebFooterView.chatBtn.tag == 1{
                
                print_debug(object: "chatBtn")
                self.scrollV.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
                self.celebFooterView.scrollV.setContentOffset(CGPoint(x:SCREEN_WIDTH, y:0), animated: true)
                self.celebFooterView.movableSepratorLeadingCons.constant = SCREEN_WIDTH/3
                
            }else{
                
                guard CommonFunctions.checkLogin() else {
                    CommonFunctions.showLoginAlert(vc: self)
                    return
                }

//                sender.setTitleColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for:  .normal)
                
                let vc = self.storyboard?.instantiateViewController(withIdentifier:"OnlyCommentVC") as! OnlyCommentVC
                vc.channelId = self.channelId
                
                self.navigationController?.pushViewController(vc, animated: true)
                
            }
            

            
            
            
            //******************************************                                                            **
            //        case self.celebFooterView.chatBtn:
            //            print_debug(object: "chatBtn")
            //            self.scrollV.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
            //            self.celebFooterView.scrollV.setContentOffset(CGPoint(x:SCREEN_WIDTH, y:0), animated: true)
            //            self.celebFooterView.movableSepratorLeadingCons.constant = SCREEN_WIDTH/3
            
        //Arvind**************************
        case self.celebHeaderViewXIB.countBtn:
            
            guard CommonFunctions.checkLogin() else {
                CommonFunctions.showLoginAlert(vc: self)
                return
            }

            print_debug(object: "fanBtnTap")
            sender.setTitleColor(#colorLiteral(red: 0.2663406923, green: 0.6735604378, blue: 0.2969806151, alpha: 1), for:  .normal)
            let vc = self.storyboard?.instantiateViewController(withIdentifier:"OnlyFanVC") as! OnlyFanVC
            if let dele = self.delegate {
                vc.delegate = dele
            }
            vc.vCState = VCState.Channel
            vc.channelId = self.channelId
            vc.userName = self.userName
            self.navigationController?.pushViewController(vc, animated: true)
            
            
        case self.celebFooterView.fansBtn:
            
             sender.setTitleColor(#colorLiteral(red: 1, green: 0.1215686275, blue: 0.2392156863, alpha: 1), for:  .normal)
            print_debug(object: "fanBtnTap")
            self.celebFooterView.scrollV.setContentOffset(CGPoint(x:SCREEN_WIDTH*2, y:0), animated: true)
            self.celebFooterView.movableSepratorLeadingCons.constant = (SCREEN_WIDTH/3) + (SCREEN_WIDTH/3)
            
            
            //********************************************
            
            //        case self.celebFooterView.fansBtn:
            //
            //            print_debug(object: "fanBtnTap")
            //            self.celebFooterView.scrollV.setContentOffset(CGPoint(x:SCREEN_WIDTH*2, y:0), animated: true)
            //            self.celebFooterView.movableSepratorLeadingCons.constant = (SCREEN_WIDTH/3) + (SCREEN_WIDTH/3)
            
        default :
            print_debug(object: "default")
        }
        //        sender.setTitleColor(CommonColors.globalRedColor(), for:  .normal)
    }
    
    func updateFansAndLike () {
        if let dele = self.fansVCDelegate {
            dele.fansListUpdate()
        }
        if let dele = self.likesVCDelegate {
            print_debug(object: dele)
            self.updatesVC.profileLikesUpdate()
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    func is3DTouchAvailable(btn: UIButton) -> Bool {
        if #available(iOS 9, *) {
            if self.traitCollection.forceTouchCapability == UIForceTouchCapability.available {
                self.registerForPreviewing(with: self, sourceView: btn)
                return true
            } else { return false }
        } else { return false}
    }
    
    func checkFanStatus() {
        if !self.celebHeaderViewXIB.fanBtn.isSelected {
            print_debug(object: "oN")
            CommonFunctions.fanBtnOnFormatting(btn: self.celebHeaderViewXIB.fanBtn)
            self.currentCounter = self.currentCounter+1
            if self.currentCounter == 1 {
                
                //Arvind*********
                self.celebHeaderViewXIB.countBtn.setTitle("1 Fan", for:  .normal)
                self.celebHeaderViewXIB.countBtn.setTitleColor(#colorLiteral(red: 0.2663406923, green: 0.6735604378, blue: 0.2969806151, alpha: 1), for:  .normal)
                //************
                
                //self.celebHeaderViewXIB.countLbl.text = "1 Fan"
            } else {
                
                //Arvind*********
                self.celebHeaderViewXIB.countBtn.setTitle("\(self.currentCounter) Fans", for:  .normal)
                self.celebHeaderViewXIB.countBtn.setTitleColor(#colorLiteral(red: 0.2663406923, green: 0.6735604378, blue: 0.2969806151, alpha: 1), for:  .normal)
                //************
                
                //self.celebHeaderViewXIB.countLbl.text = "\(self.currentCounter) Fans"
            }
            //self.FansVC.
        } else {
            print_debug(object: "oFF")
            CommonFunctions.fanBtnOffFormatting(btn: self.celebHeaderViewXIB.fanBtn)
            self.currentCounter = self.currentCounter-1
            if self.currentCounter == 1  {
                
                //Arvind*********
                self.celebHeaderViewXIB.countBtn.setTitle("\(self.currentCounter) Fan", for:  .normal)
                self.celebHeaderViewXIB.countBtn.setTitleColor(#colorLiteral(red: 0.2663406923, green: 0.6735604378, blue: 0.2969806151, alpha: 1), for:  .normal)
                //************
                
                // self.celebHeaderViewXIB.countLbl.text = "\(self.currentCounter) Fan"
            } else if self.currentCounter == 0 {
                
                //Arvind*********
                self.celebHeaderViewXIB.countBtn.setTitle("NO FAN", for:  .normal)
                
                //************
                
                //self.celebHeaderViewXIB.countLbl.text = "Be the first fan"
            }else {
                
                //Arvind*********
                self.celebHeaderViewXIB.countBtn.setTitle("\(self.currentCounter) Fans", for:  .normal)
                
                //************
                //  self.celebHeaderViewXIB.countLbl.text = "\(self.currentCounter) Fans"
            }
        }
        
        self.celebHeaderViewXIB.fanBtn.isSelected = !self.celebHeaderViewXIB.fanBtn.isSelected
    }
    
    func channelAvtarTap(img: UIGestureRecognizer) {
        
        if !avtarUrl.isEmpty {
            _ =  SKPhoto.photoWithImageURL(avtarUrl)
            var images = [SKPhoto]()
            //let photo = SKPhoto.photoWithImage(self.profileImageView.image ?? PROFILEPLACEHOLDER!)// add some UIImage
            let photo = SKPhoto.photoWithImageURL(avtarUrl)
            photo.shouldCachePhotoURLImage = true
            images.append(photo)
            
            let browser = SKPhotoBrowser(photos: images)
            browser.delegate = self
            browser.initializePageIndex(0)
            present(browser, animated: true, completion: {
                
                APP_DELEGATE.setStatusBarHidden(true, with: .slide)
            })
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

//MARK:- UICollectionView Delegate & DataSource extension
//MARK:-
extension ChannelViewFanVC: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //        if self.releatedChannels.count > 0 {
        //            self.collectionViewHeightcCons.constant = 65
        //        } else {
        //            self.collectionViewHeightcCons.constant = 0
        //        }
        self.view.layoutIfNeeded()
        return self.releatedChannels.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagsCollectionCellXIB", for:  indexPath) as! TagsCollectionCellXIB
        cell.bgBtn.isHidden = false
        cell.bgBtn.addTarget(self, action: #selector(self.channelDetailBtnTap(btn:)), for: UIControlEvents.touchUpInside)
        
        _ = self.is3DTouchAvailable(btn: cell.bgBtn)
        cell.selectedBackgroundView?.backgroundColor = UIColor.clear
        if let name = self.releatedChannels[indexPath.row]["name"] as? String {
            print_debug(object: name)
            cell.lbl.text = name
        } else {
            cell.lbl.text = ""
        }
        
        if let avatarURL = self.releatedChannels[indexPath.row]["avatarURL"] as? String {
            cell.imageView.sd_setImage(with: URL(string: avatarURL), placeholderImage: CHANNELLOGOPLACEHOLDER)
        } else {
            cell.imageView.image = CHANNELLOGOPLACEHOLDER
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        CommonFunctions.endAllEditing()
        
        //guard let result = self.featureChannel["results"] as? [AnyObject] else { return }
        //guard let channelID = result[row]["avatarID"] as? String else { return }
        guard let channelID = self.releatedChannels[indexPath.row]["id"] as? String else {
            return }
        
        
        print(self.releatedChannels[indexPath.row])
        print(channelID)
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier:"ChannelViewFanVC") as! ChannelViewFanVC
        vc.channelViewFanVCState = ChannelViewFanVCState.SelfVCState
        if let dele = self.allTagVCDelegate {
            vc.allTagVCDelegate = dele
        }
        if let dele = self.delegate {
            vc.delegate = dele
        }
        vc.channelId = channelID
        
        if let nationality = self.releatedChannels[indexPath.row]["displayLabels"] as? [String], nationality.count > 0 {
            vc.displayLabel = nationality
            self.displayLabel = nationality
        }
        
        self.navigationController?.pushViewController(vc, animated: true)
        collectionView.deselectItem(at: indexPath, animated: true)
        
    }
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        return CGSize(width: 60, height: 75)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        //set HorizontalDistance
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        //return self.tagVerticalDistance
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
    }
    
    func channelDetailBtnTap(btn: UIButton){
        
        CommonFunctions.endAllEditing()
        guard let indexPath = btn.collectionViewIndexPath(collectionView: self.celebHeaderViewXIB.tagsCollectionView) else { return }
        
        print_debug(object: indexPath)
        
        guard let channelID = self.releatedChannels[indexPath.row]["id"] as? String else {
            return }
        
        print_debug(object: channelID)
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier:"ChannelViewFanVC") as! ChannelViewFanVC
        vc.channelViewFanVCState = ChannelViewFanVCState.SelfVCState
        if let dele = self.allTagVCDelegate {
            vc.allTagVCDelegate = dele
        }
        if let dele = self.delegate {
            vc.delegate = dele
        }
        vc.channelId = channelID
        if let nationality = self.releatedChannels[indexPath.row]["displayLabels"] as? [String], nationality.count > 0 {
            vc.displayLabel = nationality
        }
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
}

//MARK:- UIScrollViewDelegate
//MARK:-
extension ChannelViewFanVC: UIScrollViewDelegate, MXScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let inset  = scrollView.contentOffset
        if inset.x > 0  && inset.x <  (SCREEN_WIDTH*2) {
            self.celebFooterView.movableSepratorLeadingCons.constant = inset.x/3
        }
        
        if self.scrollV === scrollView {
            self.scrollV.contentOffset = self.scrollV.contentOffset
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if self.celebHeaderViewXIB.tagsCollectionView == scrollView {
            return
        }
        self.setctorSetting(scrollView: scrollView)
    }
    
    func setctorSetting(scrollView: UIScrollView) {
        
        switch scrollView.contentOffset.x {
            
        case 0:
            self.chatsBtnTap(sender: self.celebFooterView.updateBtn)
            
        case SCREEN_WIDTH:
            self.chatsBtnTap(sender: self.celebFooterView.chatBtn)
            
        case SCREEN_WIDTH*2:
            self.chatsBtnTap(sender: self.celebFooterView.fansBtn)
            
        default:
            print_debug(object: "Inside ChannelViewFanVC")
            
        }
    }
    
}


//MARK:- WebService
//MARK:-
extension ChannelViewFanVC {
    
    func setReleatedChannels(tags: String) {
        
        var param = [String : AnyObject]()
        param["channelID"]  = self.channelId as AnyObject
        param["includeFollowCount"]  = true as AnyObject
        param["from"] = self.releatedChannelFrom as AnyObject
        param["size"] = self.releatedChannelsize as AnyObject
        param["categoryTags0"] = tags as AnyObject
        
        WebServiceController.getReleatedChannelsList(parameters: param) { (sucess, errorMessage, data) in
            if let tempData = data {
                print_debug(object: tempData)
                
                if tempData.count == 0 {
                    self.setReleatedChannels(tags: "")
                } else {
                    self.releatedChannels.append(contentsOf: tempData)
                    self.celebHeaderViewXIB.tagsCollectionView.reloadData()
                }
                
                print_debug(object: tempData)
            }
            self.celebHeaderViewXIB.tagsIndicatorView.isHidden = true // nitin
        }
        
    }
    
    func followChannel(channelId: String, follow: Bool) {
        
        let params: [String: AnyObject] = ["channelID" : channelId as AnyObject, "virtualChannel" : false as AnyObject, "follow": follow as AnyObject]
        //Arvind
        self.celebHeaderViewXIB.fanBtn.isHidden = false
        
        // self.celebHeaderViewXIB.fanBtn.isHidden = true
        WebServiceController.follwUnfollowChannel(parameters: params) { (sucess, errorMessage, data) in
            
            if sucess {
                if let dele = TABBARDELEGATE {
                    dele.sideMenuUpdate()
                }
                print_debug(object: "You click on follow btn.")
                if follow {
                    
                    //Save NSUserDefault
                    if let list = UserDefaults.getStringArrayVal(key: NSUserDefaultKeys.FRIENDSLIST) as? [String] {
                        var tempList = list
                        print_debug(object: "Old Data : \(tempList)")
                        tempList.append(channelId)
                        print_debug(object: "New Data : \(tempList)")
                        UserDefaults.setStringVal(value: tempList as AnyObject, forKey: NSUserDefaultKeys.FRIENDSLIST)
                        print_debug(object: UserDefaults.getStringArrayVal(key: NSUserDefaultKeys.FRIENDSLIST) as? [String])
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
                self.checkFanStatus()
            } else {
                print_debug(object: errorMessage)
            }
            //self.fansVC.reloadTableView()
            self.celebHeaderViewXIB.fanBtn.isHidden = false
        }
        
    }
    
    func setChannelDetail() {
        
        WebServiceController.getMiniChannelDetail(channelId: self.channelId) { (success, errorMessage, data) in
            if success {
                
                if let channelData = data {
                    
                    print_debug(object: channelData)
                    
                    if let hashtags = channelData["categoryTags"] as? NSArray {
                        
                        var tagString = ""
                        if hashtags.count > 0 {
                            
                            if let str = hashtags.firstObject as? [String] {
                                tagString = str.joined(separator: ",")
                            }
                            
                            print(tagString)
                            
                            if tagString.count > 0 {
                                self.setReleatedChannels(tags: tagString)
                            } else {
                                self.setReleatedChannels(tags: "")
                            }
                            
                        }else {
                            self.setReleatedChannels(tags: "")
                        }
                        
                    } else {
                        self.setReleatedChannels(tags: "")
                    }
                    
                    if let imgUrl = channelData["avatarURLLarge"] as? String {
                        
                        self.avtarUrl = imgUrl
                        self.channelVideoVC.avtarUrl = imgUrl
                        self.celebHeaderViewXIB.profileImageView.sd_setImage(with: URL(string: imgUrl), placeholderImage: PROFILEPLACEHOLDER)
                        //                        self.celebHeaderViewXIB.profileImageView.sd_setImage(with: URL(string: imgUrl), placeholderImage: PROFILEPLACEHOLDER, options: .continueInBackground, completed: { (image, error, cacheType, url) in
                        //
                        //                            if let img = image {
                        //                              self.celebHeaderViewXIB.profileImageView.image = img.resizeImage(self.celebHeaderViewXIB.profileImageView.bounds.size.width, opaque: true)
                        //                            }
                        //                        })
                        self.celebHeaderViewXIB.bgImageView.layer.opacity = 0.5
                        //self.celebHeaderViewXIB.bgImageView.sd_setImage(with: URL(string: imgUrl), placeholderImage: CONTAINERPLACEHOLDER)
                        self.celebHeaderViewXIB.blurMiddleView.bringSubview(toFront: self.celebHeaderViewXIB.fanBtn)
                        self.celebHeaderViewXIB.blurMiddleView.bringSubview(toFront: self.celebHeaderViewXIB.nameLbl)
                        
                        //Arvind*******
                        self.celebHeaderViewXIB.blurMiddleView.bringSubview(toFront: self.celebHeaderViewXIB.countBtn)
                        // ***********
                        
                        //******self.celebHeaderViewXIB.blurMiddleView.bringSubview(toFront: self.celebHeaderViewXIB.countLbl)
                        
                        
                        
                        //self.celebHeaderViewXIB.bgImageView.bringSubviewToFront(self.celebHeaderViewXIB.fanBtn)
                        //self.celebHeaderViewXIB.bringSubviewToFront(self.celebHeaderViewXIB.nameLbl)
                        //self.celebHeaderViewXIB.bringSubviewToFront(self.celebHeaderViewXIB.countLbl)
                        
                        //                        let img = UIImageView()
                        //                        img.sd_setImage(with: URL(string: imgUrl), placeholderImage: CONTAINERPLACEHOLDER)
                        //                        img.contentMode = .ScaleAspectFill
                        //                        img.clipsToBounds = true
                        //                        img.frame = self.celebHeaderViewXIB.blurMiddleView.frame
                        //                        img.layer.opacity = 0.5
                        
                        //self.view.addSubview(img)
                        //self.view.sendSubviewToBack(img)
                        
                    }
                    
                    if let name = channelData["name"] as? String {
                        self.userName = name
                        self.channelVideoVC.channelName = name
                        self.celebHeaderViewXIB.nameLbl.text = name
                        self.userNameLbl.text = name
                    }
                    
                    if let desc = channelData["desc"] as? String {
                        self.webViewText = desc
                    }
                    
                    if let count = channelData["countFollowers"]?.int64Value {
                        print_debug(object: count)
                        self.currentCounter = Int32(count)
                        if self.currentCounter == 1  {
                            
                            //Arvind*********
                            self.celebHeaderViewXIB.countBtn.setTitle("\(self.currentCounter) Fan", for:  .normal)
                            self.celebHeaderViewXIB.countBtn.setTitleColor(#colorLiteral(red: 0.2663406923, green: 0.6735604378, blue: 0.2969806151, alpha: 1), for:  .normal)
                            //************
                            
                            //self.celebHeaderViewXIB.countLbl.text = "\(self.currentCounter) Fan"
                        } else if self.currentCounter == 0 {
                            
                            //Arvind*********
                            self.celebHeaderViewXIB.countBtn.setTitle("NO FAN", for:  .normal)
                            self.celebHeaderViewXIB.countBtn.setTitleColor(#colorLiteral(red: 0.2663406923, green: 0.6735604378, blue: 0.2969806151, alpha: 1), for:  .normal)
                            //************
                            
                            // self.celebHeaderViewXIB.countLbl.text = "Be the first fan"
                        }else {
                            
                            //Arvind*********
                            self.celebHeaderViewXIB.countBtn.setTitle("\(self.currentCounter) Fans", for:  .normal)
                            self.celebHeaderViewXIB.countBtn.setTitleColor(#colorLiteral(red: 0.2663406923, green: 0.6735604378, blue: 0.2969806151, alpha: 1), for:  .normal)
                            //************
                            
                            
                            //self.celebHeaderViewXIB.countLbl.text = "\(self.currentCounter) Fans"
                        }
                    } else {
                        print_debug(object: "No counted.")
                    }
                    //
                    if let createTime = channelData["createTime"] as? String {
                        print(createTime)
                    }
                    
                    if let currentCellFanId = channelData["id"] as? String {
                        
                        if let list = UserDefaults.getStringArrayVal(key: NSUserDefaultKeys.FRIENDSLIST) as? [String] {
                            print_debug(object: "List Id : \(list)")
                            print_debug(object: "current cell Id : \(currentCellFanId)")
                            for temp in list{
                                print_debug(object: "temp Id : \(temp)")
                                if temp == currentCellFanId {
                                    CommonFunctions.fanBtnOnFormatting(btn: self.celebHeaderViewXIB.fanBtn)
                                    self.celebHeaderViewXIB.fanBtn.isSelected = true
                                    break
                                } else {
                                    CommonFunctions.fanBtnOffFormatting(btn: self.celebHeaderViewXIB.fanBtn)
                                    self.celebHeaderViewXIB.fanBtn.isSelected = false
                                }
                            }
                            
                        } else {
                            CommonFunctions.fanBtnOffFormatting(btn: self.celebHeaderViewXIB.fanBtn)
                            self.celebHeaderViewXIB.fanBtn.isSelected = false
                        }
                        
                        if let status = channelData["isUserFan"] as? Bool, status == true {
                            CommonFunctions.fanBtnOnFormatting(btn: self.celebHeaderViewXIB.fanBtn)
                            self.celebHeaderViewXIB.fanBtn.isSelected = true
                        }
                    }
                    
                }
                self.viewChannel(channelId: self.channelId)
                
               
                
            } else  {
                print_debug(object: errorMessage)
            }
        }
    }
    
    func viewChannel(channelId : String) {
        
        let url = WS_ViewChannel + "\(channelId)"
        
        WebServiceController.viewChannel(url: url, parameters: [String:AnyObject]()) { (sucess, msg, DataResultResponse) in
            if sucess {
                
                print_debug(object: "Success")
            } else {
                print_debug(object: "fail")
            }
        }
    }
    
}

extension ChannelViewFanVC{
  
    
    //Arvind Rawat
    //=============
    func viewChannelDetails(channelId : String) {
        
        //let url = WS_ChannelUserData + "\(channelId)"
        
        let url = "\(BASE_URL)channel/\(channelId)/summary"
        
        //Arvind
        
        WebServiceController.channelDetail(url: url, parameters: [String:AnyObject]()) { (sucess, msg, DataResultResponse) in
            
            if sucess {
                
                if let response = DataResultResponse{
                    
                    self.chData =  ChannelUserData(data: JSON(response))
                    
                }
       //*******************************************
                //=====================
                let detail = self.storyboard!.instantiateViewController(withIdentifier:"ChannelUserDetail") as! ChannelUserDetail
                
                detail.channelData = self.chData
                detail.channelID   = self.channelId
               
                self.channelPhotosAndVideo(channelId: channelId,video:false)
                self.channelPhotosAndVideo(channelId: channelId,video:true)
                let navigationController = SHARED_APP_DELEGATE.window?.rootViewController
                print_debug(object: navigationController)
                
                self.addChildViewController(detail)
                self.celebHeaderViewXIB.detailContainerView.addSubview(detail.view)
                detail.didMove(toParentViewController: self)
                
            } else {
                
                print_debug(object: "fail")
            }
        }
    }
    
    //Arvind Rawat
    //=============
    
    func channelPhotosAndVideo(channelId : String,video:Bool) {
        
        //Arvind
        var param = [String : AnyObject]()
        param["channels"]    = self.channelId as AnyObject
        param["videos"]      = video as AnyObject
        param["channelName"] = chData?.name as AnyObject
        //  param["channelName"] = self.chname as AnyObject
      
       
        WebServiceController.gettingChannelPhotos(parameters: param) { (sucess, msg, DataResultResponse) in
            
            if sucess {
                if let response = DataResultResponse{
                
                    for data in response{
                        
                        if video == false{
                       
                            self.channelPhotos.append(ChannelPhotosAndVideos(data: JSON(data)))
                         
                        }else{
                            self.channelVideos.append(ChannelPhotosAndVideos(data: JSON(data)))
                        }
                    }
                }
                if video == false{
                    self.channelPhotoVC.userName = (self.chData?.name) ?? ""
                    self.channelPhotoVC.photoData = self.channelPhotos
                    self.channelPhotoVC.photosTableView.reloadData()
                }else{
                    self.channelVideoVC.videosData = self.channelVideos
                    
                    self.channelVideoVC.channelVideoTableView.reloadData()
                }
               
            } else {
                print_debug(object: "fail")
            }
            
        }
    }
}


//MARK:- ChannelViewFanVCDelegate
//MARK:-

extension ChannelViewFanVC: ChannelViewFanVCDelegate {
    
    func moveToChat() {
        self.celebFooterView.chatBtn.tag = 2
        self.selectBtn(sender: self.celebFooterView.chatBtn)
    }
    
}



//MARK:- UIViewControllerPreviewingDelegate
//MARK:-
extension ChannelViewFanVC: UIViewControllerPreviewingDelegate {
    
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        guard CommonFunctions.checkLogin() else {
            //CommonFunctions.showLoginAlert(vc: self)
            return nil
        }
        
        guard #available(iOS 9.0, *) else { return nil }
        
        guard let indexPath = previewingContext.sourceView.collectionViewIndexPath(collectionView: self.celebHeaderViewXIB.tagsCollectionView) else { return nil }
        
        guard let channelID = self.releatedChannels[indexPath.item]["id"] as? String else { return nil }
        
        var isFriend = false
        if let list = UserDefaults.getStringArrayVal(key: NSUserDefaultKeys.FRIENDSLIST) as? [String] {
            isFriend = list.contains(channelID)
        }
        
        let channelPreviewVC = self.storyboard?.instantiateViewController(withIdentifier:"ChannelPreviewVC") as! ChannelPreviewVC
        
        if let avatarURL = self.releatedChannels[indexPath.item]["avatarURL"] as? String {
            channelPreviewVC.channelImgUrl = avatarURL
        }
        
        if isFriend {
            channelPreviewVC.msg = "Unfollow"
        } else {
            channelPreviewVC.msg = "Become a Fan"
        }
        
        if let name = self.releatedChannels[indexPath.item]["name"] as? String {
            channelPreviewVC.channelName = name
        }
        var height = 185.0
        if let desc = self.releatedChannels[indexPath.item]["desc"] as? String {
            channelPreviewVC.channelDesc = desc
            let descheight = CommonFunctions.getTextHeightWdith(param: desc, font : CommonFonts.SFUIText_Regular(setsize: 14.0)).height
            height = height + Double(min(descheight, 100.0)) + 20.0
        }
        channelPreviewVC.isFriend = isFriend
        channelPreviewVC.channelId = channelID
        channelPreviewVC.indexPath = indexPath
        channelPreviewVC.ChannelPreviewVCDelegate = self
        
        channelPreviewVC.preferredContentSize = CGSize(width: SCREEN_WIDTH, height: CGFloat(height))
        
        return channelPreviewVC
    }
    
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        guard let indexPath = previewingContext.sourceView.collectionViewIndexPath(collectionView: self.celebHeaderViewXIB.tagsCollectionView) else { return  }
        self.showChannelDetail(index: indexPath)
    }
    
    
    
}

//MARK:- SKPhotoBrowserDelegate
//MARK:-
extension ChannelViewFanVC :  SKPhotoBrowserDelegate {
    
    func didDismissAtPageIndex(_ index: Int) {
        
        APP_DELEGATE.setStatusBarHidden(false, with: .slide)
        
    }
    
    
}

extension ChannelViewFanVC : ChannelPreviewVCDelegate {
    func showChannelDetail(index: IndexPath) {
        
        
        guard let channelID = self.releatedChannels[index.item]["id"] as? String else {
            return }
        let vc = self.storyboard?.instantiateViewController(withIdentifier:"ChannelViewFanVC") as! ChannelViewFanVC
        if let dele = self.allTagVCDelegate {
            vc.allTagVCDelegate = dele
        }
        if let dele = self.delegate {
            vc.delegate = dele
        }
        vc.channelViewFanVCState = ChannelViewFanVCState.BeepDetailVC
        vc.channelId = channelID
        if let nationality = self.releatedChannels[index.item]["displayLabels"] as? [String], nationality.count > 0 {
            vc.displayLabel = nationality
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension ChannelViewFanVC : shareDelegate {
    func shareData() {
        CommonFunctions.displayShareSheet(shareContent: SHARE_Fantasticoh_URL, viewController: self)
    }
}


extension UIImage {
    func resizeImage(_ dimension: CGFloat, opaque: Bool, contentMode: UIViewContentMode = .scaleAspectFit) -> UIImage {
        var width: CGFloat
        var height: CGFloat
        var newImage: UIImage
        
        let size = self.size
        let aspectRatio =  size.width/size.height
        
        switch contentMode {
        case .scaleAspectFit:
            if aspectRatio > 1 {                            // Landscape image
                width = dimension
                height = dimension / aspectRatio
            } else {                                        // Portrait image
                height = dimension
                width = dimension * aspectRatio
            }
            
        default:
            fatalError("UIIMage.resizeToFit(): FATAL: Unimplemented ContentMode")
        }
        
        if #available(iOS 10.0, *) {
            let renderFormat = UIGraphicsImageRendererFormat.default()
            renderFormat.opaque = opaque
            let renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: height), format: renderFormat)
            newImage = renderer.image {
                (context) in
                self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
            }
        } else {
            UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), opaque, 0)
            self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
            newImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
        }
        
        return newImage
    }
}

extension ChannelViewFanVC: TagDelegate {
    
    func didTapOnTag(title: String) {
        
        guard let rootNavigation = APP_DELEGATE.keyWindow?.rootViewController as? UINavigationController, let tabbar = rootNavigation.viewControllers.first as? TabBarVC, let navigation = self.navigationController else {return}
//        tabbar.showSearchChannelDetails(searchText: title)
        for vc in navigation.viewControllers {
            if vc.isKind(of: SearchChannelVC.self) {
                self.dismiss(animated: true, completion: nil)
                break
            }
        }
        tabbar.tagText = title
        tabbar.exploreButtonAction(sender: tabbar.exploreButton)
        
        print("success")
    }
}
