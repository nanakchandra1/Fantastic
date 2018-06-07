//
//  BeepDetailVC.swift
//  Fantasticoh!
//
//  Created by Appinventiv on 09/09/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//
// nitin
import UIKit
import AVFoundation
import AVKit
import SafariServices
import ImageIO
import Firebase
import GoogleMobileAds

enum BeepVCState {
    case None, AllTagVCState, BeepDetailVCState, BeepDetailVCRelatedState, ChannelUpdateVCState, ExploreContentSearchStateVC, ProfileLikesBeep
}

protocol BeepDetailVCDelegate : class {
    
    func updateData(data: AnyObject)
}

class BeepDetailVC: UIViewController,GADInterstitialDelegate {
    
    //MARK:- @IBOutlet & Propertie's
    //MARK:-
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tblViewHeightCons: NSLayoutConstraint!
    
    @IBOutlet weak var adMobView: GADBannerView!
    @IBOutlet weak var sepratorHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var channelActivityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var collectionViewHeightcCons: NSLayoutConstraint!
    
    weak var beepDetailVCDelegate: BeepDetailVCDelegate!
    weak var tabBarDelegate: TabBarDelegate!
    weak var delegte: AllTagVCDelegate!
    weak var likesVCDelegate: LikesVCDelegate!
    weak var channelUpdateDelegate: ChannelUpdatesVCDelegate!
    //let UnitID:String = "ca-app-pub-5591749860136044/4796317682"
    let UnitID:String = "ca-app-pub-3940256099942544/2934735716"
     var interstitial: GADInterstitial!
    var beepData: AnyObject!
    var hasTags: [String]!
    var tagHeight: CGFloat = 0
    var releatedBeepSize = 5
    var releatedData: [AnyObject] = [AnyObject]()
    var releatedChannels = [AnyObject]()
    var beepVCState = BeepVCState.None
    var isVideo: Bool = false
    var webV:UIWebView!
    var isNotBeepDetail = true
    var beepDimention = [CGFloat]()
    var readMoreLink = ""
    var size = 10
    var from = 0
    var selectedIndex: Int!
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: .white)
    var channelsMiniResults = [[String : AnyObject]]()
    var callOnceInbeepDetail = true
    
    
    
    
    //MARK:- View Life cycle
    //MARK:-
    override func viewDidLoad() {
        super.viewDidLoad()
        CommonFunctions.showLoader()
        self.tblView.isHidden = true
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        //Arvind
        // self.adMobView.isHidden = true
        
        // nitin
        self.spinner.color = CommonColors.globalRedColor()
        self.spinner.startAnimating()
        self.spinner.frame = CGRect(x:0,y: 0,width: SCREEN_WIDTH,height: 28)
        self.tblView.tableFooterView = spinner
        
        self.tblView.delegate = self
        self.tblView.dataSource = self
        
        if #available(iOS 10.0, *) {
            self.tblView.prefetchDataSource = self
        }
      
//            interstitial = GADInterstitial(adUnitID: "ca-app-pub-5591749860136044/2766719013")
        //        By: - Akshay
            interstitial = GADInterstitial(adUnitID: "ca-app-pub-3940256099942544/4411468910")
            let request = GADRequest()
          //  interstitial.load(request)
              self.interstitial.delegate = self
       
        
        adMobView.delegate = self
        bannerView(rootVC: self, view: adMobView) //Ads Data
        
        let tagsCollectionCellXIB = UINib(nibName: "TagsCollectionCellXIB", bundle: nil)
        self.collectionView.register(tagsCollectionCellXIB, forCellWithReuseIdentifier: "TagsCollectionCellXIB")
        
        let userDataCell = UINib(nibName: "UserDataCell", bundle: nil)
        self.tblView.register(userDataCell, forCellReuseIdentifier: "UserDataCell")
        
        let releatedChannelCell = UINib(nibName: "ReleatedChannelCell", bundle: nil)
        self.tblView.register(releatedChannelCell, forCellReuseIdentifier: "ReleatedChannelCell")
        
        let taggedChannelFanCell = UINib(nibName: "TaggedChannelFanCell", bundle: nil)
        self.tblView.register(taggedChannelFanCell, forCellReuseIdentifier: "TaggedChannelFanCell")
        
        let fanClubeCell = UINib(nibName: "FanCellXIB", bundle: nil)
        self.tblView.register(fanClubeCell, forCellReuseIdentifier: "FanCellXIB")
        
        
        //self.getReleatedBeepData()
        self.collectionViewHeightcCons.constant = 0
        self.channelActivityIndicatorView.color = UIColor.red // nitin
        self.channelActivityIndicatorView.startAnimating()
        self.channelActivityIndicatorView.isHidden = true
        
