//
//  SuggestedChannelsVC.swift
//  Fantasticoh!
//
//  Created by Appinventiv on 05/09/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import UIKit
enum SuggestedChannelsVCState {
    case None, AllTagVCState, SideMenuState
}

protocol SuggestedChannelVCDelegate : class {
    func dataUpdate(index: Int)
    func afterSearchChannelDataReset()
}

class SuggestedChannelsVC: UIViewController {
    
    //MARK:- @IBOutlet & Propertie's
    //MARK:-
    @IBOutlet weak var tblView: UITableView!
    
    weak var delegate: TabBarDelegate!
    weak var allTagVCDelegate: AllTagVCDelegate!
    var userImgArray =  [UIImage(named: "dp1"), UIImage(named: "dp2"), UIImage(named: "dp3")]
    
    var featureChannel = [String: AnyObject]()
    var suggestedChannelsVCState = SuggestedChannelsVCState.None
    var nowIsFollow = false
    var imgArrayURL: [[String : Array<String>]]!
    
    //MARK:- View Life Cycle
    //MARK:-
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tblView.delegate = self
        self.tblView.dataSource = self
        
        let fanClubeCell = UINib(nibName: "FanCellXIB", bundle: nil)
        self.tblView.register(fanClubeCell, forCellReuseIdentifier: "FanCellXIB")
        
        let suggestedChannelsPicCellXIB = UINib(nibName: "SuggestedChannelsPicCellXIB", bundle: nil)
        self.tblView.register(suggestedChannelsPicCellXIB, forCellReuseIdentifier: "SuggestedChannelsPicCellXIB")
        
