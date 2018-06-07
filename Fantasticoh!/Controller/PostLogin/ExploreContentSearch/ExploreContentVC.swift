//
//  ExploreContentVC.swift
//  Fantasticoh!
//
//  Created by Appinventiv on 19/09/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import UIKit

enum ExploreContentVCState {
    
    case None, defaultExplore, TagsSearch
}

class ExploreContentVC: UIViewController {
    
    //MARK:- IBOutlet & Propertie's
    //MARK:-
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var noDataLbl: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var backButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var searchBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var topView: UIView!
    weak var delegate: TabBarDelegate!
    var exploreContentSearchDelegate: ExploreContentSearchDelegate!
    var refreshControl: UIRefreshControl!
    var descriptionText = [String]()
    var finalHeight = [CGFloat]()
    var tags = [[String]]()
    var beepData = [AnyObject]()
    var searchTags = ""
    var from = 0
    let size = 10
    var nextCount  = 1
    
    var userImgArray =  [UIImage(named: "dp1"), UIImage(named: "dp2"), UIImage(named: "dp3")]
    let tblTags = [["#facebook", "#video", "#magic", "#what", "#enamy"],
                   ["#facebook", "#video"], ["#facebook", "#video"] ]
    var beepIsVideo = false
    var beepDimention = [CGFloat]()
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: .white)
    
    var exploreContentVCState = ExploreContentVCState.defaultExplore
    var contentSearchText = ""
    //MARK:- View Life cycle
    //MARK:-
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tblView.delegate = self
        self.tblView.dataSource = self
        self.tblView.isHidden = true
        self.activityIndicator.isHidden = true
