//
//  TrendingChannelsVC.swift
//  Fantasticoh!
//
//  Created by Appinventiv on 03/11/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import UIKit
import SkeletonView


class TrendingChannelsVC: UIViewController {
    
    //MARK:- @IBOutlet & Properties
    //MARK:-
    
    @IBOutlet weak var tableView: UITableView!
    var featureChannel = [AnyObject]()
    var featuredBeep = [AnyObject]()
    var selectedIndex: IndexPath!
    var noDetail:Bool = false
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: .white)
    var from = 0
    let size = 40
    var nextCount  = 1
    var requestComplete = false
    //MARK:- View life cycle
    //MARK:-
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // nitin
        
        self.spinner.color = CommonColors.globalRedColor()
        self.spinner.startAnimating()
        self.spinner.frame = CGRect(x:0,y: 0,width: SCREEN_WIDTH,height: 28)
        self.tableView.tableFooterView = spinner
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        let fanClubeCell = UINib(nibName: "FanCellXIB", bundle: nil)
        self.tableView.register(fanClubeCell, forCellReuseIdentifier: "FanCellXIB")
        
        //Arvind Rawat
        let fanPreviewCell = UINib(nibName: "ChannelPhotosTableViewCell", bundle: nil)
        self.tableView.register(fanPreviewCell, forCellReuseIdentifier: "ChannelPhotosTableViewCell")
        
        
        //************
        
        //self.getFeatureChannelList()      
        Globals.setScreenName(screenName: "TrendingChannels", screenClass: "TrendingChannels")
        self.tableView.isScrollEnabled = false
        self.getFeatureChannelList(from: self.from, size: self.size)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        APP_DELEGATE.statusBarStyle = UIStatusBarStyle.lightContent
        if let index = self.selectedIndex{
            
            self.tableView.reloadRows(at: [index], with: .none)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    //MARK:- Private mehtod's & Selectors
    //MARK:-
    func fanBtnTap(sender: UIButton) {
        guard CommonFunctions.checkLogin() else {
            CommonFunctions.showLoginAlert(vc: self)
            return
        }
        let currentRow = sender.tableViewIndexPath(tableView: self.tableView)!.section
        // if let result = self.featureChannel["results"] as? [AnyObject] {
        
        if let channelID = featureChannel[currentRow]["id"] as? String {
            
            print_debug(object: channelID)
            if !sender.isSelected {
                print_debug(object: "oN")
                CommonFunctions.fanBtnOnFormatting(btn: sender)
                self.followChannel(channelId: channelID, follow: true)
                self.showSharePopup(name: featureChannel[currentRow]["name"]  as? String ?? "")
            } else {
                print_debug(object: "oFF")
                CommonFunctions.fanBtnOffFormatting(btn: sender)
                self.followChannel(channelId: channelID, follow: false)
            }
            
        }
        // }
        
        sender.isSelected = !sender.isSelected
    }
    
    func channelDetails(row: Int) {
        
        // guard let result = self.featureChannel["results"] as? [AnyObject] else { return }
        guard let channelID = self.featureChannel[row]["id"] as? String else { return }
        let vc = self.storyboard?.instantiateViewController(withIdentifier:"ChannelViewFanVC") as! ChannelViewFanVC
        vc.channelViewFanVCState = ChannelViewFanVCState.TrendingTabVC
        //vc.allTagVCDelegate = self
        if let dele = TABBARDELEGATE {
            vc.delegate = dele
        }
        vc.channelId = channelID
        if let nationality = self.featureChannel[row]["displayLabels"] as? [String], nationality.count > 0 {
            vc.displayLabel = nationality
        }
        self.navigationController?.pushViewController(vc, animated: true)
        
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

// MARK: - Table view data source
// MARK:-
extension TrendingChannelsVC : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return self.requestComplete == true ? self.featureChannel.count : 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
//        return self.requestComplete == true ? self.featureChannel.count : Int(tableView.frame.size.height/65) + 1
        
        //Arvind Rawat
        return 2 //self.requestComplete == true ? self.featureChannel.count * 2 : 0//Int(tableView.frame.size.height/65) + 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
         if indexPath.row == 0 {
            return 65
            
         }else{
            
            if noDetail == true{
                return 0
            }else{
                return 150
            }
            
            
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
       if indexPath.row == 0 {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FanCellXIB", for:  indexPath) as! FanCellXIB
        cell.contentView.showAnimatedGradientSkeleton()
        // Configure the cell...
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.grayDot.isHidden = true
        cell.secondCounterLbl.isHidden = true
        cell.redDot.isHidden = true
        if self.requestComplete == false {
            // cell.nameLbl.text = "testing user"
            //            cell.counterLbl.text = "Featured"
            //            cell.imgView.image = CHANNELLOGOPLACEHOLDER
            cell.btn.isHidden = true
            return cell
        } else {
            cell.nameLbl.stopSkeletonAnimation()
            cell.counterLbl.stopSkeletonAnimation()
            cell.imgContainerView.stopSkeletonAnimation()
        }
        cell.btn.isHidden = false
        cell.contentView.hideSkeleton()
        // if let result = self.featureChannel["results"] as? [AnyObject] {
        cell.nameLbl.text = self.featureChannel[indexPath.section]["name"]  as? String ?? ""
        
        if let nationality = self.featureChannel[indexPath.row]["displayLabels"] as? [String], nationality.count > 0 {
            cell.descriptionLabel.text = nationality.joined(separator: ",") as? String ?? ""
        }
        
        if let imgUrl = self.featureChannel[indexPath.section]["avatarURLLarge"] as? String {
            
            cell.imgView.sd_setImage(with: URL(string: imgUrl), placeholderImage: CHANNELLOGOPLACEHOLDER)
            
        } else {
            
            cell.imgView.image = CHANNELLOGOPLACEHOLDER
        }
        
        if let featuredLabel = self.featureChannel[indexPath.section]["featuredLabel"] as? String, !featuredLabel.isEmpty{
            cell.counterLbl.text = featuredLabel
            
        } else {
            cell.counterLbl.text = "Featured"
        }
        
        if let currentCellFanId  = self.featureChannel[indexPath.section]["id"]  as? String {
            
            if let list = UserDefaults.getStringArrayVal(key: NSUserDefaultKeys.FRIENDSLIST) as? [String] {
                
                print_debug(object: "List Id : \(list)")
                
                print_debug(object: "current cell Id : \(currentCellFanId)")
                
                if list.contains(currentCellFanId){
                    
                    CommonFunctions.fanBtnOnFormatting(btn: cell.btn)
                    
                    cell.btn.isSelected = true

                }else{
                    
                    CommonFunctions.fanBtnOffFormatting(btn: cell.btn)
                    
                    cell.btn.isSelected = false

                }
                
//                for temp in list{
//
//                    print_debug(object: "temp Id : \(temp)")
//
//                    if temp == currentCellFanId {
//
//                        CommonFunctions.fanBtnOnFormatting(btn: cell.btn)
//
//                        cell.btn.isSelected = true
//
//                        break
//
//                    } else {
//                        CommonFunctions.fanBtnOffFormatting(btn: cell.btn)
//                        cell.btn.isSelected = false
//                    }
//                }
                
            } else {
                CommonFunctions.fanBtnOffFormatting(btn: cell.btn)
                cell.btn.isSelected = false
            }
            
//            if let status = self.featureChannel[indexPath.row/2]["isUserFan"] as? Bool, status == true {
//                CommonFunctions.fanBtnOnFormatting(btn: cell.btn)
//                cell.btn.isSelected = true
//            }
            
        } else {
            CommonFunctions.fanBtnOffFormatting(btn: cell.btn)
            cell.btn.isSelected = false
            
        }
        
        // }
        
        
        
        cell.featureImageView.image = UIImage(named: "featured")
        
        cell.bottomView.isHidden = true
        cell.btn.addTarget(self, action: #selector(TrendingChannelsVC.fanBtnTap(sender:)), for: .touchUpInside)
        
        return cell
       }else{
        
         let cell = tableView.dequeueReusableCell(withIdentifier: "ChannelPhotosTableViewCell", for:  indexPath) as! ChannelPhotosTableViewCell
        
        cell.bottomBtn.isHidden   = true
        cell.headerLabel.isHidden = true
      cell.pushControldelegate = self
        cell.flow = .Trending
        
        if let featuredBeeps = featureChannel[indexPath.section]["featuredBeeps"] as? [AnyObject]{
        cell.featureChannel = featuredBeeps
             noDetail = false
        }else{
            noDetail = true
        }
       // cell.photosCollectionView.reloadData()
        return cell
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if self.featureChannel.count - 1 == indexPath.section {
            self.from = self.from+self.size
            
            if self.nextCount != 0 {
                self.spinner.startAnimating()
                self.getFeatureChannelList(from: self.from, size: self.size)
            } else {
                self.spinner.stopAnimating()
            }
        }
        
        cell.clipsToBounds = true
        cell.contentView.layoutIfNeeded()
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.requestComplete == false {
            return
        }
        if indexPath.row == 0{
            self.selectedIndex = indexPath
            self.channelDetails(row: indexPath.section)
        }
    }
    
}

// MARK: - Webservice methods
// MARK:-
extension TrendingChannelsVC:PushController {
   
    func pushHandleController(indexPath: IndexPath, videos: [ChannelPhotosAndVideos]) {//OPTIONAL PROTOCOL
        
    }
    
    func pushHandleForTrending(indexPath: IndexPath, videos: [AnyObject]) {
        
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier:"BeepDetailVC") as! BeepDetailVC
        vc.beepVCState = BeepVCState.AllTagVCState
        vc.hasTags = []
        vc.beepData =  ["beep" : videos[indexPath.item]] as AnyObject
        vc.from = indexPath.row
        self.navigationController?.pushViewController(vc, animated: true)
    }

    
    
    
    
    
    
    func getFeatureChannelList(from: Int, size: Int) {
        
        //CommonFunctions.showLoader()
        let params = ["from" : from, "size" : size, "previewBeeps":true] as [String : AnyObject]
        
        WebServiceController.getTrendingChannelList(parameters: params as [String : AnyObject]) { (success, errorMessage, data) in
            
            
            if success {
                
                if let channels = data?["results"] as? [AnyObject] {
                    
                    if channels.count < self.size && channels.count == 0 {
                        self.nextCount = 0
                        self.spinner.stopAnimating()
                    }
                    self.spinner.stopAnimating()
                    self.featureChannel.append(contentsOf: channels)
                  
                    
                    
                } else {
                    print_debug(object: errorMessage)
                }
               
               
                
                
                
            } else {
                print_debug(object: errorMessage)
            }
            self.requestComplete = true
            self.tableView.isScrollEnabled = true
            self.tableView.reloadData()
            CommonFunctions.hideLoader()
            self.spinner.stopAnimating()
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
                    if let list = UserDefaults.getStringArrayVal(key: NSUserDefaultKeys.FRIENDSLIST) as? [String], !list.isEmpty {
                        
                        var tempList = list
                        
                        tempList = tempList.filter({$0 != channelId})
//                        var index = 0
//                        for tempChannelId in tempList {
//                            if tempChannelId == channelId {
//                                break
//                            }
//                            index = index + 1
//                        }
//                        
//                        tempList.remove(at: index)
                        UserDefaults.setStringVal(value: tempList as AnyObject, forKey: NSUserDefaultKeys.FRIENDSLIST)
                    }
                }
                
            } else {
                print_debug(object: errorMessage)
            }
        }
    }
}

extension TrendingChannelsVC : shareDelegate {
    func shareData() {
        CommonFunctions.displayShareSheet(shareContent: SHARE_Fantasticoh_URL, viewController: self)
    }
}
extension TrendingChannelsVC: SkeletonTableViewDataSource {
    
    
    
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdenfierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return "FanCellXIB"
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.requestComplete == true ? 0 : Int(tableView.frame.size.height/65) + 1
    }
}


