//
//  FansVC.swift
//  Fantasticoh!
//
//  Created by Appinventiv on 06/09/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import UIKit
// nitin
enum VCState {
    
    case None, Personal, Channel, OtherProfile
}

protocol FansVCDelegate : class {
    func fansListUpdate()
    

}

class FansVC: UIViewController  {
    
    //MARK:- @IBOutlet & Properties
    //MARK:-
    @IBOutlet weak var tblView      : UITableView!
    @IBOutlet weak var searchLabel  : UILabel!
    @IBOutlet weak var searchButton : UIButton!
    @IBOutlet weak var noDataLbl    : UILabel!
    var nameArray           = ["Matt Damon", "Virat Kohli", "Narendra Modi"]
    var featureTypeArray    = ["Promoted", "Featured", "Trending"]
    var featureImageArray   = [UIImage(named: "promoted"), UIImage(named: "featured"), UIImage(named: "trending")]
    var userImgArray        = [UIImage(named: "dp1"), UIImage(named: "dp2"), UIImage(named: "dp3")]
    
    var vCState: VCState!
    weak var tabBarDelegate: TabBarDelegate!
    weak var likeVCDelegate: LikesVCDelegate!
    var channelId            = String()
    var fanId                = String()
    var channelfollowersData = [AnyObject]()
    var userFollowList       = [AnyObject]()
    internal var from        = 0
    internal var size        = 10
    var temExploreVC: UIViewController!
    var nextCounter          = -1
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: .white)
    
    
    //MARK:- View Life Cycle
    //MARK:-
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // nitin
        self.spinner.color = CommonColors.globalRedColor()
        self.spinner.startAnimating()
        self.spinner.frame = CGRect(x: 0,y: 0,width: SCREEN_WIDTH,height: 28)
        self.tblView.tableFooterView = spinner
        
        self.tblView.delegate = self
        self.tblView.dataSource = self
        self.tblView.register(UINib(nibName: "FanCellXIB", bundle: nil), forCellReuseIdentifier: "FanCellXIB")
        
        self.spinner.color = CommonColors.globalRedColor()
        self.spinner.startAnimating()
        self.spinner.frame = CGRect(x:0,y: 0,width: SCREEN_WIDTH,height: 20)
        
        // nitin
        
        if self.vCState == .Personal{
            self.noDataLbl.text = CommonTexts.pleaseFollowChannels

        }
        self.initDataSetUp()
        
        //_ = self.is3DTouchAvailable()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK:- @IBAction, Selector &  method's
    //MARK:-
    func initDataSetUp() {
        
        var param = [String: AnyObject]()
        param["from"] = self.from as AnyObject
        param["size"] = self.size as AnyObject
        
        if self.vCState == VCState.Personal {
            if let id = CurrentUser.userId {
                self.getUserFollowChannel(param: param, userId: id)
            }
            
        } else if self.vCState == VCState.OtherProfile {
            self.getUserFollowChannel(param: param, userId: self.fanId)
        } else if self.vCState == VCState.Channel {
            self.getChannelFollowerFans()
            self.noDataLbl.text = CommonTexts.BeTheFirstFan
        }
    }
    
    func fanBtnTap(sender: UIButton) {
        
        guard CommonFunctions.checkLogin() else {
            CommonFunctions.showLoginAlert(vc: self)
            return
        }
        
        let currentRow = sender.tableViewIndexPath(tableView: self.tblView)?.row
        
        print_debug(object: currentRow)
        if let tempChannel = self.userFollowList[currentRow!] as? [String: AnyObject] {
            
            if let channelId = tempChannel["id"] as? String {
                
                if !sender.isSelected {
                    print_debug(object: "oN")
                    CommonFunctions.fanBtnOnFormatting(btn: sender)
                    
                    if let list = UserDefaults.getStringArrayVal(key: NSUserDefaultKeys.FRIENDSLIST) as? [String]{
                        var tempList = list
                        tempList.append(channelId)
                        UserDefaults.setStringVal(value: tempList as AnyObject, forKey: NSUserDefaultKeys.FRIENDSLIST)
                    }
                    
//                    if let unread = self.userFollowList[currentRow!]["isUserFan"] as? Bool, unread == false  {
//                        if var obj = self.userFollowList[currentRow!] as? [String : AnyObject] {
//                            obj["isUserFan"] = true as AnyObject
//                            self.userFollowList[currentRow!] = obj as AnyObject
//                        }
//                    }
                    
                    self.followChannel(channelId: channelId, follow: true)
                    self.showSharePopup(name: tempChannel["name"]  as? String ?? "")
                } else {
                    print_debug(object: "oFF")
//                    if let unread = self.userFollowList[currentRow!]["isUserFan"] as? Bool, unread == true  {
//                        if var obj = self.userFollowList[currentRow!] as? [String : AnyObject] {
//                            obj["isUserFan"] = false as AnyObject
//                            self.userFollowList[currentRow!] = obj as AnyObject
//                        }
//                    }
                    if let list = UserDefaults.getStringArrayVal(key: NSUserDefaultKeys.FRIENDSLIST) as? [String], list.count > 0{
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
                        if tempList.count > index {
                            tempList.remove(at: index)
                        }
                        print_debug(object: "After remove : \(tempList)")
                        UserDefaults.setStringVal(value: tempList as AnyObject, forKey: NSUserDefaultKeys.FRIENDSLIST)
                    }
                    
                    
                    var tempList = [AnyObject]()
                    _  = self.userFollowList.map({ (temp: AnyObject) in
                        if let id = temp["id"] as? String {

                            tempList.append(temp)

//                            if id != channelId {
//                                tempList.append(temp)
//                            }
                        }
                    })
                    
                    self.userFollowList.removeAll(keepingCapacity: false)
                    self.userFollowList = tempList
                    self.tblView.reloadData()
                    CommonFunctions.fanBtnOffFormatting(btn: sender)
                    self.followChannel(channelId: channelId, follow: false)
                }
                sender.isSelected = !sender.isSelected
            }
        }
        
    }
    
    func channelDetail(row: Int) {
        
        print_debug(object: self.userFollowList[row])
        guard let temChannel = self.userFollowList[row] as? [String: AnyObject] else { return }
        guard let channelID = temChannel["id"] as? String else { return }
        print_debug(object: channelID)
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier:"ChannelViewFanVC") as! ChannelViewFanVC
        
        print_debug(object: vc.channelViewFanVCState)
        vc.channelViewFanVCState = ChannelViewFanVCState.ProfileFansVCState
        print_debug(object: vc.channelViewFanVCState)
        vc.allTagVCDelegate = ALLTAGVCDELEGATE
        
        if let nationality = temChannel["displayLabels"] as? [String], nationality.count > 0 {
            vc.displayLabel = nationality
        }
        
        if let dele = TABBARDELEGATE {
            vc.delegate = dele
        }
        vc.channelId = channelID
        vc.fansVCDelegate = self
        if let dele = self.likeVCDelegate {
            vc.likesVCDelegate = dele
        }
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func fansDetails(row: Int) {
        
        guard let data = self.channelfollowersData as? [[String: AnyObject]] else  { return }
        
        guard let uID = data[row]["id"] as? String else { return }
        
        if let id = CurrentUser.userId {
            if uID == id {
                return
            }
        }
        //guard let tempChannel = self.userFollowList[row] as? AnyObject else { return }
        
        let profileVC = self.storyboard?.instantiateViewController(withIdentifier:"ProfileVC") as! ProfileVC
        profileVC.profileVCState = ProfileVCState.OtherProfile
        profileVC.profileUserId = uID
        
        self.navigationController?.pushViewController(profileVC, animated: true)
        
    }
    
    
    func checkIsUserExist() -> Bool{
        if let id = CurrentUser.userId {
            let userExist = self.channelfollowersData.filter { (data) -> Bool in
                
                if let userId = data["id"] as? String, userId == id {
                    return true
                }
                
                return false
            }
            return userExist.count > 0 ? true : false
            
        }
        
        return false
    }
    
    func getUserData() -> [String : AnyObject] {
        var data = [String : AnyObject]()
        data["id"] = CurrentUser.userId as AnyObject
        data["name"] = CurrentUser.name as AnyObject
        data["avatarID"] = CurrentUser.avatarID as AnyObject
        data["avatarURLLarge"] = CurrentUser.avatarExtURL as AnyObject
        data["countFollowing"] = CurrentUser.countFollowing as AnyObject
        
        
        //        {"id":"90b9891fbade41f0","name":"Mohit Singh","tagLine":"","location":null,"locationName":"","country":"us","admin":false,"closed":false,"countFollowing":0,"countViews":0,"avatarID":"90b9891fbade41f0","avatarURL":"https://storage.googleapis.com/vsl-bb-user-avatars.vstarlabs.com/90b9891fbade41f0.jpg","avatarURLLarge":"https://storage.googleapis.com/vsl-bb-user-avatars.vstarlabs.com/90b9891fbade41f0-large.jpg"}
        
        return data
    }
    
    func reloadTableView() {
        self.tblView.reloadData()
    }
    
    func is3DTouchAvailable(view : UIView) -> Bool {
        if #available(iOS 9, *) {
            if self.traitCollection.forceTouchCapability == UIForceTouchCapability.available {
                self.registerForPreviewing(with: self, sourceView: view)
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
    
}

//MARK:- UITableViewDataSource & delegate
//MARK:-
extension FansVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.vCState == VCState.Channel {
            return  self.channelfollowersData.count
        } else {
            return self.userFollowList.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        
        if self.vCState == VCState.Channel {
            let data = self.channelfollowersData
            
            if let id = data[indexPath.row]["id"] as? String {
                if let userId =  CurrentUser.userId, userId == id  {
                    if self.vCState == VCState.Channel {
                        
                        if let list = UserDefaults.getStringArrayVal(key: NSUserDefaultKeys.FRIENDSLIST) as? [String] {
                            print_debug(object: "List Id : \(list)")
                            print_debug(object: "current cell Id : \(channelId)")
                            for temp in list{
                                print_debug(object: "temp Id : \(temp)")
                                if temp == channelId {
                                    self.noDataLbl.isHidden = true
                                    return 65
                                    //break
                                }
                            }
                            
                        }
                        self.noDataLbl.isHidden = self.channelfollowersData.count == 1 ? false : true
                        return 0
                    }
                    // return 0
                }
            }
        }
        return 65
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FanCellXIB", for:  indexPath) as! FanCellXIB
        cell.selectionStyle = .none
        cell.btn.isHidden = false
        cell.grayDot.isHidden = true
        cell.secondCounterLbl.isHidden = true
        cell.redDot.isHidden = true
        cell.featureImageWidthCons.constant = 0
        cell.featureImageView.image = UIImage()
        
        _ = is3DTouchAvailable(view: cell.contentView)
        cell.counterLbl.text = "Fan of 0 channel"
        cell.btn.addTarget(self, action: #selector(FansVC.fanBtnTap(sender:)), for: .touchUpInside)
        
        if self.vCState == VCState.Channel {
            
            cell.btn.isHidden = true
            
            let data = self.channelfollowersData
            
            if let name = data[indexPath.row]["name"] as? String {
                
                cell.nameLbl.text = name
                
            } else {
                
                cell.nameLbl.text = ""
            }
            
            if let nationality = data[indexPath.row]["displayLabels"] as? [String], nationality.count > 0 {
                cell.descriptionLabel.text = nationality.joined(separator: ",") as? String ?? ""
            }
            
            if let counter = data[indexPath.row]["countFollowing"] as? Int {
                
                if counter == 1  {
                    
                    cell.counterLbl.text = "Fan of \(counter) channel"
                    
                } else if counter == 0 {
                    
                    cell.counterLbl.text = "" //"Be the first fan"
                    
                }else {
                    
                    cell.counterLbl.text = "Fan of \(counter) channels"
                }
                
            } else {
                
                cell.counterLbl.text = "Be the first fan"
            }
            
            cell.imgView.contentMode = .center

            if let imgUrl = data[indexPath.row]["avatarURLLarge"] as? String {
                
                if let id = data[indexPath.row]["id"] as? String {
                    
                    if let userId =  CurrentUser.userId, userId == id  {
                        
                        print_debug(object: "user image ************")
                        print_debug(object: imgUrl)
                        
                    }
                }
                
                cell.imgView.sd_setImage(with: URL(string: imgUrl), placeholderImage: AppIconPLACEHOLDER, options: SDWebImageOptions(rawValue: 1), completed: { (image, error, type, url) in
                    
                    cell.imgView.contentMode = .scaleAspectFill
                    
                })
                
            } else {
                
                cell.imgView.image = AppIconPLACEHOLDER
            }
            
        } else {
            cell.btn.isHidden = false
            cell.btn.isSelected = true
            
            CommonFunctions.fanBtnOnFormatting(btn: cell.btn)
            
            if let tempChannel = self.userFollowList[indexPath.row] as? [String: AnyObject] {
                
                print_debug(object: tempChannel)
                
                
                if let currentCellFanId  = tempChannel["id"]  as? String {
                    print_debug(object: "Channel id found.")
                    
                    if let list = UserDefaults.getStringArrayVal(key: NSUserDefaultKeys.FRIENDSLIST) as? [String] {
                        print_debug(object: list)
                        
                        if list.isEmpty {
                            CommonFunctions.fanBtnOffFormatting(btn: cell.btn)
                            cell.btn.isSelected = false
                        } else {
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
                        }
                        
                        
                    } else {
                        CommonFunctions.fanBtnOffFormatting(btn: cell.btn)
                        cell.btn.isSelected = false
                    }
                } else {
                    print_debug(object: "Channel id  not found.")
                }
                
                if let status = tempChannel["isUserFan"] as? Bool, status == true {
                    CommonFunctions.fanBtnOnFormatting(btn: cell.btn)
                    cell.btn.isSelected = true
                }
                
                if let channelName = tempChannel["name"] as? String {
                    cell.nameLbl.text = channelName
                } else {
                    cell.nameLbl.text = ""
                }
                
                if let counter = tempChannel["countFollowers"] as? Int {
                    if counter == 1  {
                        cell.counterLbl.text = "\(counter) Fan"
                    } else if counter == 0 {
                        cell.counterLbl.text = "Be the first fan"
                    }else {
                        cell.counterLbl.text = "\(counter) Fans"
                    }
                    
                } else {
                    cell.counterLbl.text = "Be the first fan"
                }
                cell.imgView.contentMode = .center

                if let imgUrl = tempChannel["avatarURLLarge"] as? String {
                    cell.imgView.sd_setImage(with: URL(string: imgUrl), placeholderImage: AppIconPLACEHOLDER, options: SDWebImageOptions(rawValue: 1), completed: { (image, error, type, url) in
                        cell.imgView.contentMode = .scaleAspectFill
                    })
                } else {
                    cell.imgView.image = AppIconPLACEHOLDER
                }
            }
            
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if self.vCState == VCState.Personal {
            print_debug(object: "In personal channel detail")
            self.channelDetail(row: indexPath.row)
        } else if self.vCState == VCState.OtherProfile {
            print_debug(object: "Other profile channel list")
            self.channelDetail(row: indexPath.row)
        } else if self.vCState == VCState.Channel {
            print_debug(object: "Fans list")
            self.fansDetails(row: indexPath.row)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        self.spinner.stopAnimating()
        if self.vCState == VCState.Channel {
            
            if self.channelfollowersData.count-1 == indexPath.row {
                self.tblView.tableFooterView = spinner
                self.from = self.from+10
                var param = [String: AnyObject]()
                param["from"] = self.from as AnyObject
                param["size"] = self.size as AnyObject
                
                if self.nextCounter != 0 {
                    self.spinner.startAnimating()
                    self.getChannelFollowerFans()
                } else {
                    
                }
            }
            
        } else {
            if self.userFollowList.count-1 == indexPath.row {
                self.tblView.tableFooterView = spinner
                self.from = self.from+10
                var param = [String: AnyObject]()
                param["from"] = self.from as AnyObject
                param["size"] = self.size as AnyObject
                
                if self.nextCounter != 0 {
                    self.spinner.startAnimating()
                    if self.vCState == VCState.Personal {
                        if let uID = CurrentUser.userId {
                            self.getUserFollowChannel(param: param, userId: uID)
                        }
                    } else if self.vCState == VCState.OtherProfile {
                        self.getUserFollowChannel(param: param, userId: self.fanId)
                    }
                } else {
                    
                }
            }
        }
    }
    
    
}

//MARK:- WebService
//MARK:-
extension FansVC {
    
    func getChannelFollowerFans() {
        
        let url = WS_Channel + "/" + channelId + "/" + "followers?from=\(self.from)&size=\(self.size)"
        WebServiceController.getChannelFollowers(url: url) { (sucess, errorMessage, data) in
            
            if sucess {
                if let setData = data {
                    if setData.count < 10 && setData.count == 0 {
                        self.nextCounter = 0
                    }
                    
                    self.channelfollowersData.append(contentsOf: setData)
                    if self.vCState == VCState.Channel {
                        if  self.nextCounter == 0 {
                            if self.checkIsUserExist() == false {
                                print_debug(object: "userExist")
                                self.channelfollowersData.append(self.getUserData() as AnyObject)
                            }
                        }
                    }
                    self.spinner.stopAnimating()
                    
                }
            } else {
                print_debug(object: errorMessage)
            }
            // nitin
            self.noDataLbl.isHidden = self.channelfollowersData.count > 0 ? (self.checkIsUserExist() == true ? false : true) : false
            self.tblView.reloadData()
        }
        
    }
    
    internal func getUserFollowChannel(param: [String: AnyObject], userId: String) {
        
        let url = WS_UserChannelList + "/" + userId + "/following"
        print_debug(object: url)
        WebServiceController.getUserFollowChannels(url: url, param: param) { (sucess, errorMessage, data) in
            
            if sucess {
                if let setData = data  {
                    if setData.count < 10 && setData.count == 0 {
                        self.nextCounter = 0
                    }
                    
                    //                    if self.vCState == VCState.Personal {
                    //                        if self.from == 0 {
                    //                           UserDefaults.standard.removeObjectForKey(NSUserDefaultKeys.FRIENDSLIST)
                    //                        }
                    //                    }
                    // nitin
                    if self.vCState == VCState.Personal {
                        for obj in setData {
                            if let id = obj["id"] as? String {
                                
                                //Save NSUserDefault
                                if let list = UserDefaults.getStringArrayVal(key: NSUserDefaultKeys.FRIENDSLIST) as? [String] {
                                    var tempList = list
                                    print_debug(object: "Old Data : \(tempList)")
                                    if !tempList.contains(id) {
                                        tempList.append(id)
                                        print_debug(object: "New Data : \(tempList)")
                                        UserDefaults.setStringVal(value: tempList as AnyObject, forKey: NSUserDefaultKeys.FRIENDSLIST)
                                        print_debug(object: UserDefaults.getStringArrayVal(key: NSUserDefaultKeys.FRIENDSLIST) as? [String])
                                    }
                                } else {
                                    let id: [String] = [id]
                                    UserDefaults.setStringVal(value: id as AnyObject, forKey: NSUserDefaultKeys.FRIENDSLIST)
                                    print_debug(object: " After \(String(describing: UserDefaults.getStringArrayVal(key: NSUserDefaultKeys.FRIENDSLIST) as? [String]))")
                                }
                            }
                        }
                    }
                    self.userFollowList.append(contentsOf: setData)
                    self.spinner.stopAnimating()
                    self.tblView.reloadData()
                    
                }
            } else {
                self.spinner.stopAnimating()
                print_debug(object: errorMessage)
            }
            // nitin
            self.spinner.stopAnimating()
            // nitin
            self.noDataLbl.isHidden = self.userFollowList.count > 0 ? true : false
            if self.vCState != .OtherProfile{
                self.searchButton.isHidden = self.userFollowList.count > 0 ? true : false
                self.searchLabel.isHidden = self.userFollowList.count > 0 ? true : false

            }else{
                self.searchButton.isHidden = true
                self.searchLabel.isHidden = true
                self.noDataLbl.text = CommonTexts.noResultFound
            }
        }
    }
    
    func followChannel(channelId: String, follow: Bool) {
        
        let params: [String: AnyObject] = ["channelID" : channelId as AnyObject, "virtualChannel" : false as AnyObject, "follow": follow as AnyObject]
        WebServiceController.follwUnfollowChannel(parameters: params) { (sucess, errorMessage, data) in
            
            if sucess {
                if let dele = TABBARDELEGATE {
                    dele.sideMenuUpdate()
                }
                print_debug(object: "You click on follow btn.")
                var param = [String: AnyObject]()
                self.from = 0
                param["from"] = self.from as AnyObject
                param["size"] = self.size as AnyObject
                if self.vCState == VCState.Personal {
                    if CurrentUser.userId != nil {
                        //self.getUserFollowChannel(param, userId: uID)
                    }
                } else if self.vCState == VCState.OtherProfile {
                    //self.getUserFollowChannel(param, userId: self.fanId)
                }
                
            } else {
                print_debug(object: errorMessage)
            }
            
            // nitin
            self.noDataLbl.isHidden = self.userFollowList.count > 0 ? true : false
            self.noDataLbl.isHidden = self.userFollowList.count > 0 ? true : false
            self.searchButton.isHidden = self.userFollowList.count > 0 ? true : false
            self.searchLabel.isHidden = self.userFollowList.count > 0 ? true : false
        }
    }
    
}

extension FansVC : FansVCDelegate {
    // nitin
    func fansListUpdate() {
        if self.vCState == VCState.Channel {
            self.channelfollowersData.removeAll()
        } else {
            self.userFollowList.removeAll()
        }
        self.tblView.reloadData()
        nextCounter = -1
        self.from = 0
        self.size = 10
        self.initDataSetUp()
    }
}


//MARK:- UIViewControllerPreviewingDelegate
//MARK:-
extension FansVC: UIViewControllerPreviewingDelegate {
    @available(iOS 9.0, *)
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        
        guard let indexPath = previewingContext.sourceView.tableViewIndexPath(tableView: self.tblView) else { return  }
        
        // 3 5
        if self.vCState == VCState.Channel {
            self.showUserDetail(index: indexPath.row)
        } else {
            self.showChannelDetail(index: indexPath)
        }
    }

    
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        guard #available(iOS 9.0, *) else { return nil }
        
        guard let indexPath = previewingContext.sourceView.tableViewIndexPath(tableView: self.tblView) else { return nil }
        
        // 3 5
        if self.vCState == VCState.Channel {
            guard let data = self.channelfollowersData as? [[String: AnyObject]] else  { return nil}
            
            //guard let uID = data[indexPath.row]["id"] as? String else { return  nil}
            
            var userImageUrl = ""
            var userName = ""
            if let imgUrl = data[indexPath.row]["avatarURLLarge"] as? String {
                userImageUrl = imgUrl
            }
            if let name = data[indexPath.row]["name"] as? String {
                userName = name
            }
            
            let userPreviewVC = self.storyboard?.instantiateViewController(withIdentifier:"UserPreviewVC") as! UserPreviewVC
            userPreviewVC.userName = userName
            userPreviewVC.userImgUrl = userImageUrl
            userPreviewVC.UserPreviewVCDelegate = self
            userPreviewVC.index = indexPath.row
            userPreviewVC.preferredContentSize = CGSize(width: SCREEN_WIDTH, height: 185)
            
            return userPreviewVC
            
        } else {
            
            guard let channelID = self.userFollowList[indexPath.row]["id"] as? String else { return nil }
            
            var isFriend = false
            if let list = UserDefaults.getStringArrayVal(key: NSUserDefaultKeys.FRIENDSLIST) as? [String] {
                isFriend = list.contains(channelID)
            }
            
            let channelPreviewVC = self.storyboard?.instantiateViewController(withIdentifier:"ChannelPreviewVC") as! ChannelPreviewVC
            
            if let avatarURL = self.userFollowList[indexPath.row]["avatarURL"] as? String {
                channelPreviewVC.channelImgUrl = avatarURL
            }
            
            if isFriend {
                channelPreviewVC.msg = "Unfollow"
            } else {
                channelPreviewVC.msg = "Become a Fan"
            }
            
            if let name = self.userFollowList[indexPath.row]["name"] as? String {
                channelPreviewVC.channelName = name
            }
            var height = 185.0
            if let desc = self.userFollowList[indexPath.row]["desc"] as? String {
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
        
    }
    
    
    
}

extension FansVC : UserPreviewVCDelegate {
    
    func showUserChat(index: Int) {
        
        guard CommonFunctions.checkLogin() else {
            CommonFunctions.showLoginAlert(vc: self)
            return
        }
        guard let otherUserDetail = self.channelfollowersData[index] as? [String : AnyObject] else {
            return
        }
        
        if otherUserDetail.isEmpty { return }
        let vc = self.storyboard?.instantiateViewController(withIdentifier:"UserChatVC") as! UserChatVC
        vc.toUserDetail = otherUserDetail
        vc.openFromChat = OpenFromChat.Channel
        let navVC = UINavigationController(rootViewController: vc)
        navVC.navigationBar.isHidden = true
        self.present(navVC, animated: true, completion: nil)
        
    }
    
    func showUserDetail(index: Int) {
        self.fansDetails(row: index)
    }
}

extension FansVC : ChannelPreviewVCDelegate {
    func showChannelDetail(index: IndexPath) {
        
        
        guard let channelID = self.userFollowList[index.row]["id"] as? String else {
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
extension FansVC : shareDelegate {
    func shareData() {
        CommonFunctions.displayShareSheet(shareContent: SHARE_Fantasticoh_URL, viewController: self)
    }
}
