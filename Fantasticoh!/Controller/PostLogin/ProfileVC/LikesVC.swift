//
//  LikesVC.swift
//  Fantasticoh!
//
//  Created by Appinventiv on 06/09/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import UIKit

protocol LikesVCDelegate : class {
    func fromChannelDetailDataReload(updateData: [AnyObject])
}

class LikesVC: UIViewController {
    
    //MARK:- @IBOutlet & Properties
    //MARK:-
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var noDataLbl: UILabel!

    var fansVCDelegate: FansVCDelegate!
    var beepData = [AnyObject]()
    var descriptionText = [String]()
    var tags = [[String]]()
    var vCState: VCState!
    var fanId = String()
    var refreshControl: UIRefreshControl!
    var nextCount  = 1
    let size = 5
    var from = 0
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: .white)
    var beepIsVideo = false
    var beepDimention = [CGFloat]()
    
    //MARK:- View Life Cycle
    //MARK:-
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tblView.delegate = self
        self.tblView.dataSource = self
        
        let userDataCell = UINib(nibName: "UserDataCell", bundle: nil)
        self.tblView.register(userDataCell, forCellReuseIdentifier: "UserDataCell")
        
        self.refreshControl = UIRefreshControl()
        self.tblView.addSubview(refreshControl)
        self.refreshControl.tintColor = CommonColors.globalRedColor()
        self.refreshControl.addTarget(self, action: #selector(LikesVC.refresh(sender:)), for: UIControlEvents.valueChanged)
        
        self.spinner.color = CommonColors.globalRedColor()
        self.spinner.startAnimating()
        self.spinner.frame = CGRect(x:0,y: 0,width: SCREEN_WIDTH,height: 28)
        self.tblView.tableFooterView = spinner
        
        // nitin
        self.noDataLbl.text = CommonTexts.CurrentlyNoLikes
        self.noDataLbl.numberOfLines = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.beepData.removeAll(keepingCapacity: false)
        if self.vCState == VCState.Personal {
            if let uID = CurrentUser.userId {
                if uID.isEmpty {
                    return
                }
                let url = WS_UserChannelList + "/\(uID)" + "/likes"
                var param = [String : AnyObject]()
                param["from"] = 0 as AnyObject
                param["size"] = self.size as AnyObject
                self.getDashBoardData(url: url, param: param)
            }
            
        } else if self.vCState == VCState.OtherProfile {
            
            let url = WS_UserChannelList + "/\(self.fanId)" + "/likes"
            var param = [String : AnyObject]()
            param["from"] = 0 as AnyObject
            param["size"] = self.size as AnyObject
            self.getDashBoardData(url: url, param: param)
            
        }
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    //MARK:- IBAction & Selector Method
    //MARK:-
    
    func refresh(sender: AnyObject) {
        self.setInitData()
    }
    
    func setInitData() {
        
        self.beepData = [AnyObject]()
        self.descriptionText = [String]()
        self.tags = [[String]]()
        self.beepDimention = [CGFloat]()
        
        if self.vCState == VCState.Personal {
            if let uID = CurrentUser.userId {
                if uID.isEmpty {
                    return
                }
                let url = WS_UserChannelList + "/\(uID)" + "/likes"
                var param = [String : AnyObject]()
                param["from"] = 0 as AnyObject
                param["size"] = self.size as AnyObject
                self.getDashBoardData(url: url, param: param)
            }
            
        } else if self.vCState == VCState.OtherProfile {
            
            let url = WS_UserChannelList + "/\(self.fanId)" + "/likes"
            var param = [String : AnyObject]()
            param["from"] = 0 as AnyObject
            param["size"] = self.size as AnyObject
            self.getDashBoardData(url: url, param: param)
            
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
                self.tblView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .none)
                self.shareBeep(beepId: beepId)
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
    
     func tapOnTag(str: String) {
        if let dele = TABBARDELEGATE {
            dele.tagBtnTap(tag: str, state: SetExploreVCDataState.Content)
        }
    }
    
    func likeBtnTap(sender:UIButton) {
 
        guard CommonFunctions.checkLogin() else {
            CommonFunctions.showLoginAlert(vc: self)
            return
        }
        
        guard let currentIndexPath = sender.tableViewIndexPath(tableView: self.tblView) else { return }
        guard let cell = self.tblView.cellForRow(at: currentIndexPath) as? UserDataCell else { return }
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
        
        self.tblView.reloadRows(at: [IndexPath(row: currentIndexPath.row, section: currentIndexPath.section)], with: .none)
    }
    
    func chatBtnTap(sender:UIButton) {
 
        guard CommonFunctions.checkLogin() else {
            CommonFunctions.showLoginAlert(vc: self)
            return
        }
        
        guard let currentIndexPath = sender.tableViewIndexPath(tableView: self.tblView) else { return }
        let row = currentIndexPath.row
        
        guard let beep = self.beepData[row]["beep"] as? [String : AnyObject] else { return }
        guard let channel = beep["channels"] as? [String] else { return }
        let channelID = channel.first!
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier:"ChannelViewFanVC") as! ChannelViewFanVC
        vc.channelViewFanVCState = ChannelViewFanVCState.ProfileUserLikes
        vc.likesVCDelegate = self
        vc.channelId = channelID
        if let dele = self.fansVCDelegate {
            vc.fansVCDelegate = dele
        }
        vc.isChat = true
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func shareBtnTap(sender:UIButton) {

//        guard CommonFunctions.checkLogin() else {
//            CommonFunctions.showLoginAlert(vc: self)
//            return
//        }
        
        guard let currentIndexPath = sender.tableViewIndexPath(tableView: self.tblView) else { return }
        let cell = self.tblView.cellForRow(at: currentIndexPath) as! UserDataCell
        if let beep = self.beepData[currentIndexPath.row]["beep"] as? [String : AnyObject] {
            
            if let id = beep["id"] as? String {
                
                let url =  SHARE_BEEP_URL + id
                self.displayShareSheet(shareContent: url, beepId: id, cell: cell, row: currentIndexPath.row)
                
            }
        }
    }
    
    func beepDetail(img: UIGestureRecognizer) {

        let currentIndexPath = img.view!.tableViewIndexPath(tableView: self.tblView)
        guard let row = currentIndexPath?.row else { return }
        if self.beepData.count == 0 || self.tags.count == 0 {
            return
        }
        let vc = self.storyboard?.instantiateViewController(withIdentifier:"BeepDetailVC") as! BeepDetailVC
        vc.beepVCState = BeepVCState.ProfileLikesBeep
        vc.likesVCDelegate = self
        vc.tabBarDelegate = TABBARDELEGATE
        vc.tagHeight = self.tagHeight(row: row)
        vc.hasTags = self.tags[row]
        guard let data = self.beepData[row] as? AnyObject else { return }
        vc.beepData = data
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tagHeight(row: Int) -> CGFloat{
        
        var tagWidth: CGFloat = 10 + 10
        var line  = 1
        let array = self.tags[row]
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
        let totalLineWidth = line * 20
        let totalLinseSpaceWidth = line * 10
        return CGFloat(totalLineWidth + totalLinseSpaceWidth)
    }
    
    func channelViewTap(img: UIGestureRecognizer) {
        
        let currentIndexPath = img.view!.tableViewIndexPath(tableView: self.tblView)
        guard let row = currentIndexPath?.row else { return }
        
        guard let beep = self.beepData[row]["beep"] as? [String : AnyObject] else { return }
        guard let channel = beep["channels"] as? [String] else { return }
        let channelID = channel.first!
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier:"ChannelViewFanVC") as! ChannelViewFanVC
        vc.channelViewFanVCState = ChannelViewFanVCState.ProfileUserLikes
        vc.likesVCDelegate = self
        vc.channelId = channelID
        if let dele = self.fansVCDelegate {
            vc.fansVCDelegate = dele
        }
        
        self.navigationController?.pushViewController(vc, animated: true)
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

//MARK:- UITableView Delegate & DataSource
//MARK:-
extension LikesVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.beepData.count > 0 {
            print_debug(object: self.beepData.count)
            return self.beepData.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.beepData.count > 0, indexPath.row < self.beepData.count  {
           
            let frame  = CommonFunctions.getTextHeightWdith(param: self.descriptionText[indexPath.row], font : CommonFonts.SFUIText_Medium(setsize: 14.5))
            let descriptionHeight   = frame.height
            let hDim = self.beepDimention[indexPath.row] 
            
            let height = 145 + hDim + 12 + descriptionHeight
            
            var counters = (like: 0, share: 0, views: 0)
            if let beep = self.beepData[indexPath.row]["beep"] as? [String : AnyObject] {
                if let countLikes = beep["countLikes"] as? Int {
                    counters.like = abs(countLikes)
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
            
            //return 150 + self.beepDimention[indexPath.row] + 12 + descriptionHeight
            //return 325 + 12 + descriptionHeight
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard indexPath.row < self.beepData.count  else { return UITableViewCell() }
    
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserDataCell", for:  indexPath) as! UserDataCell
        cell.isUserInteractionEnabled = true
        cell.selectionStyle = .none
        cell.tagContainerViewHeightConstraint.constant = 0
        cell.pageController.isHidden = true
        
       
        cell.likeBtn.addTarget(self, action: #selector(LikesVC.likeBtnTap(sender:)), for: .touchUpInside)
        cell.chatBtn.addTarget(self, action: #selector(LikesVC.chatBtnTap(sender:)), for: .touchUpInside)
        cell.shareBtn.addTarget(self, action: #selector(LikesVC.shareBtnTap(sender:)), for: .touchUpInside)
        cell.flagButton.addTarget(self, action: #selector(LikesVC.flagBtnTap(sender:)), for: UIControlEvents.touchUpInside)
        
        //Video logo
        let backgroundView = UIImageView(image: UIImage(named: "video_play_button")!)
        let org = cell.tapView.frame.origin
        let height = cell.tapView.frame.height
        backgroundView.frame = CGRect(origin: org, size: CGSize(width: SCREEN_WIDTH, height: height))
        backgroundView.contentMode = .center
        //cell.tapView.addSubview(backgroundView)
        
        let imageViewTap = UITapGestureRecognizer(target:self, action: #selector(LikesVC.beepDetail(img:)))  //
        cell.tapView.isUserInteractionEnabled = true
        cell.tapView.addGestureRecognizer(imageViewTap)
        
        //channelDetails
        let channelViewTap = UITapGestureRecognizer(target:self, action:#selector(LikesVC.channelViewTap(img:)))
        cell.providerDescContainerView.isUserInteractionEnabled = true
        cell.providerDescContainerView.addGestureRecognizer(channelViewTap)
        
        
        cell.imgCollectionViewHeightCons.constant = self.beepDimention[indexPath.row]
        cell.imgCollectionView.isHidden   = true
        cell.pageController.isHidden      = true
        self.setTableViewData(cell: cell, indexPath: indexPath)
        cell.contentView.layoutIfNeeded()
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

        if self.beepData.count-1 == indexPath.row {
        
            self.from = self.from+self.size
            if self.nextCount != 0 {
                self.spinner.startAnimating()
                if self.vCState == VCState.Personal {
                    if let uID = CurrentUser.userId {
                        if uID.isEmpty {
                            return
                        }
                        let url = WS_UserChannelList + "/\(uID)" + "/likes"
                        var param = [String : AnyObject]()
                        param["from"] = self.from as AnyObject
                        param["size"] = self.size as AnyObject
                        self.getDashBoardData(url: url, param: param)
                    }
                    
                } else if self.vCState == VCState.OtherProfile {
                    
                    let url = WS_UserChannelList + "/\(self.fanId)" + "/likes"
                    var param = [String : AnyObject]()
                    param["from"] = self.from as AnyObject
                    param["size"] = self.size as AnyObject
                    self.getDashBoardData(url: url, param: param)
                    
                }

            } else {
                self.spinner.stopAnimating()
            }
        
        }
        
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
            
            
            if let postTime = beep["postTime"] as? String   {
                
                print_debug(object: postTime)
                let dateFormat = DateFormatter()
                dateFormat.timeZone = TimeZone(identifier: "UTC")
                dateFormat.dateFormat =  "yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"
                print_debug(object: dateFormat.date(from: postTime))
                
                
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

}

//MARK:- WebService extension
//MARK:-
extension LikesVC {

     func getDashBoardData(url: String, param: [ String : AnyObject]) {
        
        WebServiceController.getDashboradFeed(url: url, parameters: param) { (sucess, errorMessage, data) in
            
            if sucess {
                
                if let beepData = data {
                    //self.nextCount = beepData.count
                    if beepData.count < 10 && beepData.count == 0 {
                        self.nextCount = 0
                        self.spinner.stopAnimating()
                    }
                    self.spinner.stopAnimating()
                    print_debug(object: beepData)

                    for beepss in beepData {
                        
                        if let beep = beepss["beep"] as? [String : AnyObject] {
                            
                            if let hashtags = beep["hashtags"] as? [String] {
                                
                                var arr = [String]()
                                _ = hashtags.map({ (temp: String) in
                                    //let attStr = NSAttributedString(string: temp, attributes: [NSAttributedF])
                                    if !temp.hasPrefix("_") {
                                        arr.append("#\(temp)")
                                    }
                                })
                                self.tags.append( arr)
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
                    }
                    if let beeps = data  {
                        self.beepData.append(contentsOf: beeps)
                    }

                    if self.beepData.isEmpty {
                        self.beepData.removeAll(keepingCapacity: false)
                        self.refreshControl.endRefreshing()
                        self.tblView.reloadData()
                        self.noDataLbl.isHidden = false
                    } else  {
                        self.noDataLbl.isHidden = true
                        self.refreshControl.endRefreshing()
                        self.tblView.reloadData()
                    }
                    
                } else {
                    self.refreshControl.endRefreshing()
                }
                
            } else {
                print_debug(object: errorMessage)
                self.refreshControl.endRefreshing()
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

//MARK:- Protocol extension
//MARK:-
extension LikesVC: LikesVCDelegate {
    
    func fromChannelDetailDataReload(updateData: [AnyObject]) {
        
        var newDatas = updateData
        var index = 0
        for oldBeeps in self.beepData {
            
            guard let oldBeep = oldBeeps["beep"] as? [String: AnyObject] else { return }
            guard let oldBeepId = oldBeep["id"] as? String else { return }
            print_debug(object: oldBeepId)
            var internalIndex = 0
            for newData in newDatas {
                guard let newBeep = newData["beep"] as? [String: AnyObject] else { return }
                guard let newBeepId = newBeep["id"] as? String else { return }
                print_debug(object: newBeepId)
                if oldBeepId == newBeepId {
                    self.beepData[index] = newData
                    self.tblView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
                    newDatas.remove(at: internalIndex)
                    internalIndex = internalIndex + 1
                    index = 0
                }
            }
            index = index + 1
            
        }
    }
}

extension LikesVC : shareDelegate {
    func shareData() {
        CommonFunctions.displayShareSheet(shareContent: SHARE_Fantasticoh_URL, viewController: self)
    }
}