//        self.view.bringSubview(toFront: self.activityIndicator)
        self.noDataLbl.isHidden = true
        let userDataCell = UINib(nibName: "UserDataCell", bundle: nil)
        self.tblView.register(userDataCell, forCellReuseIdentifier: "UserDataCell")
        self.spinner.color = CommonColors.globalRedColor()
        self.spinner.startAnimating()
        self.spinner.frame = CGRect(x:0,y: 0,width: SCREEN_WIDTH,height: 28)
        self.tblView.tableFooterView = spinner
        self.spinner.isHidden = true
        self.searchBar.delegate = self
        if exploreContentVCState == .TagsSearch {
            self.searchBarHeightConstraint.constant = 44.0
            self.backButtonHeightConstraint.constant = 44.0
            self.topView.isHidden = false
        }
        self.activityIndicator.color = CommonColors.globalRedColor()
        
        // nitin
        self.noDataLbl.text = CommonTexts.NoContentAvailable
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        //self.view.endEditing(true)
    }
    
    //MARK:- IBOutlet & Propertie's
    //MARK:-
     func searchContentText(text: String) {
        
        print_debug(object: text)
        self.searchTags = text.lowercased()
        
        //channels=&hashtags=delhidynamosfc&from=0&size=20
        
        self.beepDimention      = [CGFloat]()
        self.beepData           = [AnyObject]()
        self.finalHeight        = [CGFloat]()
        self.descriptionText    = [String]()
        self.tags               = [[String]]()
        self.tblView.reloadData()
        self.spinner.isHidden = true
        if text.characters.count > 1 {
            var param: [String: AnyObject] = [String: AnyObject]()
            
            if let tempTag = self.searchTags.characters.first {
                
                if tempTag == "#" {
                    //(at: searchTags.startIndex)
                    self.searchTags.remove(at: searchTags.startIndex)
                }
            }
            
            //param["channels"]           = ""
            //param["hashtags"]           = self.searchTags
            param["query"]              = self.searchTags as AnyObject
            param["from"]               = self.from as AnyObject
            param["size"]               = self.size as AnyObject
            self.getDashBoardData(param: param)

        } else {
            self.noDataLbl.isHidden = true
            self.activityIndicator.isHidden = true
            self.tblView.reloadData()
            spinner.isHidden = true
            spinner.stopAnimating()
        }
        
        
    }
    @IBAction func backBtnTap(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func likeBtnTap(sender:UIButton) {
        
        guard CommonFunctions.checkLogin() else {
            CommonFunctions.showLoginAlert(vc: self)
            return
        }
        
        guard let currentIndexPath = sender.tableViewIndexPath(tableView: self.tblView) else { return }
        guard let cell = self.tblView.cellForRow(at: currentIndexPath) as? UserDataCell  else { return }
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
           /* if let source = beep["source"] as? [String : AnyObject] {
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
//        self.tblView.reloadData()
//        self.tblView.reloadRows(at: [currentIndexPath], with: .none)
        //self.setDataSetAfterLike(cell, beep: self.beepData[currentIndexPath.row], indexPath: currentIndexPath)
        
        
    }
    
    func chatBtnTap(sender:UIButton) {
        
        guard CommonFunctions.checkLogin() else {
            CommonFunctions.showLoginAlert(vc: self)
            return
        }
        
        guard let currentIndexPath = sender.tableViewIndexPath(tableView: self.tblView) else { return }
        
        guard let beep = self.beepData[currentIndexPath.row]["beep"] as? [String : AnyObject] else { return }
        guard let channel = beep["channels"] as? [String] else { return }
        let channelID = channel.first!
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier:"ChannelViewFanVC") as! ChannelViewFanVC
        vc.channelViewFanVCState = ChannelViewFanVCState.AllTagVCChatState
        vc.channelId = channelID
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func shareBtnTap(sender:UIButton) {
        
//        guard CommonFunctions.checkLogin() else {
//            CommonFunctions.showLoginAlert(vc: self)
//            return
//        }
        
        guard let currentIndexPath = sender.tableViewIndexPath(tableView: self.tblView)  else { return }
        guard let cell = self.tblView.cellForRow(at: currentIndexPath) as? UserDataCell else { return }
        if let beep = self.beepData[currentIndexPath.row]["beep"] as? [String : AnyObject] {
            
            if let id = beep["id"] as? String {
                
                let url =  SHARE_BEEP_URL + id
                self.displayShareSheet(shareContent: url, beepId: id, cell: cell, row: currentIndexPath.row)
                
            }
        }
        
    }
    
    func beepDetail(img: UIGestureRecognizer) {
        
        guard let currentIndexPath = img.view!.tableViewIndexPath(tableView: self.tblView) else { return }
        let vc = self.storyboard?.instantiateViewController(withIdentifier:"BeepDetailVC") as! BeepDetailVC
        vc.beepVCState = BeepVCState.ExploreContentSearchStateVC
        vc.tagHeight = self.setTagHeight(indexPath: currentIndexPath) // nitin
        vc.hasTags = self.tags[currentIndexPath.row]
        guard let data = self.beepData[currentIndexPath.row] as? [String: AnyObject] else { return }
        vc.beepData = data as AnyObject
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func channelViewTap(img: UIGestureRecognizer) {
        
        guard let currentIndexPath = img.view!.tableViewIndexPath(tableView: self.tblView) else { return }
        print_debug(object: currentIndexPath)
        
        guard let beep = self.beepData[currentIndexPath.row]["beep"] as? [String : AnyObject] else { return }
        guard let channel = beep["channels"] as? [String] else { return }
        let channelID = channel.first!
        //self.searchTags
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier:"ChannelViewFanVC") as! ChannelViewFanVC
        vc.channelId = channelID
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tapOnTag(str: String) {
        print_debug(object: str)
        if let dele = self.delegate{
            dele.tagBtnTap(tag: str, state: SetExploreVCDataState.Content)
        }
    }
    
    func displayShareSheet(shareContent: String, beepId: String, cell: UserDataCell, row: Int) {
        
        let activityVC = UIActivityViewController(activityItems: [shareContent as NSString], applicationActivities: nil)
        
        activityVC.completionWithItemsHandler = { activity, success, items, error in
            
            if !success{
                print("cancelled")
                return
            } else {
                
                
                
                guard let beep = self.beepData[row]["beep"] as? [String : AnyObject] else { return }
                guard let meta = self.beepData[row]["meta"] as? [String : AnyObject] else { return }
                var tempBeep = beep
                if var countShares = beep["countShares"] as? Int {
                    countShares =  countShares + 1
                    cell.shareCountLbl.text = "\(countShares)"
                    tempBeep["countShares"] = countShares as AnyObject
                    var data = [String:AnyObject]()
                    data["beep"] = tempBeep as AnyObject
                    data["meta"] = meta as AnyObject
                    self.beepData[row] = data as AnyObject
                }
                self.shareBeep(beepId: beepId)
                self.tblView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .none)
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
    
    func setDataSetAfterLike(cell: UserDataCell,  beep: AnyObject, indexPath: IndexPath) {
        
        
        guard let beep = self.beepData[indexPath.row]["beep"] as? [String : AnyObject] else { return }
        
        
        print_debug(object: beep)
        
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
            
        
        self.tblView.reloadRows(at: [indexPath], with: .none)
    }
    
    func flagBtnTap(sender: UIButton) {
        
        //        guard CommonFunctions.checkLogin() else {
        //            CommonFunctions.showLoginAlert(vc: self)
        //            return
        //        }
        
        guard let currentIndexPath = sender.tableViewIndexPath(tableView: self.tblView) else { return }
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


//MARK:- UITableView Delegate & DataSource Extension
//MARK:-
extension ExploreContentVC: UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.beepData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // nitin
        //Crash//
        if indexPath.row >= self.beepData.count {
            print("//Crash//")
            return 0.0
        }
//        let descriptionHeight   = CommonFunctions.getTextHeightWdith(param: self.descriptionText[indexPath.row], font : CommonFonts.SFUIText_Medium(setsize: 14.5)).height
//        var counters = (like: 0, share: 0, views: 0)
//        if let beep = self.beepData[indexPath.row]["beep"] as? [String : AnyObject] {
//            if let countLikes = beep["countLikes"] as? Int {
//                counters.like = countLikes
//            }
//            if let countShares = beep["countShares"] as? Int {
//                counters.share = countShares
//            }
//            
//            if let countViews = beep["countViews"] as? Int {
//                counters.views = countViews
//            }
//        }
        
        return UITableViewAutomaticDimension
        
//        if counters.like == 0 && counters.share == 0 && counters.views == 0 {
//
//            return 145.0 + self.beepDimention[indexPath.row] + descriptionHeight
//        } else {
//
//            return 145.0 + self.beepDimention[indexPath.row] + descriptionHeight
//        }
        //return 325 + 12 + descriptionHeight + self.finalHeight[indexPath.row]
        
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 400.0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserDataCell", for:  indexPath) as! UserDataCell
        
        if indexPath.row >= self.beepData.count {
            return cell
        }
        cell.bottomViewHeightConstant.constant = 0
        cell.btnContainerView.isHidden = true
        cell.isUserInteractionEnabled = true
        cell.selectionStyle = .none
        cell.readMoreBtn.isHidden = true
        cell.tagContainerViewHeightConstraint.constant = 0
        cell.tagContainerView.isHidden = true
        
        //self.finalHeight[indexPath.row]
        
        cell.tagContainerView.tags.addObjects(from: self.tags[indexPath.row] as [AnyObject])
        cell.tagContainerView.tagSelectedTextColor = CommonColors.lightGrayColor()
        cell.tagContainerView.tagTextColor = CommonColors.lightGrayColor()
        cell.tagContainerView.setCompletionBlockWithSelected { (val: Int) in
            
            print_debug(object: cell.tagContainerView.selectedTags.lastObject)
            if let tagStr = cell.tagContainerView.selectedTags.lastObject as? String {
                
                self.exploreContentSearchDelegate.resetSetSearhBarText(text: tagStr)
            }
        }
        cell.tagContainerView.collectionView.reloadData()
        
        self.setTableViewData(cell: cell, indexPath: indexPath)
        
        cell.likeBtn.addTarget(self, action: #selector(ExploreContentVC.likeBtnTap(sender:)), for: .touchUpInside)
        cell.chatBtn.addTarget(self, action: #selector(ExploreContentVC.chatBtnTap(sender:)), for: .touchUpInside)
        cell.shareBtn.addTarget(self, action: #selector(ExploreContentVC.shareBtnTap(sender:)), for: .touchUpInside)
        cell.flagButton.addTarget(self, action: #selector(ChannelUpdatesVC.flagBtnTap(sender:)), for: UIControlEvents.touchUpInside)
        
        //Video logo
        let backgroundView = UIImageView(image: UIImage(named: "video_play_button")!)
        let org = cell.tapView.frame.origin
        let height = cell.tapView.frame.height
        backgroundView.frame = CGRect(origin: org, size: CGSize(width: SCREEN_WIDTH, height: height))
        backgroundView.contentMode = .center
        //cell.tapView.addSubview(backgroundView)
        
        let imageViewTap = UITapGestureRecognizer(target:self, action:#selector(ExploreContentVC.beepDetail(img:)))
        cell.tapView.isUserInteractionEnabled = true
        cell.tapView.addGestureRecognizer(imageViewTap)
        
        //channelDetails
        let channelViewTap = UITapGestureRecognizer(target:self, action:#selector(ExploreContentVC.channelViewTap(img:)))
        cell.providerDescContainerView.isUserInteractionEnabled = true
        cell.providerDescContainerView.addGestureRecognizer(channelViewTap)
        
        cell.imgCollectionViewHeightCons.constant = self.beepDimention[indexPath.row]
        cell.imgCollectionView.isHidden = true
        cell.pageController.isHidden = true
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if self.beepData.count-1 == indexPath.row {
            spinner.isHidden = true
            self.from = self.from+10
            var param: [String: AnyObject] = [String: AnyObject]()
            //param["channels"]           = ""
            //param["hashtags"]           = self.searchTags
            param["query"]              = self.searchTags as AnyObject
            param["from"]               = self.from as AnyObject
            param["size"]               = self.size as AnyObject
            
            if self.nextCount != 0 {
                self.getDashBoardData(param: param)
                spinner.startAnimating()
                spinner.isHidden = false
            } else {
                spinner.isHidden = true
                
            }
            
        }
        
        cell.clipsToBounds = true
        
    }
    
    func setTableViewData(cell: UserDataCell, indexPath: IndexPath) {
        
        var sourceData: (sourceName: String, sourceImg: UIImage, channelImage: UIImage)!
        
        if let meta = self.beepData[indexPath.row]["meta"] as? [String : AnyObject] {
            if let userLiked = meta["userLiked"] as? Bool {
                cell.likeBtn.isSelected = userLiked
            }
            
            
            if let tempBeepMedia = meta["beepMedia"] as? [AnyObject] {
                
                if  tempBeepMedia.count == 0 {
                    cell.mainImageView.image = CONTAINERPLACEHOLDER
                    cell.mainImageView.contentMode = .center
                } else {
                    if let beepMedia = tempBeepMedia.first {
                        
                        if let urls = beepMedia["imgURLs"] as? [String : AnyObject] {
                            if let url = urls["img1x"] as? String {
                                cell.imageArrayURl = [URL(string: url)!]
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
                                        weakCell?.mainImageView.contentMode = .center
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
            
            /* if let tempBeepMedia = meta["beepMedia"] as? [AnyObject] {
             
             if tempBeepMedia.count == 0 {
             cell.imageArrayURl = [NSURL(string: "")!]
             cell.moreCount = 1
             } else {
             if let beepMedia = tempBeepMedia.first {
             
             if let urls = beepMedia["imgURLs"] as? [String : AnyObject] {
             if let url = urls["img2x"] as? String {
             cell.imageArrayURl = [NSURL(string: url)!]
             } else {
             cell.imageArrayURl = [NSURL(string: "")!]
             }
             } else {
             cell.imageArrayURl = [NSURL(string: "")!]
             }
             cell.moreCount = 1
             }
             }
             
             
             } */
            
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
            /*
             if let countLikes = beep["countLikes"] as? Int {
             cell.likeCountLbl.text = "\( countLikes )"
             if countLikes > 1 {
             cell.likeTextLbl.text = "Likes"
             } else {
             cell.likeTextLbl.text = "Like"
             }
             }
             
             if let countShares = beep["countShares"] as? Int {
             if countShares > 1 {
             cell.shareTextLbl.text = "Shares"
             } else {
             cell.shareTextLbl.text = "Share"
             }
             cell.shareCountLbl.text = "\( countShares )"
             }
             */
            
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
            
            // crash
            if let postTime = beep["postTime"] as? String {
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
        
    }
    
    func setTagHeight(indexPath: IndexPath) -> CGFloat {
        
        var tagWidth: CGFloat = 10 + 10
        var line  = 1
        var finalHeight: CGFloat = 0
        
        // nitin
        if indexPath.row >= self.tags.count {
            
            //Crash//
            let array = self.tags[indexPath.row]
            _  = array.map({ (temp) in
                
                let frame = CommonFunctions.getTextHeightWdith(param: temp as? String ?? "", font : CommonFonts.SFUIText_Medium(setsize: 14.5))
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
        }
        
        let totalLineWidth = line * 20
        let totalLinseSpaceWidth = line * 10
        finalHeight = CGFloat(totalLineWidth + totalLinseSpaceWidth)
        //self.finalHeight.insert(finalHeight, atIndex: indexPath.row)
        //self.finalHeight.append(finalHeight) // nitin
        
        return finalHeight
        //--------------------------------------
        
    }
    
}


//MARK:- WebService method's
//MARK:-
extension ExploreContentVC {
    
    func getDashBoardData(param: [ String : AnyObject]) {
        
        WebServiceController.searchEveryThing(url: WS_Dashboard_Search, parameters: param) { (sucess, errorMessage, data) in
            //self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
            self.spinner.isHidden = true
            if data == nil && !sucess {
                self.noDataLbl.isHidden = false
                self.tblView.isHidden = true
                print_debug(object: errorMessage)
                return
            }
            
            guard let results = data!["beeps"] as? [String: AnyObject] else {
                self.noDataLbl.isHidden = false
                self.tblView.isHidden = true
                return
            }
            
            guard let responsejson = results["results"] as? [AnyObject] else {
                self.noDataLbl.isHidden = false
                self.tblView.isHidden = true
                return
            }
            
            if responsejson.count < 10 && responsejson.count == 0 {
                self.nextCount = 0
            }
            
            for beepss in responsejson {
                
                if let beep = beepss["beep"] as? [String : AnyObject] {
                    
                    if let hashtags = beep["hashtags"] as? [String] {
                        
                        print_debug(object: hashtags)
                        var arr = [String]()
                        _ = hashtags.map({ (temp: String) in
                            if !temp.hasPrefix("_") {
                                arr.append("#\(temp)")
                            }
                        })
                        self.tags.append(arr)
                    }
                }
                
                if let meta = beepss["meta"] as? [String : AnyObject] {
                    if let summary = meta["summary"] as? String {
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
                
                self.beepData.append(beepss)
                
            }
            
            if self.beepData.isEmpty {
                self.noDataLbl.isHidden = false
                self.tblView.isHidden = true
            } else  {
                self.noDataLbl.isHidden = true
                self.tblView.isHidden = false
                self.tblView.reloadData()
                
            }
            
        }
    }
    
    func likeBeep(beepid: String, flag: Bool) {
        
        var url = WS_LikeBeep + "/" + beepid + "?"
        url.append("index=bb-beeps-feed")
        url.append("&like=\(flag)")
        
        print_debug(object: url)
        
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

//MARK:- UISearchBarDelegate Extension
//MARK:-
extension ExploreContentVC : UISearchBarDelegate {
    
    
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier:"SuggestionSearchVC") as! SuggestionSearchVC
        vc.exploreContentSearchDelegate = self
        self.navigationController?.pushViewController(vc, animated: false)
        
        // nitin
        if !self.contentSearchText.isEmpty {
            CommonFunctions.delay(delay: 0.1, closure: {
                
                vc.searchBar.text = self.contentSearchText
                vc.searchKeyword(text: self.contentSearchText.getSearchFormatedString())
                
            })
        }
        
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        self.view.endEditing(true)
    }
}

//MARK:- ExploreContentSearchDelegate
//MARK:-
extension ExploreContentVC: ExploreContentSearchDelegate {
    
    func resetSetSearhBarText(text: String) {
        //self.searchBar.delegate?.searchBar!(self.searchBar, textDidChange: text)
        //let tempText = self.searchBar.text ?? ""
        //let currentText = "#" + tempText + " " + text
        self.searchBar.text = text.removeExcessiveSpaces
        //self.setContentSearchState = SetContentSearchState.Content
        //self.searchBar.becomeFirstResponder()
        
    }
    
    func setChannelText(text: String) {
        self.searchBar.resignFirstResponder()
        self.searchBar.endEditing(true)
        self.searchBar.text = text.removeExcessiveSpaces
        self.contentSearchText = text.removeExcessiveSpaces
        
        self.noDataLbl.isHidden = true
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
        self.searchContentText(text: text)
        
        
        
    }
    
}

extension ExploreContentVC : shareDelegate {
    func shareData() {
        CommonFunctions.displayShareSheet(shareContent: SHARE_Fantasticoh_URL, viewController: self)
    }
}
