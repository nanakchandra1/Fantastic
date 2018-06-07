//
//  ChannelUpdatesVC.swift
//  Fantasticoh!
//
//  Created by Appinventiv on 29/09/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import UIKit

protocol ChannelUpdatesVCDelegate : class {
    func beepDataReload()
    func fromChannelDetailDataReload(updateData: [AnyObject]) // nitin
}

class ChannelUpdatesVC: UIViewController {
    
    //MARK:- IBOutlet & Propertie's
    //MARK:-
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var noDataLbl: UILabel!
    
    weak var delegate: TabBarDelegate!
    weak var alltagVCDelegate: AllTagVCDelegate!
    weak var likesVCDelegate: LikesVCDelegate!
    weak var channelViewFanVCDelegate: ChannelViewFanVCDelegate!
    var refreshControl: UIRefreshControl!
    var channelId = String()
    var beepData = [AnyObject]()
    var descriptionText = [String]()
    var tags = [[String]]()
    var from = 0
    let size = 3
    var updateBeepData = [AnyObject]()
    var nextCount  = 1
    var beepIsVideo = false
    var beepDimention = [CGFloat]()
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: .white)
    
    //MARK:- View Life cycle
    //MARK:-
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        self.refreshControl = UIRefreshControl()
        self.refreshControl.tintColor = CommonColors.globalRedColor()
        self.refreshControl.addTarget(self, action: #selector(ChannelUpdatesVC.refresh(sender:)), for: UIControlEvents.valueChanged)
        self.tblView.addSubview(refreshControl)
        
        let userDataCell = UINib(nibName: "UserDataCell", bundle: nil)
        self.tblView.register(userDataCell, forCellReuseIdentifier: "UserDataCell")
        
        self.setInitData()
        
        // nitin
        self.noDataLbl.text = CommonTexts.NoUpdate
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        APP_DELEGATE.statusBarStyle = UIStatusBarStyle.lightContent
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- IBAction, Selector &  Method
    //MARK:-
    
    func refresh(sender: AnyObject) {
        
        self.setInitData()
        self.refreshControl?.endRefreshing()
    }
    
     func setInitData() {
        
//        self.beepData = [AnyObject]()
//        self.descriptionText = [String]()
//        self.beepDimention = [CGFloat]()
//        self.tags = [String]()
//        
        self.beepData.removeAll(keepingCapacity: false)
        self.descriptionText.removeAll(keepingCapacity: false)
        self.beepDimention.removeAll(keepingCapacity: false)
        self.tags.removeAll(keepingCapacity: false)
        
        
        _ = CurrentUser.userId ?? ""
        let param: [String: AnyObject] = ["channels" : self.channelId as AnyObject, "from" : self.from as AnyObject, "size" : self.size as AnyObject, "hashtags" : "" as AnyObject]
        self.getDashBoardData(param: param)
    }
    
    func beepDetail(img: UIGestureRecognizer) {
        
        //return
        guard let tempView = img.view else { return }
        guard let currentIndexPath = tempView.tableViewIndexPath(tableView: self.tblView) else { return }
        let row = currentIndexPath.row
        if self.beepData.count == 0 || self.tags.count == 0 {
            return
        }
        let vc = self.storyboard?.instantiateViewController(withIdentifier:"BeepDetailVC") as! BeepDetailVC
        //vc.isShowNext = false
        vc.beepVCState = BeepVCState.ChannelUpdateVCState
        vc.tabBarDelegate = self.delegate
        vc.channelUpdateDelegate = self
        vc.tagHeight = self.tagHeight(row: row)
        vc.hasTags = self.tags[row]
        guard let data = self.beepData[row] as? [String: AnyObject] else { return }
        vc.beepData = data as AnyObject
        vc.from = row
        self.navigationController?.pushViewController(vc, animated: true)
        
        
        
    }
    
     func tagHeight(row: Int)-> CGFloat {
        
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
    
    
    func likeBtnTap(sender:UIButton) {
        
        guard CommonFunctions.checkLogin() else {
            CommonFunctions.showLoginAlert(vc: self)
            return
        }
        
        guard let currentIndexPath = sender.tableViewIndexPath(tableView: self.tblView) else { return }
        let cell = self.tblView.cellForRow(at: currentIndexPath) as! UserDataCell
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
        self.createArrayToDashBoard(row: currentIndexPath.row)
        
    }
    
    func chatBtnTap(sender:UIButton) {
        
        guard CommonFunctions.checkLogin() else {
            CommonFunctions.showLoginAlert(vc: self)
            return
        }
        
        if let dele = self.channelViewFanVCDelegate {
            dele.moveToChat()
        }
    }
    
    func shareBtnTap(sender:UIButton) {
        
//        guard CommonFunctions.checkLogin() else {
//            CommonFunctions.showLoginAlert(vc: self)
//            return
//        }
        
        guard let currentIndexPath = sender.tableViewIndexPath(tableView: self.tblView) else { return }
        guard let cell = self.tblView.cellForRow(at: currentIndexPath) as? UserDataCell else { return }
        
        if let beep = self.beepData[currentIndexPath.row]["beep"] as? [String : AnyObject] {
            
            if let id = beep["id"] as? String {
                
                let url =  SHARE_BEEP_URL + id
                self.displayShareSheet(shareContent: url, beepId: id, cell: cell, row: currentIndexPath.row)
                
            }
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
                self.createArrayToDashBoard(row: row)
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
    
     func tapOnTag(str: String) {
        if let dele = self.delegate {
            dele.tagBtnTap(tag: str, state: SetExploreVCDataState.Content)
        } else {
            print_debug(object: "Delegate not found")
        }
    }
    
     func createArrayToDashBoard(row: Int){
        
        print_debug(object: self.beepData[row])
        
        guard let beepD = self.beepData[row] as? AnyObject else { return }
        
        guard let beep = beepD["beep"] as? [String: AnyObject] else { return }
        guard let meta = beepD["meta"] as? [String: AnyObject] else { return }
        
        let id = beep["id"] as? String
        var index = 0
        for temp in self.updateBeepData {
            if let beep = temp["beep"] as? [String: AnyObject]{
                let tempId = beep["id"] as? String
                if tempId == id {
                    self.updateBeepData.remove(at: index)
                    break
                }
            }
            index = index + 1
            
        }
        var data = [String:AnyObject]()
        data["beep"] = beep as AnyObject
        data["meta"] = meta as AnyObject
        self.updateBeepData.append(data as AnyObject)
    }
    
    func allTagVcUpdate() {
        
        if let dele = ALLTAGVCDELEGATE {
            if let navController = self.navigationController {
                navController.popViewController(animated: true)
            }
            dele.fromChannelDetailDataReload(updateData: self.updateBeepData)
        }
    }
    
    func allTagVcUpdateAfterSideMenu() {
        
        if let dele = ALLTAGVCDELEGATE {
            if let navController = self.navigationController {
                navController.popViewController(animated: true)
            }
            dele.fromChannelDetailDataReload(updateData: self.updateBeepData)
        }
    }
    
    func profileLikesUpdate() {
        
        if self.likesVCDelegate != nil {
            print_debug(object: "Delegate found")
        } else {
            print_debug(object: "Delegate not found")
        }
        
        if let dele = self.likesVCDelegate {
            dele.fromChannelDetailDataReload(updateData: self.updateBeepData)
        }
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
extension ChannelUpdatesVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.beepData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if self.beepData.count > 0 {
            let descriptionHeight   = CommonFunctions.getTextHeightWdith(param: self.descriptionText[indexPath.row], font : CommonFonts.SFUIText_Medium(setsize: 15.5)).height
            //return 325 + 12 + descriptionHeight //+ self.finalHeight[indexPath.row]
            let hDim = self.beepDimention[indexPath.row] 
            let height = 145 + hDim + 16 + descriptionHeight
            
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
                return (height - 16)
            } else {
                return height
            }
            
            
            
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard self.beepData.count > 0 else { return UITableViewCell() }
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserDataCell", for:  indexPath) as! UserDataCell
        cell.isUserInteractionEnabled = true
        cell.selectionStyle = .none
        cell.pageController.isHidden = true
        cell.tagContainerViewHeightConstraint.constant = 0 //self.finalHeight[indexPath.row]
        
        cell.tagContainerView.tags.addObjects(from: self.tags[indexPath.row] as [AnyObject])
        cell.tagContainerView.tagSelectedTextColor = CommonColors.lightGrayColor()
        cell.tagContainerView.tagTextColor = CommonColors.lightGrayColor()
        cell.tagContainerView.setCompletionBlockWithSelected { (val: Int) in
            
            if let tagStr = cell.tagContainerView.selectedTags.firstObject as? String {
                print_debug(object: tagStr)
                self.tapOnTag(str: tagStr)
            }
        }
        cell.tagContainerView.collectionView.reloadData()
        
        cell.likeBtn.addTarget(self, action: #selector(ChannelUpdatesVC.likeBtnTap(sender:)), for: UIControlEvents.touchUpInside)
        cell.chatBtn.addTarget(self, action: #selector(ChannelUpdatesVC.chatBtnTap(sender:)), for: UIControlEvents.touchUpInside)
        cell.shareBtn.addTarget(self, action: #selector(ChannelUpdatesVC.shareBtnTap(sender:)), for: UIControlEvents.touchUpInside)
        cell.flagButton.addTarget(self, action: #selector(ChannelUpdatesVC.flagBtnTap(sender:)), for: UIControlEvents.touchUpInside)
        
        let imageViewTap = UITapGestureRecognizer(target:self, action: #selector(ChannelUpdatesVC.beepDetail(img:)))
        cell.tapView.isUserInteractionEnabled = true
        cell.tapView.addGestureRecognizer(imageViewTap)
        
        let descriptionViewTap = UITapGestureRecognizer(target:self, action:#selector(AllTagVC.beepDetail(img:)))
        cell.descriptionLbl.isUserInteractionEnabled = true
        cell.descriptionLbl.addGestureRecognizer(descriptionViewTap)
        
        cell.imgCollectionViewHeightCons.constant = self.beepDimention[indexPath.row]
        cell.imgCollectionView.isHidden   = true
        cell.pageController.isHidden      = true
        self.setTableViewData(cell: cell, indexPath: indexPath)
        cell.contentView.layoutIfNeeded()
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // nitin
        spinner.stopAnimating()
        if self.beepData.count-1 == indexPath.row {
            
            
            self.from = self.from+self.size
            let param: [String: AnyObject] = ["channels" : self.channelId as AnyObject, "from" : self.from as AnyObject, "size" : self.size as AnyObject, "hashtags" : "" as AnyObject]
            if self.nextCount != 0 {
                self.getDashBoardData(param: param)
                spinner.startAnimating()
            } else {
                spinner.stopAnimating()
            }
            
            
        }
        cell.contentView.layoutIfNeeded()
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
                        if let hostName = source["host"] as? String,  !hostName.isEmpty  {
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
            
            /* if let text = beep["text"] as? String {
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


//MARK:- WebService method's
//MARK:-
extension ChannelUpdatesVC {
    
     func getDashBoardData(param: [ String : AnyObject]) {
        
        WebServiceController.getDashboradFeed(url: WS_Dashboard, parameters: param) { (sucess, errorMessage, data) in
            
            if sucess {
                
                if let beepData = data {
                    if beepData.count < 10 && beepData.count == 0 {
                        self.nextCount = 0
                    }
                    for beepss in beepData {
                        
                        if let beep = beepss["beep"] as? [String : AnyObject] {
                            
                            if let hashtags = beep["hashtags"] as? [String] {
                                
                                var arr = [String]()
                                _ = hashtags.map({ (temp: String) in
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
                    if let beeps = data {
                        self.beepData.append(contentsOf: beeps)
                    }
                    
                    if self.beepData.isEmpty {
                        self.noDataLbl.isHidden = false
                    } else  {
                        self.tblView.isHidden = false
                        self.tblView.reloadData()
                    }
                    
                } else {
                    self.tblView.isHidden = true
                }
                
            } else {
                self.tblView.isHidden = true
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

extension ChannelUpdatesVC: ChannelUpdatesVCDelegate {
    
    func beepDataReload() {
        //self.setInitData()
    }
    // nitin
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

extension ChannelUpdatesVC : UITableViewDataSourcePrefetching {
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            let cell = tableView.dequeueReusableCell(withIdentifier: "UserDataCell", for:  indexPath) as! UserDataCell
            self.setTableViewData(cell: cell, indexPath: indexPath)
        }
    }
}

extension ChannelUpdatesVC : shareDelegate {
    func shareData() {
        CommonFunctions.displayShareSheet(shareContent: SHARE_Fantasticoh_URL, viewController: self)
    }
}