//        if let PostTime = beep["postTime"] as? String {
//            print_debug(object: PostTime)
//        }
        
        var delayTime: Double = 2.3//1.9
        if let meta = self.beepData["meta"] as? [String : AnyObject] {
            if let beepMedia = meta["beepMedia"] as? [AnyObject] {
                
                if beepMedia.count > 1 {
                    delayTime = 3//2.8
                }
            }
        }
        //self.getBeepDetail(id: channelId)
        CommonFunctions.delay(delay: delayTime, closure: {
            self.tblView.isHidden = false
            self.tblView.layoutIfNeeded()
            self.view.layoutIfNeeded()
            CommonFunctions.hideLoader()
        })
        //self.is3DTouchAvailable()
        self.tblView.allowsSelection = true
        
        Globals.setScreenName(screenName: "BeepDetail", screenClass: "BeepDetail")
        
        if let data = self.beepData as? SeeAllPhotosAndVideos { // changes Arvind for checking the type of model and dictionary
            self.collectionViewHeightcCons.constant = 75
             self.channelActivityIndicatorView.isHidden = false
            self.getChannelDetail(channelId: data.id )
        }
        else {
            print_debug(object: self.beepData)
            guard let beep = self.beepData["beep"] as? [String : AnyObject] else { return }
            //guard let channelId = beep["id"] as? String else { return }
            guard let channels = beep["channels"] as? [String] else { return }
            self.collectionViewHeightcCons.constant = 75
             self.channelActivityIndicatorView.isHidden = false
            self.getChannelDetail(channelId: channels.first ?? "")
        }
        
    }
    
    //ADS
    
    func bannerView(rootVC:UIViewController,view:UIView) {
        let height = UIApplication.shared.statusBarFrame.height
      self.adMobView.isHidden = false
        let bannerView = GADBannerView()
        bannerView.frame = view.frame
        bannerView.frame.size.height = view.frame.height - height
        bannerView.rootViewController = rootVC
        bannerView.adUnitID = self.UnitID

        view.addSubview(bannerView)

        bannerView.load(GADRequest())

    }
    
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        
        if interstitial.isReady {
            interstitial.present(fromRootViewController: self)
        } else {
            print("Ad wasn't ready")
        }
    }
    
    
    /// Tells the delegate an ad request failed.
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
        print("interstitial:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
    
    
    func is3DTouchAvailable(btn: UIButton) -> Bool {
        if #available(iOS 9, *) {
            if self.traitCollection.forceTouchCapability == UIForceTouchCapability.available {
                self.registerForPreviewing(with: self, sourceView: btn)
                return true
            } else { return false }
        } else { return false}
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        APP_DELEGATE.statusBarStyle = .lightContent
        if let data = self.beepData as? SeeAllPhotosAndVideos {
           self.getBeepDetail(id: data.id)
       
        } else {
     
            guard let beep = self.beepData["beep"] as? [String : AnyObject] else {
            if let id = self.beepData["id"] as? String {
                self.getBeepDetail(id: id)
            }
            return }
      
            guard let channelId = beep["id"] as? String else { return }
        self.getBeepDetail(id: channelId)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.webV != nil {
            self.webV = nil
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //MARK:- @IBAction, Selector &  method's
    //MARK:-
    @IBAction func backBtnTap(sender: UIButton) {
        
        switch self.beepVCState {
        case .AllTagVCState :
            if let dele = self.delegte {
                dele.fromChannelDetailDataReload(updateData: [self.beepData])
            }
            self.navigationController?.popViewController(animated: true)
        case .ChannelUpdateVCState :
            if let dele = self.channelUpdateDelegate {
                dele.fromChannelDetailDataReload(updateData: [self.beepData]) // nitin
            }
            self.navigationController?.popViewController(animated: true)
        case .BeepDetailVCState :
            //self.getReleatedBeepData()
            self.navigationController?.popViewController(animated: true)
            
        case .ExploreContentSearchStateVC :
            self.navigationController?.popViewController(animated: true)
            
        case .ProfileLikesBeep :
            if let dele = self.likesVCDelegate {
                dele.fromChannelDetailDataReload(updateData: [self.beepData])
            }
            self.navigationController?.popViewController(animated: true)
        case .BeepDetailVCRelatedState :
            if let dele = self.beepDetailVCDelegate {
                dele.updateData(data: self.beepData)
            }
            self.navigationController?.popViewController(animated: true)
        default:
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func searchBtnTap(sender: UIButton) {
    }
    
    func displayShareSheet(shareContent: String, beepId: String, cell: UserDataCell) {
        
        let activityVC = UIActivityViewController(activityItems: [shareContent as NSString], applicationActivities: nil)
        
        activityVC.completionWithItemsHandler = { activity, success, items, error in
            
            if !success{
                print("cancelled")
                return
            } else {
                
                guard let currentBeep = self.beepData["beep"] as? [String : AnyObject] else { return }
                guard let currentMeta = self.beepData["meta"] as? [String : AnyObject] else { return }
                var tempBeep = currentBeep
                let tempMeta = currentMeta
                
                let count = currentBeep["countShares"] as? Int ?? 0
                
                tempBeep["countShares"] = count + 1 as AnyObject
                
                var data = [String:AnyObject]()
                data["beep"] = tempBeep as AnyObject
                data["meta"] = tempMeta as AnyObject
                self.beepData = data as AnyObject
                self.shareBeep(beepId: beepId)
                self.cellUpdateAfterLike(cell: cell)
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
    
    func channelViewTap(img: UIGestureRecognizer) {
        //if !self.isShowNext { return }
        let currentIndexPath = img.view!.tableViewIndexPath(tableView: self.tblView)
        var channelID = ""
        if currentIndexPath?.section == 0 {
            guard let beep = self.beepData["beep"] as? [String : AnyObject] else { return }
            guard let channel = beep["channels"] as? [String] else { return }
            if let channelid = channel.first {
                channelID = channelid
            }
            
        } else {
            guard let row = currentIndexPath?.row else { return }
            guard let beep = self.releatedData[row]["beep"] as? [String : AnyObject] else { return }
            guard let channel = beep["channels"] as? [String] else { return }
            if let channelid = channel.first {
                channelID = channelid
            }
        }
        if channelID.isEmpty { return }
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier:"ChannelViewFanVC") as! ChannelViewFanVC
        if let dele = self.tabBarDelegate {
            vc.delegate = dele
        }
        vc.channelViewFanVCState = ChannelViewFanVCState.BeepDetailVC
        vc.channelId = channelID
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func readMoreBtnTap(sender: UIButton) {
        
        
        if self.readMoreLink.isEmpty || !APP_DELEGATE.canOpenURL(NSURL(string: self.readMoreLink)! as URL) {
            CommonFunctions.showInfoAlert(title: "", msg: CommonTexts.READ_MORE_DATA_NOT_FOUND)
            return
        }
        
        if #available(iOS 9.0, *) {
            let safariVC = SFSafariViewController(url: URL(string: self.readMoreLink)!)
            self.present(safariVC, animated: true, completion: {
                APP_DELEGATE.statusBarStyle = .default
            })
        } else {
            let webViewVC = self.storyboard?.instantiateViewController(withIdentifier:"WebViewVC") as! WebViewVC
            webViewVC.urlString = self.readMoreLink
            self.present(webViewVC, animated: true, completion: {
                APP_DELEGATE.statusBarStyle = .default
            })
        }
        
        /*
         if let beep = self.beepData["beep"] as? [String : AnyObject] {
         if let source = beep["source"] as? [String : AnyObject] {
         if let sourceHost = source["link"] as? String {
         
         }
         }
         }*/
        
    }
    
    // nitin
    func releatedBeepViewTap(img: UIGestureRecognizer) {
        
        //guard let beeps = self.releatedData.first as? [String : AnyObject] else { return }
        //guard let beep = beeps["beep"] as? [String : AnyObject] else { return }
        //guard let beepID = beep["id"] as? String else { return }
        
        //if !self.isShowNext { return }
        
        let currentIndexPath = img.view!.tableViewIndexPath(tableView: self.tblView)
        guard let row = currentIndexPath?.row, currentIndexPath?.section == 2 else { return }
        
        self.showBeepDetail(row: row)
        
        
    }
    
    // nitin
    
    func showBeepDetail(row : Int) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier:"BeepDetailVC") as! BeepDetailVC
        vc.beepDetailVCDelegate = self
        self.selectedIndex = row
        self.setVCData(vc: vc, row: row)
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func setVCData(vc: BeepDetailVC, row: Int) {
        
        //vc.isShowNext = false
        if let dele = self.tabBarDelegate {
            vc.tabBarDelegate = dele
        }
        if let dele = self.delegte {
            vc.delegte = dele
        }
        if let dele = self.channelUpdateDelegate {
            vc.channelUpdateDelegate = dele
        }
        
        vc.beepVCState = BeepVCState.BeepDetailVCRelatedState
        guard let beeps = self.releatedData[row] as? [String : AnyObject] else { return }
        guard let beep = beeps["beep"] as? [String : AnyObject] else { return }
        guard let hashtags = beep["hashtags"] as? [String] else { return }
        vc.beepData = beeps as AnyObject
        
        var arr = [String]()
        _ = hashtags.map({ (temp: String) in
            arr.append("#\(temp)")
        })
        vc.hasTags = arr
        vc.tagHeight = self.calculatetTagHeight(tempTag: NSMutableArray(array: arr))
        
    }
    
    // nitin
    func calculatetTagHeight(tempTag: NSMutableArray)-> CGFloat {
        
        if tempTag.count == 0 {
            return 0.0
        }
        
        var tagWidth: CGFloat = 10 + 10
        var line  = 1
        var finalHeight: CGFloat = 0
        
        let array = tempTag
        var counter = 1
        _  = array.map({ (temp) in
            
            let frame = CommonFunctions.getTextHeightWdith(param: temp as? String ?? "", font : CommonFonts.SFUIText_Medium(setsize: 15.5))
            tagWidth = tagWidth + frame.width
            tagWidth = tagWidth + 10
            
            if tagWidth >= (SCREEN_WIDTH - 20) {
                tagWidth = 10 + 10
                line = line + 1
            } else if frame.width >= (SCREEN_WIDTH - 50)  {
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
            
            counter += 1
        })
        
        let totalLineWidth = line * 24
        let totalLinseSpaceWidth = line * 4
        finalHeight = CGFloat(totalLineWidth + totalLinseSpaceWidth)
        print_debug(object: "finalHeight")
        print_debug(object: finalHeight)
        return finalHeight
    }
    
    // nitin
    func getHostName() -> String {
        let urlString = self.readMoreLink
        let url = NSURL(string: urlString)
        return  url?.host ?? ""
    }
    
    func tapOnTag(str: String) {
        
        if let dele = TABBARDELEGATE {
            dele.tagBtnTap(tag: str, state: SetExploreVCDataState.Content)
        } else {
            print("Delegate not found.")
        }
        /*
         APP_DELEGATE.statusBarStyle = UIStatusBarStyle.default
         let exploreContentSearchVC = self.storyboard?.instantiateViewController(withIdentifier:"ExploreContentSearchVC") as! ExploreContentSearchVC
         exploreContentSearchVC.exploreContentSearchState = ExploreContentSearchState.None
         
         self.navigationController?.pushViewController(exploreContentSearchVC, animated: true)
         */
        
    }
    
    func likeBtnTap(sender:UIButton) {
        
        guard CommonFunctions.checkLogin() else {
            CommonFunctions.showLoginAlert(vc: self)
            
            return
        }
        
        guard let currentIndexPath = sender.tableViewIndexPath(tableView: self.tblView), currentIndexPath.section == 0  else { return }
        guard let currentBeep = self.beepData["beep"] as? [String : AnyObject] else { return }
        guard let currentMeta = self.beepData["meta"] as? [String : AnyObject] else { return }
        var tempBeep = currentBeep
        var tempMeta = currentMeta
        let cell = self.tblView.cellForRow(at: currentIndexPath) as! UserDataCell
        var beepid = ""
        if let beep = self.beepData["beep"] as? [String : AnyObject] {
            
            if let id = beep["id"] as? String {
                
                beepid = id
                
            }
        }
        
        
        var count = currentBeep["countLikes"] as? Int ?? 0
        
        //tempBeep["countShares"] = count + 1
        if !sender.isSelected {
            count = count + 1
            cell.likeCountLbl.text = "\(count)"
            //cell.likeBtn.likeBounce(0.0)
            cell.likeBtn.animate()
            
            sender.isSelected = true
            tempMeta["userLiked"] = true as AnyObject
            self.likeBeep(beepid: beepid, flag: true)
           /* if let source = currentBeep["source"] as? [String : AnyObject] {
                if let sourceHost = source["user"] as? String, !sourceHost.isEmpty {
                    self.showSharePopup(name: sourceHost)
                }
                else if let sourceHost = source["host"] as? String {
                    var sourceData: (sourceName: String, sourceImg: UIImage, channelImage: UIImage)!
                    sourceData = CommonFunctions.checkSourceType(str: sourceHost)
                    self.showSharePopup(name: sourceData.sourceName)
                }
            }*/
            
        } else{
            if count > 0 {
                count = count - 1
                cell.likeCountLbl.text = "\(count)"
                sender.isSelected = false
                tempMeta["userLiked"] = false as AnyObject
                self.likeBeep(beepid: beepid, flag: false)
            }
        }
        tempBeep["countLikes"] = count as AnyObject
        var data = [String:AnyObject]()
        data["beep"] = tempBeep as AnyObject
        data["meta"] = tempMeta as AnyObject
        self.beepData = data as AnyObject
        self.tblView.reloadSections(NSIndexSet(index: 0) as IndexSet, with: .none)
        //self.cellUpdateAfterLike(cell)
    }
    
    func chatBtnTap(sender:UIButton) {
        
        guard CommonFunctions.checkLogin() else {
            CommonFunctions.showLoginAlert(vc: self)
            return
        }
        
        guard let currentIndexPath = sender.tableViewIndexPath(tableView: self.tblView) else { return }
        var beep = [String : AnyObject]()
        if currentIndexPath.section == 0 {
            guard let tempBeep = self.beepData["beep"] as? [String : AnyObject] else { return }
            beep = tempBeep
        } else {
            guard let tempBeep = self.releatedData[currentIndexPath.row]["beep"] as? [String : AnyObject] else { return }
            beep = tempBeep
        }
      
        guard let channel = beep["channels"] as? [String] else { return }
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
        
        
        
        //Previous
        //==========================
//        guard let channel = beep["channels"] as? [String] else { return }
//        if let channelID = channel.first {
//
//            let vc = self.storyboard?.instantiateViewController(withIdentifier:"ChannelViewFanVC") as! ChannelViewFanVC
//            if let dele = self.tabBarDelegate {
//                vc.delegate = dele
//            }
//            vc.channelViewFanVCState = ChannelViewFanVCState.None
//            vc.channelId = channelID
//            vc.isChat = true
//            self.navigationController?.pushViewController(vc, animated: true)
//        }
 
    }
    
    func shareBtnTap(sender:UIButton) {
        
        //        guard CommonFunctions.checkLogin() else {
        //            CommonFunctions.showLoginAlert(vc: self)
        //            return
        //        }
        
        guard let currentIndexPath = sender.tableViewIndexPath(tableView: self.tblView), currentIndexPath.section == 0 else { return }
        guard let currentBeep = self.beepData["beep"] as? [String : AnyObject] else { return }
        guard let currentMeta = self.beepData["meta"] as? [String : AnyObject] else { return }
        var tempBeep = currentBeep
        guard let cell = self.tblView.cellForRow(at: currentIndexPath) as? UserDataCell  else { return }
        if let beep = self.beepData["beep"] as? [String : AnyObject] {
            
            if let id = beep["id"] as? String {
                
                let url =  SHARE_BEEP_URL + id
                self.displayShareSheet(shareContent: url, beepId: id, cell: cell)
                
                tempBeep["countShares"] = beep["countShares"] as? Int as AnyObject
            }
        }
        //tempBeep["countShares"] = Int(cell.likeCountLbl.text!)
        var data = [String:AnyObject]()
        data["beep"] = tempBeep as AnyObject
        data["meta"] = currentMeta as AnyObject
        self.beepData = data as AnyObject
    }
    
    func cellUpdateAfterLike(cell: UserDataCell) {
        
        guard let beep = self.beepData["beep"] as? [String : AnyObject] else { return }
        
        var counters = (like: 0, share: 0)
        if let countLikes = beep["countLikes"] as? Int {
            counters.like = countLikes
        }
        
        if let countShares = beep["countShares"] as? Int {
            counters.share = countShares
        }
        
        
        if counters.like == 0 && counters.share == 0 {
            //cell.likeContainerHeightCons.constant   = 0
            cell.shareTextLbl.text = ""
            cell.likeTextLbl.text = ""
            cell.showlikeContainerView.isHidden = true
        } else {
            
            //cell.likeContainerHeightCons.constant = 16
            cell.seondDotView.isHidden = true
            cell.showlikeContainerView.isHidden = false
            
            if counters.like == 0 && counters.share != 0 {
                
                cell.likeTextLbl.text = counters.share > 1 ? "Shares" : "Share"
                cell.likeCountLbl.text = "\( counters.share )"
                
                cell.shareTextLbl.text = ""
                cell.shareCountLbl.text = ""
                
            } else {
                
                cell.likeTextLbl.text = counters.like > 1 ? "Likes" : "Like"
                cell.likeCountLbl.text = "\( counters.like )"
                
                if counters.share == 0 {
                    cell.shareTextLbl.text = ""
                    cell.shareCountLbl.text = ""
                    
                } else {
                    cell.shareTextLbl.text = counters.share > 1 ? "Shares" : "Share"
                    cell.shareCountLbl.text = "\( counters.share )"
                    cell.seondDotView.isHidden = false
                }
                
            }
            
        }
        
    }
    
    func relatedLikeBtnTap(sender:UIButton) {
        
        guard CommonFunctions.checkLogin() else {
            CommonFunctions.showLoginAlert(vc: self)
            return
        }
        
        guard let currentIndexPath = sender.tableViewIndexPath(tableView: self.tblView), currentIndexPath.section == 2 else { return }
        guard let cell = self.tblView.cellForRow(at: currentIndexPath) as? UserDataCell else { return }
        guard let beep = self.releatedData[currentIndexPath.row]["beep"] as? [String : AnyObject] else { return }
        guard let meta = self.releatedData[currentIndexPath.row]["meta"] as? [String : AnyObject] else { return }
        var beepid = ""
        if let id = beep["id"] as? String {
            beepid = id
        }
        
        var count = beep["countLikes"] as? Int ?? 0
        if !sender.isSelected {
            count = count + 1
            cell.likeCountLbl.text = "\(count)"
            
            cell.likeBtn.likeBounce(0.0)
            cell.likeBtn.animate()
            
            sender.isSelected = true
            var data = [String:AnyObject]()
            var tempBeep = beep
            var tempMeta = meta
            if var countLikes = beep["countLikes"] as? Int {
                countLikes =  countLikes + 1
                tempBeep["countLikes"] = countLikes as AnyObject
                
                data["beep"] = tempBeep as AnyObject
                self.releatedData[currentIndexPath.row] = data as AnyObject
            }
            if var isLike = meta["userLiked"] as? Bool {
                isLike = true
                tempMeta["userLiked"] = isLike as AnyObject
                
                data["meta"] = tempMeta as AnyObject
                self.releatedData[currentIndexPath.row] = data as AnyObject
            }
            self.likeBeep(beepid: beepid, flag: true)
          /*  if let source = beep["source"] as? [String : AnyObject] {
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
            if count > 0 {
                count = count - 1
                cell.likeCountLbl.text = "\(count)"
                
                sender.isSelected = false
                var data = [String:AnyObject]()
                var tempBeep = beep
                var tempMeta = meta
                if var countLikes = beep["countLikes"] as? Int {
                    countLikes =  countLikes - 1
                    tempBeep["countLikes"] = countLikes as AnyObject
                    
                    data["beep"] = tempBeep as AnyObject
                    self.releatedData[currentIndexPath.row] = data as AnyObject
                }
                if var isLike = meta["userLiked"] as? Bool {
                    isLike = false
                    tempMeta["userLiked"] = isLike as AnyObject
                    
                    data["meta"] = tempMeta as AnyObject
                    self.releatedData[currentIndexPath.row] = data as AnyObject
                }
                self.likeBeep(beepid: beepid, flag: false)
            }
        }
        
        self.tblView.reloadRows(at: [IndexPath(row: currentIndexPath.row, section: currentIndexPath.section)], with: .none)
        
    }
    
    
    func relatedShareBtnTap(sender:UIButton) {
        
        //        guard CommonFunctions.checkLogin() else {
        //            CommonFunctions.showLoginAlert(vc: self)
        //            return
        //        }
        
        guard let currentIndexPath = sender.tableViewIndexPath(tableView: self.tblView), currentIndexPath.section == 2 else { return }
        let cell = self.tblView.cellForRow(at: currentIndexPath) as! UserDataCell
        if let beep = self.releatedData[currentIndexPath.row]["beep"] as? [String : AnyObject] {
            
            if let id = beep["id"] as? String {
                
                let url =  SHARE_BEEP_URL + id
                self.relatedBeepDisplayShareSheet(shareContent: url, beepId: id, cell: cell, row: currentIndexPath.row)
                
            }
        }
        
    }
    
    func relatedBeepDisplayShareSheet(shareContent: String, beepId: String, cell: UserDataCell, row: Int) {
        
        let activityVC = UIActivityViewController(activityItems: [shareContent as NSString], applicationActivities: nil)
        
        activityVC.completionWithItemsHandler = { activity, success, items, error in
            
            if !success{
                print("cancelled")
                return
            } else {
                
                guard let beep = self.releatedData[row]["beep"] as? [String : AnyObject] else { return }
                guard let meta = self.releatedData[row]["meta"] as? [String : AnyObject] else { return }
                var tempBeep = beep
                if var countShares = beep["countShares"] as? Int {
                    countShares =  countShares + 1
                    cell.shareCountLbl.text = "\(countShares)"
                    tempBeep["countShares"] = countShares as AnyObject
                    var data = [String:AnyObject]()
                    data["beep"] = tempBeep as AnyObject
                    data["meta"] = meta as AnyObject
                    self.releatedData[row] = data as AnyObject
                }
                self.shareBeep(beepId: beepId)
                self.tblView.reloadRows(at: [IndexPath(row: row, section: 2)], with: .none)
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
    
    // nitin
    func showTagInSearchChannel(tag :String) {
        let vc = self.storyboard!.instantiateViewController(withIdentifier:"ExploreContentVC") as! ExploreContentVC
        vc.exploreContentVCState = .TagsSearch
        vc.view.backgroundColor = UIColor.white
        let navVC = UINavigationController(rootViewController: vc)
        navVC.navigationBar.isHidden = true
        self.present(navVC, animated: true) {
            APP_DELEGATE.statusBarStyle = UIStatusBarStyle.default
        }
        CommonFunctions.delay(delay: 0.2) {
            vc.contentSearchText = tag.replace(string: "#", replacement: "")
            vc.searchBar.text = tag.replace(string: "#", replacement: "")
            vc.searchContentText(text: tag.replace(string: "#", replacement: ""))
        }
        
    }
    
    func fanBtnTap(sender: UIButton) {
        
        guard CommonFunctions.checkLogin() else {
            CommonFunctions.showLoginAlert(vc: self)
            return
        }
        let currentRow = sender.tableViewIndexPath(tableView: self.tblView)!.row
        
        print_debug(object: currentRow)
        
        print_debug(object: self.channelsMiniResults[currentRow])
        
        guard let channelID = self.channelsMiniResults[currentRow]["id"] as? String else { return }
        if !sender.isSelected {
            print_debug(object: "oN")
            CommonFunctions.fanBtnOnFormatting(btn: sender)
            //sender.setTitleColor(UIColor.white, for:  .Selected)
            self.followChannel(channelId: channelID, follow: true)
            self.showSharePopup(name: self.channelsMiniResults[currentRow]["name"]  as? String ?? "")
        } else {
            print_debug(object: "oFF")
            CommonFunctions.fanBtnOffFormatting(btn: sender)
            //sender.setTitleColor(CommonColors.fanlblTextColor(), for:  .Selected)
            self.followChannel(channelId: channelID, follow: false)
        }
        
        sender.isSelected = !sender.isSelected
        
        /*
         let indexPath = sender.tableViewIndexPath(tableView: self.tblView)!
         
         guard let selectedChannel = self.searchArray[indexPath.row] as? AnyObject else { return }
         guard let channelID = selectedChannel["id"] as? String else { return }
         if let deleg = self.endEditingDelegate {
         deleg.searchBarEditing(true)
         }
         if let dele = self.delegate {
         //CommonFunctions.hideKeyboard()
         dele.exploreChannel(channelID, searchStr: self.channelSearchText, state: false)
         
         print_debug(object: channelID)
         }
         
         */
        /*CommonFunctions.hideKeyboard()
         let vc = self.storyboard?.instantiateViewController(withIdentifier:"ChannelViewFanVC") as! ChannelViewFanVC
         self.navigationController?.pushViewController(vc, animated: true)
         */
        
        /*
         let indexPath = sender.tableViewIndexPath(tableView: self.tblView)!
         print(indexPath.row)
         if let data  = self.searchArray[indexPath.row] as? [String: AnyObject] {
         
         if let id = data["id"] as? String {
         
         print(id)
         }
         }
         
         print("INfo TAbl")*/
    }
    
    func flagBtnTap(sender: UIButton) {
        
        //        guard CommonFunctions.checkLogin() else {
        //            CommonFunctions.showLoginAlert(vc: self)
        //            return
        //        }
        
        guard let currentIndexPath = sender.tableViewIndexPath(tableView: self.tblView) else { return }
        
        var beepId = ""
        if currentIndexPath.section == 0 {
            
            guard let beep = self.beepData["beep"] as? [String : AnyObject], let id = beep["id"] as? String else  { return}
            beepId = id
        } else {
            
            guard let beep = self.releatedData[currentIndexPath.row]["beep"] as? [String : AnyObject], let id = beep["id"] as? String else  { return}
            beepId = id
        }
        
        
        
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        
        let reportAction = UIAlertAction(title: "Report this content", style: .default, handler: {
            
            (alert: UIAlertAction!) -> Void in
            
            let optionMenu = UIAlertController(title: CommonTexts.FlagThisBeep, message: nil, preferredStyle: .alert)
            
            let yesAction = UIAlertAction(title: "Yes", style: .default, handler: {
                
                (alert: UIAlertAction!) -> Void in
                
                self.flagBeep(beepId: beepId, index: currentIndexPath.row)
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
    
    @IBAction func reportButtonTap(_ sender: Any) {
        
        
        var beepId = ""
        
        guard let beep = self.beepData["beep"] as? [String : AnyObject], let id = beep["id"] as? String else  { return}
        beepId = id
        
        
        
        
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        
        let reportAction = UIAlertAction(title: "Report this content", style: .default, handler: {
            
            (alert: UIAlertAction!) -> Void in
            
            let optionMenu = UIAlertController(title: CommonTexts.FlagThisBeep, message: nil, preferredStyle: .alert)
            
            let yesAction = UIAlertAction(title: "Yes", style: .default, handler: {
                
                (alert: UIAlertAction!) -> Void in
                
                self.flagBeep(beepId: beepId, index: 0)
                //self.reportUser(userId: uID)
            })
            
            let noAction = UIAlertAction(title: "No", style: .destructive, handler: {
                
                (alert: UIAlertAction!) -> Void in
                
            })
            optionMenu.addAction(yesAction)
            optionMenu.addAction(noAction)
            
            self.present(optionMenu, animated: true, completion: nil)
            
        })
        
        let shareAction = UIAlertAction(title: "Share this post", style: .default, handler: {
            
            (alert: UIAlertAction!) -> Void in
            
            //            guard CommonFunctions.checkLogin() else {
            //                CommonFunctions.showLoginAlert(vc: self)
            //                return
            //            }
            
            guard let currentBeep = self.beepData["beep"] as? [String : AnyObject] else { return }
            guard let currentMeta = self.beepData["meta"] as? [String : AnyObject] else { return }
            var tempBeep = currentBeep
            guard let cell = self.tblView.cellForRow(at: IndexPath(row: 0, section: 0)) as? UserDataCell  else { return }
            if let beep = self.beepData["beep"] as? [String : AnyObject] {
                
                if let id = beep["id"] as? String {
                    
                    let url =  SHARE_BEEP_URL + id
                    self.displayShareSheet(shareContent: url, beepId: id, cell: cell)
                    
                    tempBeep["countShares"] = beep["countShares"] as? Int as AnyObject
                }
            }
            //tempBeep["countShares"] = Int(cell.likeCountLbl.text!)
            var data = [String:AnyObject]()
            data["beep"] = tempBeep as AnyObject
            data["meta"] = currentMeta as AnyObject
            self.beepData = data as AnyObject
            
            
        })
        
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            
            (alert: UIAlertAction!) -> Void in
            
            
        })
        
        optionMenu.addAction(shareAction)
        optionMenu.addAction(reportAction)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
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

extension BeepDetailVC: GADBannerViewDelegate{
  
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        self.adMobView.isHidden = false
        
    }
    
    /// Tells the delegate an ad request failed.
    func adView(_ bannerView: GADBannerView,
                didFailToReceiveAdWithError error: GADRequestError) {
        print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
    
    
}
//MARK:- UITableView Delegate & DataSource
//MARK:-
extension BeepDetailVC : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.releatedData.count > 0 && self.beepData != nil {
            
            return 3
        }
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print_debug(object: self.beepDimention.count)
        print_debug(object: self.releatedData.count)
        if section == 0 {
            return 1
        } else if section  == 1 {
            return self.channelsMiniResults.count
        }
        return self.releatedData.count
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return CGFloat.leastNormalMagnitude
        } else if section == 1 {
            return self.channelsMiniResults.count > 0 ? 30 :  CGFloat.leastNormalMagnitude
        }
        return 30
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 0 {
            
            
            var titleStr = ""
            var textData = ""
            if let beep = self.beepData["beep"] as? [String : AnyObject] {
                if let title = beep["title"] as? String {
                    titleStr = title
                }
                if let text = beep["text"] as? String {
                    textData = text
                }
            }
            self.tagHeight = self.calculatetTagHeight(tempTag: NSMutableArray(array: self.hasTags))
            let tileHeight   = CommonFunctions.getTextHeightWdith(param: titleStr, font : CommonFonts.SFUIText_Medium(setsize: 15.5)).height
            let textHeight   = CommonFunctions.getTextHeightWdith(param: textData, font : CommonFonts.SFUIText_Regular(setsize: 15)).height
            
            var readMoreHeight : CGFloat = 16.0 + (self.tagHeight > 0.0 ? 8.0 : 0.0)
            
            // nitin
            if !self.readMoreLink.isEmpty {
                var additinalPadding : CGFloat = 10.0
                if let beep = self.beepData["beep"] as? [String : AnyObject] {
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
                    if counters.like != 0 || counters.share != 0 || counters.views != 0{
                        additinalPadding = 12.0
                    }
                }
                readMoreHeight   = CommonFunctions.getTextHeightWdith(param: self.getHostName(), font : CommonFonts.SFUIText_Regular(setsize: 14)).height + 22.0 + 16.0 + additinalPadding
            }
            
            if textData.isEmpty {
                readMoreHeight = readMoreHeight - 16.0
            }
            
            if let meta = self.beepData["meta"] as? [String : AnyObject] {
                if let tempBeepMedia = meta["beepMedia"] as? [AnyObject] {
                    
                    if tempBeepMedia.count  == 1 {
                        
                        if self.beepIsVideo(beeps: tempBeepMedia) {
                            return 145 + self.dynamicHeightSetup() + tileHeight + self.tagHeight + textHeight + readMoreHeight
                        } else {
                            return 145 + self.dynamicHeightSetup() + tileHeight + self.tagHeight + textHeight + readMoreHeight
                        }
                        
                    } else {
                        return 145 + self.dynamicHeightSetup() + tileHeight + self.tagHeight + textHeight + readMoreHeight
                        //return 325 + tileHeight + self.tagHeight + textHeight
                    }
                }
            }
            let height = tileHeight + self.tagHeight + textHeight + readMoreHeight
            return 145 + self.dynamicHeightSetup() + height
            
        } else if indexPath.section == 1 {
            return 55
        }else  {
            
            if self.releatedData.count > 0 {
                
                var descriptionHeight: CGFloat  = 0
                if let meta = self.releatedData[indexPath.row]["meta"] as? [String : AnyObject] {
                    if let summary = meta["summary"] as? String{
                        descriptionHeight = CommonFunctions.getTextHeightWdith(param: summary, font : CommonFonts.SFUIText_Medium(setsize: 14.5)).height
                    } else {
                        descriptionHeight = 0
                    }
                } else {
                    descriptionHeight = 0
                }
                let height = 145 + self.beepDimention[indexPath.row] + 12 + descriptionHeight
                
                var counters = (like: 0, share: 0, views: 0)
                if let beep = self.releatedData[indexPath.row]["beep"] as? [String : AnyObject] {
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
                    return (height - 12)
                } else {
                    return height
                }
                
            } else {
                return 0
            }
            
            //return self.beepDimention[indexPath.row] + 10 + 10 + 60
            
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 0 {
            return  nil
        }
        let view = UIView()
        view.backgroundColor = UIColor.white
        let lbl = UILabel(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 30))
        lbl.backgroundColor = UIColor.lightGray.withAlphaComponent(0.7)
        lbl.textColor = UIColor.darkGray
        lbl.font = CommonFonts.SFUIText_Bold(setsize: 14)
        if section == 1 {
            lbl.text = CommonTexts.Tagged_Channels
        } else {
            lbl.text = CommonTexts.RELEATED_TEXT
        }
        
        lbl.textAlignment = NSTextAlignment.center
        view.addSubview(lbl)
        return view
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "UserDataCell", for:  indexPath) as! UserDataCell
            self.setTableViewData(cell: cell, indexPath: indexPath)
            cell.tagContainerViewHeightConstraint.constant = self.tagHeight
            cell.tagContainerView.tagSelectedTextColor = CommonColors.lightGrayColor()
            cell.tagsContainerTopConstraints.constant = (self.tagHeight > 0.0 ? 8.0 : 2.0)
            
            cell.tagContainerView.tags.removeAllObjects()
            cell.tagContainerView.tags.addObjects(from: self.hasTags as [AnyObject])
            cell.tagContainerView.setCompletionBlockWithSelected { (val: Int) in
                // nitin
                if let tag = cell.tagContainerView.tags.object(at: val) as? String {
                    self.showTagInSearchChannel(tag: tag)
                }
                
                if self.beepVCState == BeepVCState.ExploreContentSearchStateVC {
                    //return
                }
                if let tagStr = cell.tagContainerView.selectedTags.firstObject as? String {
                    print(tagStr)
                    //self.tapOnTag(tagStr)
                }
            }
            
            cell.tagContainerView.collectionView.reloadData()
            
            //cell.tapView.addGestureRecognizer(nil)
            
            if let meta = self.beepData["meta"] as? [String : AnyObject] {
                if let beepMedia = meta["beepMedia"] as? [AnyObject] {
                    
                    print_debug(object: beepMedia.count)
                    cell.pageController.numberOfPages = beepMedia.count
                    cell.updatePageControl()
                    cell.beepMedia = beepMedia
                    cell.moreCount = beepMedia.count
                    cell.imgCollectionView.isPagingEnabled = true
                    print_debug(object: beepMedia.count)
                    print_debug(object: beepMedia)
                    if cell.moreCount > 1 {
                        cell.pageController.isHidden = false
                        cell.imgCollectionView.isScrollEnabled = true
                        cell.singleBeepHeightCons = SCREEN_WIDTH
                        cell.imgCollectionViewHeightCons.constant = self.dynamicHeightSetup()//((SCREEN_WIDTH*75)/100) //SCREEN_WIDTH //500//182
                        
                    } else {
                        cell.pageController.isHidden = true
                        cell.imgCollectionView.isScrollEnabled = false
                        
                        if self.beepIsVideo(beeps: beepMedia) {
                            cell.imgCollectionViewHeightCons.constant = self.dynamicHeightSetup() //(SCREEN_WIDTH*75)/100
                            cell.singleBeepHeightCons  = self.dynamicHeightSetup() //(SCREEN_WIDTH*75)/100
                        } else {
                            cell.imgCollectionViewHeightCons.constant = self.dynamicHeightSetup()
                            cell.singleBeepHeightCons  = self.dynamicHeightSetup()
                        }
                    }
                }
            }
            
            cell.isNotBeepDetail = false
            cell.configureCellForBeepDetail()
            cell.imgCollectionView.reloadData()
            cell.likeBtn.addTarget(self, action: #selector(BeepDetailVC.likeBtnTap(sender:)), for: .touchUpInside)
            cell.chatBtn.addTarget(self, action: #selector(BeepDetailVC.chatBtnTap(sender:)), for: .touchUpInside)
            cell.shareBtn.addTarget(self, action: #selector(BeepDetailVC.shareBtnTap(sender:)), for: .touchUpInside)
            cell.flagButton.addTarget(self, action: #selector(BeepDetailVC.flagBtnTap(sender:)), for: UIControlEvents.touchUpInside)
            cell.flagButton.isHidden = true
            
            let imageViewTap = UITapGestureRecognizer(target:self, action:#selector(self.releatedBeepViewTap(img:)))
            cell.tapView.isUserInteractionEnabled = true
            cell.tapView.addGestureRecognizer(imageViewTap)
            
            //channelDetails
            let channelViewTap = UITapGestureRecognizer(target:self, action:#selector(BeepDetailVC.channelViewTap(img:)))
            cell.providerDescContainerView.isUserInteractionEnabled = true
            cell.providerDescContainerView.addGestureRecognizer(channelViewTap)
            
            cell.readMoreBtn.isHidden = false
            cell.readMoreBtn.addTarget(self, action: #selector(BeepDetailVC.readMoreBtnTap(sender:)), for: .touchUpInside)
            if !self.readMoreLink.isEmpty {
                var additinalPadding : CGFloat = 0.0
                if let beep = self.beepData["beep"] as? [String : AnyObject] {
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
                    if counters.like != 0 || counters.share != 0 || counters.views != 0{
                        additinalPadding = 8.0
                    }
                }
                cell.likeContainerTopCons.constant = 16.0 + CommonFunctions.getTextHeightWdith(param: self.getHostName(), font : CommonFonts.SFUIText_Regular(setsize: 14)).height + 22.0 + additinalPadding
                
            }
            cell.showlikeContainerView.layoutIfNeeded()
            cell.readMoreHostName.text = self.getHostName()
            cell.pageController.currentPage = 0
            cell.imgCollectionView.isHidden = false
            return cell
            
        } else if indexPath.section == 1{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "TaggedChannelFanCell", for:  indexPath) as!
            TaggedChannelFanCell
            cell.isUserInteractionEnabled = true
//            cell.bottomView.backgroundColor = CommonColors.sepratorColor()
            cell.fanBtnSetup()
            //cell.infoBtn.isUserInteractionEnabled = true
            cell.infoBtn.addTarget(self, action: #selector(self.fanBtnTap(sender:)), for: .touchUpInside)
            
             let data  = self.channelsMiniResults[indexPath.row]
            
            print_debug(object: data)
            
                if let pic = data["avatarURL"] as? String {
                    
                    cell.imgView.sd_setImage(with: URL(string: pic), placeholderImage: CHANNELLOGOPLACEHOLDER)
                    cell.imgView.contentMode = .scaleToFill
                    cell.imgView.clipsToBounds = true
                    
                }
                //cell.imgView.image = UIImage(named: "dp1")
                
                if let name = data["name"] as? String {
                    cell.nameLbl.text = name
                }
            
            if let displayLabels = data["displayLabels"] as? [String] {
                let displayLblStr = displayLabels.joined(separator: ",")
                cell.infoLbl.text = displayLblStr
            }

            
            if let countFollowers = data["countFollowers"] as? Int, countFollowers > 0  {
                
                if countFollowers == 1{
                    
                    cell.fanCountLbl.text = "\(countFollowers) Fan"

                }else{
                    
                    cell.fanCountLbl.text = "\(countFollowers) Fans"

                }
            }else{
                
                cell.fanCountLbl.text = "Be the 1st Fan"
            }

            
                if let currentCellFanId  = data["id"]  as? String {
                    if let list = UserDefaults.getStringArrayVal(key: NSUserDefaultKeys.FRIENDSLIST) as? [String] {
                        print_debug(object: "List Id : \(list)")
                        print_debug(object: "current cell Id : \(currentCellFanId)")
                        for temp in list{
                            print_debug(object: "temp Id : \(temp)")
                            if temp == currentCellFanId {
                                CommonFunctions.fanBtnOnFormatting(btn: cell.infoBtn)
                                cell.infoBtn.isSelected = true
                                break
                            } else {
                                CommonFunctions.fanBtnOffFormatting(btn: cell.infoBtn)
                                cell.infoBtn.isSelected = false
                            }
                        }
                        
                    } else {
                        CommonFunctions.fanBtnOffFormatting(btn: cell.infoBtn)
                        cell.infoBtn.isSelected = false
                    }
                    
                    if let status = data["isUserFan"] as? Bool, status == true {
                        CommonFunctions.fanBtnOnFormatting(btn: cell.infoBtn)
                        cell.infoBtn.isSelected = true
                    }
                    
                } else {
                    CommonFunctions.fanBtnOffFormatting(btn: cell.infoBtn)
                    cell.infoBtn.isSelected = false
                    
                }
                
                
            return cell
        }
        else  {  return self.userDataRelatedCellSetUp(tableView: tableView, indexPath: indexPath)}
        
    }
    
    
    // ntin
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 1 {
            
            
            if let data  = self.channelsMiniResults[indexPath.row ] as? [String: AnyObject] {
                if let channelId = data["id"] as? String {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier:"ChannelViewFanVC") as! ChannelViewFanVC
                    vc.channelViewFanVCState = ChannelViewFanVCState.AllTagVCChannelState
                    //                if let dele = ALLTAGVCDELEGATE {
                    //                    vc.allTagVCDelegate = dele
                    //                }
                    //
                    //                if let dele = TABBARDELEGATE {
                    //                    vc.delegate = dele
                    //                }
                    vc.channelId = channelId
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            
            
            
        }else if indexPath.section == 2 {
            
            self.showBeepDetail(row: indexPath.row )
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.row == self.releatedData.count-2  {
            if self.size != -1 {
                self.from = self.from+10
                self.getReleatedBeepData()
                self.spinner.startAnimating()
            } else {
                self.spinner.stopAnimating()
            }
        }
        
        
        
        cell.clipsToBounds = true
        cell.contentView.layoutIfNeeded()
        cell.layoutIfNeeded() // nitin
    }
    
    
    func setTableViewData(cell: UserDataCell, indexPath: IndexPath) {
        
        var sourceData: (sourceName: String, sourceImg: UIImage, channelImage: UIImage)!
        
        var textData = (beepSummery: "", metaSummery: "")
        if let meta = self.beepData["meta"] as? [String : AnyObject] {
            if let userLiked = meta["userLiked"] as? Bool {
                cell.likeBtn.isSelected = userLiked
            }
            
            //TODO ::
            if let tempBeepMedia = meta["beepMedia"] as? [AnyObject] {
                
                if tempBeepMedia.count  > 1 {
                    
                } else {
                    
                }
            }
            
            if let summary = meta["summary"] as? String {
                textData.metaSummery = summary
            }
            
        }
        
        if let beep = self.beepData["beep"] as? [String : AnyObject] {
            
            if let source = beep["source"] as? [String : AnyObject] {
                
                if let sourceHost = source["host"] as? String {
                    
                    sourceData = CommonFunctions.checkSourceType(str: sourceHost)
                }
                
                if let link = source["link"] as? String {
                    self.readMoreLink = link
                }
                
                
                if let sourceUser = source["user"] as? String {
                    if sourceUser.isEmpty {
                        cell.providerNameLbl.text = sourceData.sourceName
                        cell.logoImgeView.image = sourceData.channelImage
                        cell.newsTypeLogoImageView.image = sourceData.sourceImg
                    } else {
                        cell.providerNameLbl.text = sourceUser
                        cell.newsTypeLogoImageView.image = sourceData.sourceImg
                        if let sourceAvatar = source["avatar"] as? String {
                            cell.logoImgeView.sd_setImage(with: URL(string: sourceAvatar), placeholderImage: CHANNELLOGOPLACEHOLDER)
                        }
                    }
                }
            }
            
            if let title = beep["title"] as? String {
                cell.descriptionLbl.text = title
            }
            
            if let text = beep["text"] as? String {
                textData.beepSummery = text
            }
            
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
            //counters.views = 10
            if counters.like == 0 && counters.share == 0 && counters.views == 0 {
                //cell.likeContainerHeightCons.constant   = 0
                cell.shareTextLbl.text = ""
                cell.likeTextLbl.text = ""
                cell.showlikeContainerView.isHidden = true
                cell.viewsDotView.isHidden = true
                cell.viewsCountLabel.text = ""
            } else {
                
                //cell.likeContainerHeightCons.constant = 16
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
            cell.likeContainerHeightCons.constant = 16
            
            if let postTime = beep["postTime"] as? String   {
                let dateFormat = DateFormatter()
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
        
        cell.descDetailLbl.text = textData.beepSummery
        cell.imgCollectionView.reloadData()
    }
    
    
    func dynamicHeightSetup()-> CGFloat {
        
        if let meta = self.beepData["meta"] as? [String : AnyObject] {
            if let tempBeepMedia = meta["beepMedia"] as? [AnyObject] {
                
                if tempBeepMedia.count == 0 {
                    return 180
                } else {
                    if let beepMedia = tempBeepMedia.first {
                        guard let urls = beepMedia["imgURLs"] as? [String : AnyObject] else { return  180 }
                        print_debug(object: urls)
                        if  let img2xH = urls["img2xH"] as? Int {
                            if let img2xW = urls["img2xW"] as? Int {
                                let ratio = (CGFloat(img2xH)/CGFloat(img2xW)) * (SCREEN_WIDTH)
                                if ratio <= 180 {
                                    return SCREEN_WIDTH //240
                                } else {
                                    //return ratio
                                    if ratio.isNaN {
                                        return 240
                                    } else {
                                        return ratio
                                    }
                                    
                                }
                            }
                        }
                    }
                }
            }
        }
        return 180
    }
    
    
    func userDataRelatedCellSetUp(tableView: UITableView, indexPath: IndexPath) -> UserDataCell  {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserDataCell", for:  indexPath) as! UserDataCell
        cell.isUserInteractionEnabled = true
        cell.selectionStyle = .none
        cell.pageController.isHidden = true
        cell.readMoreBtn.isHidden = true
        cell.tagContainerViewHeightConstraint.constant = 0 //self.finalHeight[indexPath.row]
        cell.likeContainerTopCons.constant = 2
        cell.descDetailLbl.text = ""
        cell.tagsContainerTopConstraints.constant = 2.0
        
        //self.setTableViewData(cell, indexPath: indexPath)
        cell.likeBtn.addTarget(self, action: #selector(self.relatedLikeBtnTap(sender:)), for: UIControlEvents.touchUpInside)
        cell.chatBtn.addTarget(self, action: #selector(self.chatBtnTap(sender:)), for: UIControlEvents.touchUpInside)
        cell.shareBtn.addTarget(self, action: #selector(self.relatedShareBtnTap(sender:)), for: UIControlEvents.touchUpInside)
        cell.flagButton.addTarget(self, action: #selector(BeepDetailVC.flagBtnTap(sender:)), for: UIControlEvents.touchUpInside)
        cell.flagButton.isHidden = false
        
        let imageViewTap = UITapGestureRecognizer(target:self, action:#selector(self.releatedBeepViewTap(img:)))
        cell.tapView.isUserInteractionEnabled = true
        cell.tapView.addGestureRecognizer(imageViewTap)
        
        //channelDetails
        let channelViewTap = UITapGestureRecognizer(target:self, action:#selector(self.channelViewTap(img:)))
        cell.providerDescContainerView.isUserInteractionEnabled = true
        cell.providerDescContainerView.addGestureRecognizer(channelViewTap)
        
        cell.imgCollectionViewHeightCons.constant = self.beepDimention[indexPath.row]
        cell.imgCollectionView.isHidden   = true
        cell.pageController.isHidden      = true
        self.setTableViewRelatedData(cell: cell, indexPath: indexPath)
        cell.contentView.layoutIfNeeded()
        return cell
    }
    
    
    func setTableViewRelatedData(cell: UserDataCell, indexPath: IndexPath) {
        
        var sourceData: (sourceName: String, sourceImg: UIImage, channelImage: UIImage)!
        
        if let meta = self.releatedData[indexPath.row]["meta"] as? [String : AnyObject] {
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
                                weakCell?.mainImageView.sd_setImage(with: URL(string: url), completed: {  (image, err, tempcatch, url) in
                                    if image == nil {
                                        weakCell?.mainImageView.image = CONTAINERPLACEHOLDER
                                        
                                    } else {
                                        weakCell?.mainImageView.image = image
                                        weakCell?.mainImageView.contentMode = .scaleAspectFill
                                    }
                                })                          } else {
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
        
        if let beep = self.releatedData[indexPath.row]["beep"] as? [String : AnyObject] {
            
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
                
                let dateFormat = DateFormatter()
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
        
        cell.pageController.currentPage = 0
        cell.imgCollectionView.isHidden = true
        cell.imgCollectionView.reloadData()
    }
    
    
    func beepIsVideo(beeps: [AnyObject])-> Bool {
        
        print(beeps)
        
        guard let beep = beeps.first as? [String: AnyObject] else { return true }
        guard let contentType = beep["contentType"] as? String else { return true }
        
        
        print(contentType)
        
        switch contentType {
        case BeepContentType.Image.rawValue :
            return false
            
        case BeepContentType.Vine.rawValue :
            return true
            
        case BeepContentType.Youtube.rawValue :
            return true
            
        case BeepContentType.Twitch.rawValue :
            return true
            
        case BeepContentType.Mp4.rawValue :
            return true
            
        case BeepContentType.FbVideo.rawValue :
            return true
            
        case BeepContentType.Vimeo.rawValue :
            return true
            
        case BeepContentType.Soundcloud.rawValue :
            return true
            
        default:
            return false
        }
    }
    
    
}

//MARK:- UIWebViewDelegate
//MARK:-
extension BeepDetailVC: UIWebViewDelegate {
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        return true
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        
    }
    
}

//MARK:- UICollectionView Delegate & DataSource extension
//MARK:-
extension BeepDetailVC: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if self.releatedChannels.count > 0 {
            //self.collectionViewHeightcCons.constant = 65
        } else {
            //self.collectionViewHeightcCons.constant = 0
        }
        self.view.layoutIfNeeded()
        return self.releatedChannels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagsCollectionCellXIB", for:  indexPath) as! TagsCollectionCellXIB
        cell.bgBtn.isHidden = false
        cell.bgBtn.addTarget(self, action: #selector(self.channelDetailBtnTap(btn:)), for: UIControlEvents.touchUpInside)
        _ = self.is3DTouchAvailable(btn: cell.bgBtn)
        cell.selectedBackgroundView?.backgroundColor = UIColor.clear
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor.clear
        cell.backgroundView = bgColorView
        
        if let name = self.releatedChannels[indexPath.row]["name"] as? String {
            print_debug(object: name)
            cell.lbl.text = name
        } else {
            cell.lbl.text = ""
        }
        
        if let avatarURL = self.releatedChannels[indexPath.row]["avatarURL"] as? String {
            
            print_debug(object: avatarURL)
            cell.imageView.sd_setImage(with: URL(string: avatarURL), placeholderImage: CHANNELLOGOPLACEHOLDER)
            
        } else {
            cell.imageView.image = CHANNELLOGOPLACEHOLDER
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let channelID = self.releatedChannels[indexPath.row]["id"] as? String else {
            return }
        print(self.releatedChannels[indexPath.row])
        print(channelID)
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier:"ChannelViewFanVC") as! ChannelViewFanVC
        if let dele = self.tabBarDelegate {
            vc.delegate = dele
        }
        vc.channelViewFanVCState = ChannelViewFanVCState.BeepDetailVC
        vc.channelId = channelID
        
        if let nationality = self.releatedChannels[indexPath.row]["displayLabels"] as? [String], nationality.count > 0 {
            vc.displayLabel = nationality
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
        guard let indexPath = btn.collectionViewIndexPath(collectionView: self.collectionView) else { return }
        
        guard let channelID = self.releatedChannels[indexPath.row]["id"] as? String else {
            return }
        let vc = self.storyboard?.instantiateViewController(withIdentifier:"ChannelViewFanVC") as! ChannelViewFanVC
        if let dele = self.tabBarDelegate {
            vc.delegate = dele
        }
        vc.channelViewFanVCState = ChannelViewFanVCState.BeepDetailVC
        vc.channelId = channelID
        self.navigationController?.pushViewController(vc, animated: true)
    }
}



//MARK:- BeepDetailVCDelegate
//MARK:-
extension  BeepDetailVC : BeepDetailVCDelegate {
    
    func updateData(data: AnyObject) {
        
        if let index = self.selectedIndex, self.releatedData.count > index {
            self.releatedData[index] = data
            self.tblView.reloadRows(at: [IndexPath(row: index, section: 2)], with: .none)
        }
    }
}

//MARK:- Webservice methods
//MARK:-
extension  BeepDetailVC {
    
    func likeBeep(beepid: String, flag: Bool) {
        
        var url = WS_LikeBeep + "/" + beepid + "?"
        url.append("index=bb-beeps-feed")
        url.append("&like=\(flag)")
        //url = url + "\(flag)"
        
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
    
    func getReleatedBeepData() {
        
        guard let beep = self.beepData["beep"] as? [String : AnyObject] else { return }
        guard let beepID = beep["id"] as? String else { return }
        guard let channel = beep["channels"] as? [String] else { return }
        guard let PostTime = beep["postTime"] as? String else { return }
        let channelID = channel.first ?? ""
        
        var param: [String: AnyObject] =  ["excludeBeepIDs" : beepID as AnyObject]
        param["channels"] = channelID as AnyObject
        param["hashtags"] = "" as AnyObject
        param["from"] = self.from as AnyObject
        param["size"] = self.size as AnyObject
        param["ltePostTime"] = PostTime as AnyObject
        
        WebServiceController.getReleatedBeep(parameters: param) { (sucess, errorMessage, data) in
            
            guard sucess else { return }
            guard let beeps = data else { return }
            
            if beeps.count == 0 {
                self.size = -1
                return
            }
            
            
            for beepss in beeps {
                
                self.releatedData.append(beepss)
                guard let meta = beepss["meta"] as? [String : AnyObject] else {
                    self.beepDimention.append(180)
                    return }
                
                print_debug(object: "---------")
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
                                        }
                                    }
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
            
            self.tblView.reloadData()
            //self.tblView.beginUpdates()
            //self.tblView.insertSections(NSIndexSet(index: 1), with: .None)
            //self.tblView.insertRowsAtIndexPaths([IndexPath(row: 1, inSection: 0)], with: .None)
            //self.tblView.endUpdates()
            
        }
    }
    
    func getBeepDetail(id: String) {
        
        let url = WS_BeepDetail + "/" + id + "?index=bb-beeps-feed&populateChannels=true"
        
        WebServiceController.getBeepDetail(url: url, parameters: [String : AnyObject]()) { (success, errorMessage, data) in
            
            if success {
                if let getData = data {
                    
                    //print_debug(object: getData)
                    self.beepData = getData as AnyObject
                    if self.callOnceInbeepDetail {
                        self.getReleatedBeepData()
                    }
                    
                    guard let currentBeep = self.beepData["beep"] as? [String : AnyObject] else { return }
                    /*guard let currentMeta = self.beepData["meta"] as? [String : AnyObject] else { return }*/
                    guard let getBeep = getData["beep"] as? [String : AnyObject] else { return }
                    guard let getMeta = getData["meta"] as? [String : AnyObject] else { return }
                    
                    
                    
                    var isReload = false
                    if let currentlike = currentBeep["countLikes"] as? Int {
                        if let getlike = getBeep["countLikes"] as? Int {
                            if currentlike != getlike {
                                isReload = true
                            }
                        }
                        
                    }
                    
                    if let currentShare = currentBeep["countShares"] as? Int {
                        if let getShare = getBeep["countShares"] as? Int {
                            if currentShare != getShare {
                                isReload = true
                            }
                        }
                        
                    }
                    
                    // nitin change
                    // guard let hashtags = getBeep["hashtags"] as? [String] else { return }
                    guard let hashtags = getMeta["userHashTags"] as? [String] else { return }
                    //vc.beepData = beeps
                    
                    var arr = [String]()
                    _ = hashtags.map({ (temp: String) in
                        // arr.append("#\(temp)") // nitin # change
                        arr.append("\(temp)")
                    })
                    
                    self.hasTags = arr
                    self.tagHeight = self.calculatetTagHeight(tempTag: NSMutableArray(array: arr))
                    isReload = true
                    
                    
                    if isReload {
                        var data = [String:AnyObject]()
                        data["beep"] = getBeep as AnyObject
                        data["meta"] = getMeta as AnyObject
                        self.beepData = data as AnyObject
                        let indexPath = IndexPath(row: 0, section: 0)
                        self.tblView.reloadRows(at: [indexPath], with: .none)
                    }
                    
                    if let channelsMiniResults = getMeta["channelsMiniResults"] as? [[String : AnyObject]] {
                        print_debug(object: "hhhhhhhhhhhhhh")
                        print_debug(object: channelsMiniResults)
                        self.channelsMiniResults = channelsMiniResults
                        self.tblView.reloadData()
                    }
                    guard let index = getMeta["index"] as? String else { return }
                    guard let channels = getBeep["channels"] as? [String] else { return }

                    self.viewBeep(beepId: id, channels: channels.first ?? "", index: index)
                }
                
            } else {
                CommonFunctions.showAlertWarning(msg: CommonTexts.INVALID_LOGIN_TITLE)
                let _ = self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func getChannelDetail(channelId: String) {
        
        WebServiceController.getMiniChannelDetail(channelId: channelId) { (success, errorMessage, data) in
            if success {
                
                if let channelData = data {
                    
                    print_debug(object: channelData)
                    
                    if let hashtags = channelData["categoryTags"] as? NSArray {
                        
                        var tagString = ""
                        if hashtags.count > 0 {
                            
                            if let str = hashtags.firstObject as? [String] {
                                tagString = str.joined(separator: ",")
                            }
                            
                            if tagString.characters.count > 0 {
                                self.setReleatedChannels(tags: tagString)
                            } else {
                                self.setReleatedChannels(tags: "")
                            }
                            
                        } else {
                            self.setReleatedChannels(tags: "")
                        }
                        
                    } else {
                        self.setReleatedChannels(tags: "")
                    }
                }
            } else {
                self.setReleatedChannels(tags: "")
            }
        }
    }
    
    func setReleatedChannels(tags: String) {
        
        
        guard let beep = self.beepData["beep"] as? [String : AnyObject] else {
            self.collectionViewHeightcCons.constant = 0
            sepratorHeightConstraint.constant = 0
            self.channelActivityIndicatorView.isHidden = true
            return }
        guard let channels = beep["channels"] as? NSArray else { self.collectionViewHeightcCons.constant = 0
            sepratorHeightConstraint.constant = 0
            self.channelActivityIndicatorView.isHidden = true
            return }
        
        var param = [String : AnyObject]()
        param["channelID"]  = channels.firstObject as? String as AnyObject
        param["includeFollowCount"]  = true as AnyObject
        param["from"] = 0 as AnyObject
        param["size"] = 10 as AnyObject
        param["categoryTags0"] = tags as AnyObject
        
        WebServiceController.getReleatedChannelsList(parameters: param) { (sucess, errorMessage, data) in
            if let tempData = data {
                print_debug(object: tempData)
                
                if tempData.count == 0 {
                    self.setReleatedChannels(tags: "")
                } else {
                    self.releatedChannels.append(contentsOf: tempData)
                    self.collectionView.reloadData()
                }
                
                print_debug(object: tempData)
            }
            
            
            self.channelActivityIndicatorView.isHidden = true
        }
        
    }
    
    func followChannel(channelId: String, follow: Bool) {
        
        let params: [String: AnyObject] = ["channelID" : channelId as AnyObject, "virtualChannel" : false as AnyObject, "follow": follow as AnyObject]
        WebServiceController.follwUnfollowChannel(parameters: params) { (sucess, errorMessage, data) in
            
            if sucess {
                if channelId.isEmpty { return }
                print_debug(object: "You click on follow btn.")
                if let dele = TABBARDELEGATE {
                    dele.sideMenuUpdate()
                }
                if follow {
                    //Save NSUserDefault
                    if let list = UserDefaults.getStringArrayVal(key: NSUserDefaultKeys.FRIENDSLIST) as? [String] {
                        var tempList = list
                        tempList.append(channelId)
                        UserDefaults.setStringVal(value: tempList as AnyObject, forKey: NSUserDefaultKeys.FRIENDSLIST)
                    } else {
                        let id: [String] = [channelId]
                        UserDefaults.setStringVal(value: id as AnyObject, forKey: NSUserDefaultKeys.FRIENDSLIST)
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
                        tempList.remove(at: index)
                        UserDefaults.setStringVal(value: tempList as AnyObject, forKey: NSUserDefaultKeys.FRIENDSLIST)
                    }
                }
                
            } else {
                print_debug(object: errorMessage)
            }
        }
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
    func viewBeep(beepId : String,channels : String, index : String) {
        
        let url = WS_ViewBeep + "\(beepId)?channels=\(channels)?index=\(index)"
        
        WebServiceController.viewBeep(url: url, parameters: [String:AnyObject]()) { (sucess, msg, DataResultResponse) in
            if sucess {
                print_debug(object: "Success")
            } else {
                 print_debug(object: "fail")
            }
            
        }
        
    }
    
}


//MARK:- Webservice methods
//MARK:-
extension  BeepDetailVC: UIViewControllerPreviewingDelegate {
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        guard CommonFunctions.checkLogin() else {
            //CommonFunctions.showLoginAlert(vc: self)
            return nil
        }
        
        guard #available(iOS 9.0, *) else { return nil }
        
        guard let indexPath = previewingContext.sourceView.collectionViewIndexPath(collectionView: self.collectionView)  else { return nil }
        
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
        
        channelPreviewVC.isFriend = isFriend
        channelPreviewVC.channelId = channelID
        channelPreviewVC.indexPath = indexPath
        channelPreviewVC.ChannelPreviewVCDelegate = self
        var height = 185.0
        if let desc = self.releatedChannels[indexPath.item]["desc"] as? String {
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
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        
    }
    
}

extension BeepDetailVC : ChannelPreviewVCDelegate {
    func showChannelDetail(index: IndexPath) {
        
        
        guard let channelID = self.releatedChannels[index.item]["id"] as? String else {
            return }
        let vc = self.storyboard?.instantiateViewController(withIdentifier:"ChannelViewFanVC") as! ChannelViewFanVC
        if let dele = self.tabBarDelegate {
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



extension BeepDetailVC : UITableViewDataSourcePrefetching {
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            if indexPath.section == 2 {
            self.userDataRelatedCellSetUp(tableView: tableView, indexPath: indexPath)
            }
        }
    }
}
extension BeepDetailVC : shareDelegate {
    func shareData() {
        CommonFunctions.displayShareSheet(shareContent: SHARE_Fantasticoh_URL, viewController: self)
    }
}