        self.getFeatureChannelList()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        print("deinit") // never gets called
    }
    
    //MARK:- @IBAction, Selector & Private method's
    //MARK:-
    @IBAction func menuBtnTap(sender: UIButton) {
        
        if self.suggestedChannelsVCState == SuggestedChannelsVCState.AllTagVCState {
            //USE
            self.navigationController?.popViewController(animated: true)
            if self.nowIsFollow {
                if let dele = ALLTAGVCDELEGATE {
                    dele.beepDataReload()
                }
            }
        } else if self.suggestedChannelsVCState == SuggestedChannelsVCState.SideMenuState {
            //USE
            self.navigationController?.popViewController(animated: true)
            if self.nowIsFollow {
                if let dele = ALLTAGVCDELEGATE {
                    dele.beepDataReload()
                }
            }
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func searchBtnTap(sender: UIButton) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier:"SearchChannelVC") as! SearchChannelVC
        vc.previoudDataIsAvalible = PrevioudDataIsAvalible.Avalible
        vc.searchChannelVCState = SearchChannelVCState.SuggestedChannelsVC
        vc.featureChannel = self.featureChannel
        vc.multiDelegate = self
        let navVC = UINavigationController(rootViewController: vc)
        navVC.navigationBar.isHidden = true
        self.present(navVC, animated: true) {
            APP_DELEGATE.statusBarStyle = UIStatusBarStyle.default
        }
    }
    
    func fanBtnTap(sender: UIButton) {
        guard CommonFunctions.checkLogin() else {
            CommonFunctions.showLoginAlert(vc: self)
            return
        }
        guard let index = sender.tableViewIndexPath(tableView: self.tblView) else { return }
        self.nowIsFollow = true
        let currentRow = index.row/2
        if var result = self.featureChannel["results"] as? [AnyObject] {
            
            if let channelID = result[currentRow]["id"] as? String {
                
                print_debug(object: channelID)
                if !sender.isSelected {
                    print_debug(object: "oN")
                    CommonFunctions.fanBtnOnFormatting(btn: sender)
                    self.followChannel(channelId: channelID, follow: true)
                    self.showSharePopup(name: result[currentRow]["name"]  as? String ?? "")
                    if var data = result[currentRow] as? [String : Any] {
                        data["isUserFan"] = true
                        result[currentRow] = data as AnyObject
                        self.featureChannel["results"] = result as AnyObject
                    }
                    
                } else {
                    print_debug(object: "oFF")
                    CommonFunctions.fanBtnOffFormatting(btn: sender)
                    self.followChannel(channelId: channelID, follow: false)
                    if var data = result[currentRow] as? [String : Any] {
                        data["isUserFan"] = false
                        result[currentRow] = data as AnyObject
                        self.featureChannel["results"] = result as AnyObject
                    }
                }
                
            }
        }
        
        sender.isSelected = !sender.isSelected
    }
    
    func fansDetails(row: Int) {
        
        if let result = self.featureChannel["results"] as? [AnyObject] {
            
            if let channelID = result[row]["id"] as? String {
                
                let vc = self.storyboard?.instantiateViewController(withIdentifier:"ChannelViewFanVC") as! ChannelViewFanVC
                
                if let nationality = result[row]["displayLabels"] as? [String], nationality.count > 0 {
                    vc.displayLabel = nationality
                }
                
                if let dele = self.delegate {
                    vc.delegate = dele
                }
                vc.suggestedChannelVCDelegate = self
                vc.channelViewFanVCState = ChannelViewFanVCState.SuggestedChannelVCState
                vc.channelId = channelID
                vc.previousSelectedIndex = row
               
                self.navigationController?.pushViewController(vc, animated: true)
                
            }
        }
        
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


//MARK:- UITableView Delegate & DataSource extension
//MARK:-
extension SuggestedChannelsVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let result = self.featureChannel["results"] as? [AnyObject] {
            return (result.count * 2)
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if (indexPath.row % 2 == 0) {
            return 65
        } else  {
            return 105
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row % 2 == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "FanCellXIB", for:  indexPath) as! FanCellXIB
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            cell.grayDot.isHidden = true
            cell.secondCounterLbl.isHidden = true
            cell.redDot.isHidden = true
            _ = is3DTouchAvailable(btn: cell.contentView)
            if let result = self.featureChannel["results"] as? [AnyObject] {
                
                cell.nameLbl.text = result[indexPath.row/2]["name"]  as? String ?? ""
                
                if let nationality = result[indexPath.row/2]["displayLabels"] as? [String], nationality.count > 0 {
                    cell.descriptionLabel.text = nationality.joined(separator: ",") as? String ?? ""
                }
                
                if let imgUrl = result[indexPath.row/2]["avatarURLLarge"] as? String {
                    
                    cell.imgView.sd_setImage(with: URL(string: imgUrl), placeholderImage: CHANNELLOGOPLACEHOLDER)
                    
                } else {
                    
                    cell.imgView.image = CHANNELLOGOPLACEHOLDER
                }
                
                if let featuredLabel = result[indexPath.row/2]["featuredLabel"] as? String{
                    cell.counterLbl.text = featuredLabel
                    
                } else {
                    cell.counterLbl.text = "Featured"
                }
                
                if let currentCellFanId  = result[indexPath.row/2]["id"]  as? String {
                    if let list = UserDefaults.getStringArrayVal(key: NSUserDefaultKeys.FRIENDSLIST) as? [String] {
                        print_debug(object: "List Id : \(list)")
                        print_debug(object: "current cell Id : \(currentCellFanId)")
                        for temp in list{
                            print_debug(object: "temp Id : \(temp)")
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
                    
                    if let status = result[indexPath.row/2]["isUserFan"] as? Bool, status == true {
                        CommonFunctions.fanBtnOnFormatting(btn: cell.btn)
                        cell.btn.isSelected = true
                    }
                    
                } else {
                    CommonFunctions.fanBtnOffFormatting(btn: cell.btn)
                    cell.btn.isSelected = false
                    
                }
                
            }
            
            cell.featureImageView.image = UIImage(named: "featured")
            
            cell.bottomView.isHidden = true
            cell.btn.addTarget(self, action: #selector(SuggestedChannelsVC.fanBtnTap(sender:)), for: .touchUpInside)
            
            return cell
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "SuggestedChannelsPicCellXIB", for:  indexPath) as! SuggestedChannelsPicCellXIB
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            
            cell.firstImageView.image = CONTAINERPLACEHOLDER
            cell.firstImageView.contentMode = .center
            
            cell.secondImageView.image = CONTAINERPLACEHOLDER
            cell.secondImageView.contentMode = .center
            
            cell.thirdImageView.image = CONTAINERPLACEHOLDER
            cell.thirdImageView.contentMode = .center
            if let result = self.featureChannel["results"] as? [AnyObject] {
                print(result[indexPath.row/2]["featuredBeeps"])
            }
            
            
            if let temp = self.imgArrayURL[indexPath.row/2] as? AnyObject {
                print_debug(object: temp)
                if let imgArr = temp["\(indexPath.row/2)"] as? [String] {
                    
                    if let img = imgArr[0] as? String {
                        //cell.firstImageView.image = UIImage(named: img)
//                        SDWebImageManager.shared().imageDownloader?.downloadImage(with: URL(string: img), options: [], progress: nil, completed: {[weak self] (image, data, error, succes) in
//
//                            guard self != nil else {return}
//
//
//                            if let newimage = image {
//                                cell.firstImageView.image = newimage
//                                cell.firstImageView.contentMode = .scaleAspectFill
//                            } else {
//                                cell.firstImageView.image = CONTAINERPLACEHOLDER
//                                cell.firstImageView.contentMode = .center
//                            }
//
//
//                        })
                        weak var weakCell = cell
                        weakCell?.firstImageView.sd_setImage(with: URL(string: img), placeholderImage: CONTAINERPLACEHOLDER, options: .progressiveDownload, completed: { [weak self] (image, error, cacheType, imageURL) in
                            guard self != nil else {return}
                            if image == nil {
                                weakCell?.firstImageView.image = CONTAINERPLACEHOLDER
                                weakCell?.firstImageView.contentMode = .center
                                
                            } else {
                                weakCell?.firstImageView.image = image
                                weakCell?.firstImageView.contentMode = .scaleAspectFill
                            }
                        })
                        
                        // cell.firstImageView.sd_setImage(with: URL(string: img), placeholderImage: CONTAINERPLACEHOLDER)
                    } else {
                        cell.firstImageView.image = CONTAINERPLACEHOLDER
                        cell.firstImageView.contentMode = .center
                    }
                    if let img = imgArr[1] as? String {
                        //cell.secondImageView.sd_setImage(with: URL(string: img), placeholderImage: CONTAINERPLACEHOLDER)
                        
//                        SDWebImageManager.shared().imageDownloader?.downloadImage(with: URL(string: img), options: [], progress: nil, completed: { [weak self] (image, data, error, succes) in
//
//                            guard self != nil else {return}
//
//                            if let newimage = image {
//                                cell.secondImageView.image = newimage
//                                cell.secondImageView.contentMode = .scaleAspectFill
//                            } else {
//                                cell.secondImageView.image = CONTAINERPLACEHOLDER
//                                cell.secondImageView.contentMode = .center
//                            }
//
//
//                        })
                        weak var weakCell = cell
                        weakCell?.secondImageView.sd_setImage(with: URL(string: img), placeholderImage: CONTAINERPLACEHOLDER, options: .progressiveDownload, completed: { [weak self] (image, error, cacheType, imageURL) in
                            guard self != nil else {return}
                            if image == nil {
                                weakCell?.secondImageView.image = CONTAINERPLACEHOLDER
                                weakCell?.secondImageView.contentMode = .center
                                
                            } else {
                                weakCell?.secondImageView.image = image
                                weakCell?.secondImageView.contentMode = .scaleAspectFill
                            }
                        })
                        
                    } else {
                        cell.secondImageView.image = CONTAINERPLACEHOLDER
                        cell.secondImageView.contentMode = .center
                    }
                    if let img = imgArr[2] as? String {
                        //cell.thirdImageView.sd_setImage(with: URL(string: img), placeholderImage: CONTAINERPLACEHOLDER)
                        
//                        SDWebImageManager.shared().imageDownloader?.downloadImage(with: URL(string: img), options: [], progress: nil, completed: { [weak self] (image, data, error, succes) in
//
//                            guard self != nil else {return}
//
//                            if let newimage = image {
//                                cell.thirdImageView.image = newimage
//                                cell.thirdImageView.contentMode = .scaleAspectFill
//                            } else {
//                                cell.thirdImageView.image = CONTAINERPLACEHOLDER
//                                cell.thirdImageView.contentMode = .center
//                            }
//                            // }
//
//                        })
                        
                        weak var weakCell = cell
                        weakCell?.thirdImageView.sd_setImage(with: URL(string: img), placeholderImage: CONTAINERPLACEHOLDER, options: .progressiveDownload, completed: { [weak self] (image, error, cacheType, imageURL) in
                            guard self != nil else {return}
                            if image == nil {
                                weakCell?.thirdImageView.image = CONTAINERPLACEHOLDER
                                weakCell?.thirdImageView.contentMode = .center
                                
                            } else {
                                weakCell?.thirdImageView.image = image
                                weakCell?.thirdImageView.contentMode = .scaleAspectFill
                            }
                        })
                        
                    } else {
                        cell.thirdImageView.image = CONTAINERPLACEHOLDER
                        cell.thirdImageView.contentMode = .center
                    }
                }
                else {
                    self.setImg(cell: cell)
                }
            } else {
                self.setImg(cell: cell)
            }
            return cell
        }
        
    }
    
    private func setImg(cell: SuggestedChannelsPicCellXIB){
        cell.firstImageView.image = CONTAINERPLACEHOLDER
        cell.secondImageView.image = CONTAINERPLACEHOLDER
        cell.thirdImageView.image = CONTAINERPLACEHOLDER
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let row = indexPath.row/2
        self.fansDetails(row: row)
    }
}


//MARK:- Webservice method's
//MARK:-
extension SuggestedChannelsVC {
    
   /* func getFeatureChannelList() {
        
        CommonFunctions.showLoader()
        let params = ["from" : 0, "size" : 100 ]
        WebServiceController.getFeatureChannelList(parameters: params as [String : AnyObject]) { (success, errorMessage, data) in
            
            if success {
                
                if let channels = data {
                    self.featureChannel = channels
                    guard let totalCount = self.featureChannel["total"] as? Int else { return }
                    self.imgArrayURL = [[String : Array<String>]]()
                    for i in 0..<totalCount {
                        let val = [ "\(i)" : [ "content_placeholder", "content_placeholder", "content_placeholder"] ]
                        self.imgArrayURL.append(val)
                    }
                    
                    self.tblView.reloadData()
                    
                    _ = QOS_CLASS_BACKGROUND
                    let backgroundQueue = DispatchQueue(label: "queuename", attributes: .concurrent)
                    backgroundQueue.async(execute: {
                        //print("This is run on the background queue")
                        //self.getChannelImages(count: totalCount)
                    })
                    
                    
                    
                    
                    
                } else {
                    print_debug(object: errorMessage)
                }
                
            } else {
                print_debug(object: errorMessage)
            }
            CommonFunctions.hideLoader()
        }
        
    }*/
    
    func getFeatureChannelList() {
        CommonFunctions.showLoader()
        let params = ["from" : 0, "size" : 100,"previewBeeps" : true, "includeFollowCount": true,"featuredCountries": "us"] as [String : Any]
        WebServiceController.getNewFeatureChannelList(parameters: params as [String : AnyObject]) { (success, errorMessage, data) in
            
            if success {
                
                if let channels = data {
                    self.featureChannel = channels
                    guard let results = self.featureChannel["results"] as? [AnyObject] else { return }
                    let totalCount = results.count
                    
                    self.imgArrayURL = [[String : Array<String>]]()
                    for i in 0..<totalCount {
                        if let featuredBeeps = results[i]["featuredBeeps"] as? [[String : AnyObject]],featuredBeeps.count >= 3   {
                            
                            let val = [ "\(i)" : [ featuredBeeps[0]["imageURL"] as? String ?? "", featuredBeeps[1]["imageURL"] as? String ?? "", featuredBeeps[2]["imageURL"] as? String ?? ""] ]
                            self.imgArrayURL.append(val)

                            
                        } else {
                            let val = [ "\(i)" : [ "content_placeholder", "content_placeholder", "content_placeholder"] ]
                            self.imgArrayURL.append(val)
                            
                        }
                    }
                    for i in 0..<totalCount {
                        let val = [ "\(i)" : [ "content_placeholder", "content_placeholder", "content_placeholder"] ]
                        self.imgArrayURL.append(val)
                    }
                    
                    self.tblView.reloadData()
                    
                    _ = QOS_CLASS_BACKGROUND
                    let backgroundQueue = DispatchQueue(label: "queuename", attributes: .concurrent)
                    backgroundQueue.async(execute: {
                        //print("This is run on the background queue")
                        //self.getChannelImages(count: totalCount)
                    })
                } else {
                    print_debug(object: errorMessage)
                }
                
            } else {
                print_debug(object: errorMessage)
            }
            CommonFunctions.hideLoader()
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
    
    func getChannelImages(count: Int) {
        
        for i in 0..<count {
            guard let result = self.featureChannel["results"] as? [AnyObject] else { return }
            guard result.count > i else { return }
            guard let channelID = result[i]["id"] as? String else  { return }
            
            var param = [String : AnyObject]()
            param["channels"]                  = channelID as AnyObject
            param["hashtags"]                  = "" as AnyObject
            param["from"]                      = 0 as AnyObject
            param["size"]                      = 3 as AnyObject
            
            let url = WS_beeps + "feed"
            
            
            WebServiceController.getDashboradFeed(url: url, parameters: param) { (sucess, errorMessage, data) in
                
                if sucess {
                    
                    print_debug(object: data)
                    if let beepData = data {
                        var imgArr = [String]()
                        
                        //for (index, element) in list.enumerated() {
                        for beepss in beepData {
                            
                            print_debug(object: beepss)
                            if let meta = beepss["meta"] as? [String : AnyObject] {
                                if let tempBeepMedia = meta["beepMedia"] as? [AnyObject]  {
                                    
                                    if tempBeepMedia.count == 0 {
                                        imgArr.append("")
                                    } else {
                                        if let beepMedia = tempBeepMedia.first {
                                            
                                            print_debug(object: beepMedia)
                                            if let urls = beepMedia["imgURLs"] as? [String : AnyObject] {
                                                if let url = urls["img2x"] as? String {
                                                    imgArr.append(url)
                                                } else {
                                                    imgArr.append("")
                                                }
                                            } else {
                                                imgArr.append("")
                                            }
                                        } else {
                                            imgArr.append("")
                                        }
                                    }
                                    
                                } else {
                                    imgArr.append("")
                                }
                            }
                        }
                        self.imgArrayURL[i]["\(i)"] = imgArr
                    }
                    
                    //print_debug(object: self.imgArrayURL)
                    _ = IndexPath(row: i+1, section: 0)
                    
                    
                    _ = QOS_CLASS_BACKGROUND
                    //let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
                    DispatchQueue.main.async(execute: { () -> Void in
                        //self.tblView.reloadRows(at: [ind], with: .none)
                        self.tblView.reloadData()
                    })
                    
                    
                    
                }
            }
            //var userImgArray =  [UIImage(named: "dp1")
        }
        
        
    }
}


//MARK: Delegate extension
extension SuggestedChannelsVC: SuggestedChannelVCDelegate{
    
    func dataUpdate(index: Int) {
        
        self.tblView.reloadData()
        /*
         print_debug(object: index)
         if index/2 == 0{
         self.tblView.reloadRows(at: [IndexPath(row: index, inSection: 0)], with: .None)
         } else {
         self.tblView.reloadRows(at: [IndexPath(row: index-1, inSection: 0)], with: .None)
         } */
        
    }
    
    func afterSearchChannelDataReset() {
        self.getFeatureChannelList()
    }
}


//MARK:- UIViewControllerPreviewingDelegate
//MARK:-
extension SuggestedChannelsVC: UIViewControllerPreviewingDelegate {
    @available(iOS 9.0, *)
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        guard let indexPath = previewingContext.sourceView.tableViewIndexPath(tableView: self.tblView) else { return  }
        let row = indexPath.row/2
        self.fansDetails(row: row)
    }
    
    
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        guard #available(iOS 9.0, *) else { return nil }
        
        guard let indexPath = previewingContext.sourceView.tableViewIndexPath(tableView: self.tblView) else { return nil }
        
        // 3 5
        
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



extension SuggestedChannelsVC : ChannelPreviewVCDelegate {
    func showChannelDetail(index: IndexPath) {
        self.fansDetails(row: index.row)
    }
}

extension SuggestedChannelsVC : shareDelegate {
    func shareData() {
        CommonFunctions.displayShareSheet(shareContent: SHARE_Fantasticoh_URL, viewController: self)
    }
}
