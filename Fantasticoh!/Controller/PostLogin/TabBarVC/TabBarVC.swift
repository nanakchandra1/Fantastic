//
//  TabBarVC.swift
//  Fantasticoh!
//
//  Created by Appinventiv on 17/08/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

// nitin
import UIKit

//MARK:- Protocol
//MARK:-
protocol TabBarDelegate : class {
    
    func menuBtnTap(sender: UIButton, delegate: HomeVCDelegate)
    
    func tagBtnTap(tag: String, state: SetExploreVCDataState)
    
    func exploreChannel(channelId: String, searchStr: String, state: Bool)
    
    func exploreBeepDetail(beep: AnyObject, tags: [String], height: CGFloat, searchStr: String)
    
    func backToExploreVC(state: SetExploreVCDataState)
    
    func moveToProfileVC(tempChannelId: String, userID: String, temExploreVC: UIViewController)
    
    func profileToExploreVC(state: ChannelViewFanVCState)
    
    func sideMenuUpdate()
    
    //func backToProfileVC()
}

//MARK:- Enum's
//MARK:-
enum SetExploreVCDataState {
    case None, Channel, Content
}

enum ViewState {
    
    case Home, Explore, Trending, Profile, More , None
}

enum Home3DTouchState {
    case Home, Explore
}

class TabBarVC: UIViewController {
    
    //MARK:- @IBOutlet & Propertie's
    //MARK:-
    @IBOutlet weak var blureView: UIView!
    @IBOutlet weak var sideView: UIView!
    @IBOutlet weak var tblView: UITableView!
    
    @IBOutlet weak var homeButton: UIButton!
    @IBOutlet weak var exploreButton: UIButton!
    @IBOutlet weak var trendingButton: UIButton!
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    
    @IBOutlet weak var homeLbl: UILabel!
    @IBOutlet weak var exploreLbl: UILabel!
    @IBOutlet weak var trendingLbl: UILabel!
    @IBOutlet weak var profileLbl: UILabel!
    @IBOutlet weak var moreLbl: UILabel!
    @IBOutlet weak var bottomTabView: UIView!
    @IBOutlet weak var sideViewTrallingCons: NSLayoutConstraint!
    
    @IBOutlet weak var sideViewLeadingCons: NSLayoutConstraint!
    var temExploreVC: UIViewController!
    weak var homeVCDelegate: HomeVCDelegate!
    var featureChannel = [String: AnyObject]()
    var userFollowList = [AnyObject]()
    var from = 0
    var size = 10
    var nextCounter = -1
    //510/640
    var selectedState = ViewState.None
    var tagText: String = ""
    var channelText: String!
    var tempChannelId: String = ""
    var otherUserId: String = ""
    var setExploreVCDataState = SetExploreVCDataState.None
    var profileVCState: ProfileVCState  = ProfileVCState.Personal
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: .white)
    
    var nameArray = ["Matt Damon", "Virat Kohli", "Narendra Modi"]
    var featureTypeArray = ["Promoted", "Featured", "Trending"]
    var featureImageArray = [UIImage(named: "promoted"), UIImage(named: "featured"), UIImage(named: "trending")]
    var userImgArray =  [UIImage(named: "dp1"), UIImage(named: "dp2"), UIImage(named: "dp3")]
    
    var home3DTouchState = Home3DTouchState.Home
    
    //MARK:- View Life Cycle
    //MARK:
    override func viewDidLoad() {
        super.viewDidLoad()
        
        TABBARDELEGATE = self
        
        self.tblView.delegate = self
        self.tblView.dataSource = self
        self.tagText = ""
        self.channelText = ""
        let fanClubeCell = UINib(nibName: "FanCellXIB", bundle: nil)
        self.tblView.register(fanClubeCell, forCellReuseIdentifier: "FanCellXIB")
        let seeAllCell = UINib(nibName: "SeeAllCell", bundle: nil)
        self.tblView.register(seeAllCell, forCellReuseIdentifier: "SeeAllCell")
        self.blureView.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        self.sideViewLeadingCons.constant = -SCREEN_WIDTH
        self.blureView.isHidden = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(TabBarVC.handleTap(sender:)))
        self.blureView.addGestureRecognizer(gesture)
        
        self.spinner.color = CommonColors.globalRedColor()
        self.spinner.startAnimating()
        self.spinner.frame = CGRect(x:0,y: 0,width: SCREEN_WIDTH,height: 20)
        self.tblView.tableFooterView = spinner
        
        self.getFeatureChannelList()
        
        self.selectedState = .More
        
        print_debug(object: self.home3DTouchState)
        
        if self.home3DTouchState == Home3DTouchState.Home {
            self.homeButtonAction(sender: self.homeButton)
        } else {
            self.exploreButtonAction(sender: self.exploreButton)
        }
        
        self.setupSpoetLightSearch()
        
        self.getCountryList()
        
        var param = [String: AnyObject]()
        param["from"] = self.from as AnyObject
        param["size"] = self.size as AnyObject
        if let uID = CurrentUser.userId {
            self.getUserFollowChannel(param: param, userId: uID)
        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.statusBarHeightChange),
            name: NSNotification.Name.UIApplicationDidChangeStatusBarFrame,
            object: nil)
        
//        if let spotLightSyncDate = UserDefaults.standard.value(forKey:  NSUserDefaultKeys.spotLightSyncDate) as? String {
//            print(spotLightSyncDate)
//
//            let dateFormat = DateFormatter()
//            dateFormat.timeZone = TimeZone(identifier: "UTC")
//            dateFormat.dateFormat =  "yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"
//
//            if  let preConvertedDate = dateFormat.date(from: spotLightSyncDate) {
//                print(preConvertedDate)
//                if Date().daysFrom(date: preConvertedDate) > 1 {
//                    if #available(iOS 9.0, *) {
//                        SHARED_APP_DELEGATE.removeAllSearchItem()
//                    }
//                    registerBackgroundTask()
//                    self.getSpotLightList()
//                }
//            }
//
//        } else {
//            if #available(iOS 9.0, *) {
//                SHARED_APP_DELEGATE.removeAllSearchItem()
//            }
//            registerBackgroundTask()
//            self.getSpotLightList()
//        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.blureView.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        self.sideViewLeadingCons.constant = -SCREEN_WIDTH
        self.blureView.isHidden = true
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.view.layoutIfNeeded()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.view.layoutIfNeeded()
    }
    
    deinit {
        if  self.observationInfo != nil {
            self.removeObserver(self, forKeyPath: NSNotification.Name.UIApplicationDidChangeStatusBarFrame.rawValue)
        }
    }
    
    // SpotLight search
    override func restoreUserActivityState(_ activity: NSUserActivity) {
        
        print(activity)
        
        print(activity.userInfo ?? "" )
        
        //CommonFunctions.showAlertSucess("User Activity..", msg: "Call user activity")
        
        //SHARED_APP_DELEGATE.window?.rootViewController = self.storyboard?.instantiateViewController(withIdentifier:"ExploreContentSearchVC") as! ExploreContentSearchVC
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //MARK:- @IBAction, Selector &  method's
    //MARK:
    func handleTap(sender: UITapGestureRecognizer!) {
        UIView.animate(withDuration: 0.6, delay: 0.0, options: .curveEaseInOut, animations: {
            self.blureView.backgroundColor = UIColor.black.withAlphaComponent(0.0)
            self.sideViewLeadingCons.constant = -SCREEN_WIDTH//600
            self.sideView.layoutIfNeeded()
        }, completion: { (flag: Bool) in
            self.blureView.isHidden = true
        })
        
    }
    
    func statusBarHeightChange() {
        SHARED_APP_DELEGATE.window?.layoutIfNeeded()
        let childViewController = self.childViewControllers
        
        var statusBarHeight =  (APP_DELEGATE.statusBarFrame.height - 20)
        
        
        if self.navigationController?.view.frame.size.height == SCREEN_HEIGHT {
            statusBarHeight = CGFloat(0)
        }
        
        
        for child in childViewController {
            
            child.view.frame = CGRect(x:0,y:0,width: SCREEN_WIDTH,height: SCREEN_HEIGHT - 50 - statusBarHeight)
            child.view.updateConstraintsIfNeeded()
            child.view.layoutIfNeeded()
            child.viewDidLayoutSubviews()
            
            if let navigation = child as? UINavigationController {
                
                for vc  in navigation.viewControllers {
                    vc.view.updateConstraintsIfNeeded()
                    vc.view.layoutIfNeeded()
                    vc.viewDidLayoutSubviews()
                }
            }
            
            if let navi = child.presentedViewController as? UINavigationController {
                
                
                for vc  in navi.viewControllers {
                    vc.view.updateConstraintsIfNeeded()
                    vc.view.layoutIfNeeded()
                    vc.viewDidLayoutSubviews()
                }
            }
            
        }
        
        
    }
    
    @IBAction func homeButtonAction(sender: UIButton) {
        //if selectedState == .Home { return }
        self.deselectBtn()
        self.selectBtn(sender: sender)
        
        self.removeAllChildViewControllers()
        
        APP_DELEGATE.statusBarStyle = UIStatusBarStyle.lightContent
        
        let homeVC = self.storyboard?.instantiateViewController(withIdentifier:"HomeVC") as! HomeVC
        homeVC.delegate = self
        let vc = UINavigationController(rootViewController: homeVC)
        vc.navigationBar.isHidden = true
        self.view.addSubview(vc.view)
        vc.view.frame = CGRect(x:0,y:0,width: SCREEN_WIDTH,height: SCREEN_HEIGHT - 50 - (APP_DELEGATE.statusBarFrame.height - 20))
        
        self.addChildViewController(vc)
        vc.willMove(toParentViewController: self)
        
        
        self.resetViewHierarchy()
        self.deselectButton(sender: sender, state: .Home)
    }
    
    @IBAction func exploreButtonAction(sender: UIButton) {
        
        //if selectedState == .Explore { return }
        self.deselectBtn()
        self.selectBtn(sender: sender)
        
        self.removeAllChildViewControllers()
        
        APP_DELEGATE.statusBarStyle = UIStatusBarStyle.default
        
        let exploreContentSearchVC = self.storyboard?.instantiateViewController(withIdentifier:"ExploreContentSearchVC") as! ExploreContentSearchVC
        exploreContentSearchVC.delegate = self
        exploreContentSearchVC.channelSearchText = self.tagText
        exploreContentSearchVC.contentSearchText = self.tagText
        if self.tagText.isEmpty {
            exploreContentSearchVC.exploreContentSearchState = ExploreContentSearchState.None
            exploreContentSearchVC.setContentSearchState = SetContentSearchState.None
            print_debug(object: "Empty text")
        } else {
//            exploreContentSearchVC.exploreContentSearchState = ExploreContentSearchState.Content
//            exploreContentSearchVC.setContentSearchState = SetContentSearchState.Content
            
            exploreContentSearchVC.exploreContentSearchState = ExploreContentSearchState.None
            exploreContentSearchVC.setContentSearchState = SetContentSearchState.None
            print_debug(object: "not empty \(self.tagText)")
        }
        self.tagText = ""
        
        /*
         if self.setExploreVCDataState == SetExploreVCDataState.None {
         //exploreContentSearchVC.setContentSearchState = SetContentSearchState.None
         } else if self.setExploreVCDataState == SetExploreVCDataState.Channel {
         //exploreContentSearchVC.searchBarText = self.channelText
         exploreContentSearchVC.setContentSearchState = SetContentSearchState.Channels
         } else if self.setExploreVCDataState == SetExploreVCDataState.Content {
         //exploreContentSearchVC.searchBarText = self.tagText
         //self.tagText = ""
         exploreContentSearchVC.setContentSearchState = SetContentSearchState.Content
         } */
        //self.setExploreVCDataState = SetExploreVCDataState.None
        //exploreContentSearchVC.tagText = self.tagText
        //self.tagText = ""
        let vc = UINavigationController(rootViewController: exploreContentSearchVC)
        vc.navigationBar.isHidden = true
        self.view.addSubview(vc.view)
        
        vc.view.frame = CGRect(x:0,y: 0,width: SCREEN_WIDTH,height: SCREEN_HEIGHT - 50 - (APP_DELEGATE.statusBarFrame.height - 20))
        
        self.addChildViewController(vc)
        vc.willMove(toParentViewController: self)
        
        self.resetViewHierarchy()
        self.deselectButton(sender: sender, state: .Explore)
    }
    
    @IBAction func trendingButtonAction(sender: UIButton) {
        
        //if selectedState == .Trending { return }
        self.deselectBtn()
        self.selectBtn(sender: sender)
        
        APP_DELEGATE.statusBarStyle = UIStatusBarStyle.default
        
        self.removeAllChildViewControllers()
        
        let trendingChannelsVC = self.storyboard?.instantiateViewController(withIdentifier:"TrendingChannelsVC") as! TrendingChannelsVC
        let vc = UINavigationController(rootViewController: trendingChannelsVC)
        vc.navigationBar.isHidden = true
        self.view.addSubview(vc.view)
        
        vc.view.frame = CGRect(x:0,y: 0,width: SCREEN_WIDTH,height: SCREEN_HEIGHT - 50 - (APP_DELEGATE.statusBarFrame.height - 20))
        
        self.addChildViewController(vc)
        vc.willMove(toParentViewController: self)
        
        self.resetViewHierarchy()
        self.deselectButton(sender: sender, state: .Trending)
    }
    
    @IBAction func profileButtonAction(sender: UIButton) {
        guard CommonFunctions.checkLogin() else {
            showLoginAlert()
            return
        }
        if selectedState == .Profile { return }
        self.deselectBtn()
        self.selectBtn(sender: sender)
        
        self.removeAllChildViewControllers()
        
        APP_DELEGATE.statusBarStyle = UIStatusBarStyle.default
        
        let profileVC = self.storyboard?.instantiateViewController(withIdentifier:"ProfileVC") as! ProfileVC
        profileVC.tabBarDelegate = self
        profileVC.tabBarContainer = self.bottomTabView
        profileVC.profileVCState = ProfileVCState.Personal//self.profileVCState
        //self.profileVCState = ProfileVCState.Personal
        profileVC.profileUserId = self.otherUserId
        self.otherUserId = ""
        let vc = UINavigationController(rootViewController: profileVC)
        vc.navigationBar.isHidden = true
        self.view.addSubview(vc.view)
        
        vc.view.frame = CGRect(x:0,y: 0,width: SCREEN_WIDTH,height: SCREEN_HEIGHT - 50 - (APP_DELEGATE.statusBarFrame.height - 20))
        
        self.addChildViewController(vc)
        vc.willMove(toParentViewController: self)
        
        self.resetViewHierarchy()
        self.deselectButton(sender: sender, state: .Profile)
        
    }
    
    @IBAction func moreButtonAction(sender: UIButton) {
        
        //if selectedState == .More { return }
        self.deselectBtn()
        self.selectBtn(sender: sender)
        
        self.removeAllChildViewControllers()
        
        APP_DELEGATE.statusBarStyle = UIStatusBarStyle.lightContent
        
        let moreVC = self.storyboard?.instantiateViewController(withIdentifier:"MoreVC") as! MoreVC
        let vc = UINavigationController(rootViewController: moreVC)
        vc.navigationBar.isHidden = true
        self.view.addSubview(vc.view)
        
        vc.view.frame = CGRect(x:0,y: 0,width: SCREEN_WIDTH,height: SCREEN_HEIGHT - 50 - (APP_DELEGATE.statusBarFrame.height - 20))
        
        self.addChildViewController(vc)
        vc.willMove(toParentViewController: self)
        
        self.resetViewHierarchy()
        self.deselectButton(sender: sender, state: .More)
    }
    
    func showLoginAlert() {
        
        let alert = UIAlertController(title: CommonTexts.LOGIN_CONFIRMATION_TITLE, message: CommonTexts.LOGIN_CONFIRMATION_MESSAGE, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            let loginVC = self.storyboard?.instantiateViewController(withIdentifier:"LoginVC") as! LoginVC
            self.present(loginVC, animated: true, completion: {
                //                LoginButtonAnimation.fbButtonAnimation(button: loginVC.loginFBBtn, btnConstraint: loginVC.fbbtnConstraints, constraintVal: 12, googleBtn: loginVC.loginGoogleBtn, googleBtnCons: loginVC.googlebtnConstraints, skipBtn: loginVC.skipBtn, view: loginVC.view)
            })
            
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func removeAllChildViewControllers() {
        for viewController in self.childViewControllers {
            viewController.view.removeFromSuperview()
            viewController.removeFromParentViewController()
        }
    }
    
    func resetViewHierarchy() {
        self.view.bringSubview(toFront: self.bottomTabView)
    }
    
    func deselectButton(sender: UIButton, state: ViewState){
        
        self.homeButton.isSelected = false
        self.exploreButton.isSelected = false
        self.trendingButton.isSelected = false
        self.profileButton.isSelected = false
        
        self.selectedState = state
        sender.isSelected = true
    }
    
    func selectBtn(sender: UIButton) {
        
        switch sender {
        case self.homeButton:
            self.homeLbl.textColor = CommonColors.globalRedColor()
            self.homeButton.setImage(UIImage(named: "tab_hut_selected"), for:  UIControlState.normal)
            
        case self.exploreButton :
            self.exploreLbl.textColor = CommonColors.globalRedColor()
            self.exploreButton.setImage(UIImage(named: "tab_explore_selected"), for:  UIControlState.normal)
            
        case self.trendingButton :
            self.trendingLbl.textColor = CommonColors.globalRedColor()
            self.trendingButton.setImage(UIImage(named: "tab_trending_selected"), for:  UIControlState.normal)
            
        case self.profileButton :
            self.profileLbl.textColor = CommonColors.globalRedColor()
            self.profileButton.setImage(UIImage(named: "tab_profile_selected"), for:  UIControlState.normal)
            
        case self.moreButton :
            self.moreLbl.textColor = CommonColors.globalRedColor()
            self.moreButton.setImage(UIImage(named: "tab_more_selected"), for:  UIControlState.normal)
            
        default:
            fatalError("Inside TabBar Class")
        }
        
        
    }
    
    func deselectBtn() {
        
        switch self.selectedState {
        case .Home:
            self.homeLbl.textColor = CommonColors.tabBarLblGrayColor()
            self.homeButton.setImage(UIImage(named: "tab_home_unselected"), for:  UIControlState.normal)
        case .Explore:
            self.exploreLbl.textColor = CommonColors.tabBarLblGrayColor()
            self.exploreButton.setImage(UIImage(named: "tab_explore_unselected"), for:  UIControlState.normal)
        case .Trending:
            self.trendingLbl.textColor = CommonColors.tabBarLblGrayColor()
            self.trendingButton.setImage(UIImage(named: "tab_trending_unselected"), for:  UIControlState.normal)
        case .Profile:
            self.profileLbl.textColor = CommonColors.tabBarLblGrayColor()
            self.profileButton.setImage(UIImage(named: "tab_profile_unselected"), for:  UIControlState.normal)
        case .More:
            self.moreLbl.textColor = CommonColors.tabBarLblGrayColor()
            self.moreButton.setImage(UIImage(named: "tab_more_unselected"), for:  UIControlState.normal)
            
        default:
            fatalError("Inside TabBar Class")
        }
        
    }
    
    func setupSpoetLightSearch() {
        guard #available(iOS 9.0, *) else { return }
        let activity = NSUserActivity(activityType: Bundle.main.bundleIdentifier ?? "bb.vstarlabs.com")
        //let keywords = "a b c d e f g h i j k l m n o p q r s t u v w x y z"
        let keywords = "a b c d e f g h i j k l m n o p q r s t u v w x y z all photo photos video videos news social blog blogs"
        activity.keywords = Set(arrayLiteral: keywords)
        activity.title = "CheckIn Fantasticoh"
        // Enable Handoff feature
        activity.isEligibleForHandoff = true
        
        //A Boolean value that indicates whether the activity should be added to the on-device index.
        activity.isEligibleForSearch = true
        
        //A Boolean value that indicates whether the activity can be publicly accessed by all iOS users.
        activity.isEligibleForPublicIndexing = true
        
        
        activity.delegate = self
        activity.needsSave = true
        
        self.userActivity = activity
        self.userActivity!.becomeCurrent()
        
    }
    
    
}

//MARK:- UITableViewDelegate & DataSource
//MARK:-
extension TabBarVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.featureTypeArray.count + 1
        } else if section == 1 {
            return self.userFollowList.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 1 {
            return 28
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 1 {
            let header = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 28.0))
            header.backgroundColor = CommonColors.tableSectionHeaderBGColor()
            let lbl = UILabel(frame: CGRect(x: 12, y: 0, width: 60, height: 28))
            lbl.textColor = CommonColors.tableSectionHeaderTextColor()
            lbl.font = CommonFonts.SFUIText_Medium(setsize: 17.0)
            lbl.text = "FAN"
            header.addSubview(lbl)
            return header
        } else {
            return UIView()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 0 {
            if indexPath.row != 3 {
                return 60
            } else {
                return 40
            }
        } else if indexPath.section == 1 {
            return 60
        } else {
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            if indexPath.row != 3 {
                
                return  self.sectionZeroCellSetup(tableView: tableView, indexPath: indexPath)
            } else {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "SeeAllCell", for:  indexPath) as! SeeAllCell
                //cell.selectionStyle = UITableViewCellSelectionStyle.None
                cell.isUserInteractionEnabled = true
                cell.seeAllBtn.addTarget(self, action: #selector(TabBarVC.seeAllBtnTap(sender:)), for: UIControlEvents.touchUpInside)
                cell.seeAllBtn.setTitleColor(CommonColors.fanlblTextColor(), for:  .normal)
                
                cell.topView.isHidden = true
                cell.bottomView.isHidden = true
                
                //let somespace: CGFloat = 5
                
                //cell.seeAllBtn.imageEdgeInsets = UIEdgeInsetsMake(0, cell.seeAllBtn.frame.size.width - (somespace) , 0, 0)
                //cell.seeAllBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 0 + somespace, 0, 20 )
                
                //cell.btnLeadingCons.constant = 64
                return cell
            }
        } else {
            return self.sectionOneCellSetup(tableView: tableView, indexPath: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            
            if indexPath.row != 3 {
                print_debug(object: "0,1,2")
                
                self.channelDetails(row: indexPath.row)
                //  return  self.sectionZeroCellSetup(tableView, indexPath: indexPath)
            } else {
                print_debug(object: "inside 3")
            }
            
        } else {
            //return self.sectionOneCellSetup(tableView, indexPath: indexPath)
            print_debug(object: "Secton 2")
            self.fansDetails(row: indexPath.row)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if self.userFollowList.count-1 == indexPath.row {
            
            self.from = self.from+10
            var param = [String: AnyObject]()
            param["from"] = self.from as AnyObject
            param["size"] = self.size as AnyObject
            
            if self.nextCounter != 0 {
                self.spinner.startAnimating()
                if let uID = CurrentUser.userId {
                    self.getUserFollowChannel(param: param, userId: uID)
                }
                
            }
        }
    }
    
    //MARK:-  Methods
    //MARK:-
    func sectionZeroCellSetup(tableView: UITableView, indexPath: IndexPath) -> FanCellXIB {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FanCellXIB", for:  indexPath) as! FanCellXIB
        cell.isUserInteractionEnabled = true
        cell.selectionStyle = .none
        cell.btn.isHidden = true
        cell.grayDot.layer.cornerRadius = cell.grayDot.frame.height/2
        cell.grayDot.layer.masksToBounds = true
        cell.redDot.layer.cornerRadius = cell.redDot.frame.height/2
        cell.redDot.layer.masksToBounds = true
        cell.imgContainerWidthCons.constant = 30
        cell.imgContainerHeightCons.constant = 30
        cell.imgView.layer.cornerRadius = 15
        cell.imgView.layer.masksToBounds = true
        
        cell.redDot.isHidden = true
        cell.grayDot.isHidden = false
        cell.secondCounterLbl.isHidden = false
        cell.bottomView.isHidden = false
        
        cell.counterLbl.text = "Featured"
        cell.featureImageView.image = UIImage(named: "featured")
        
        if let result = self.featureChannel["results"] as? [AnyObject], result.count > 0 {
            
            cell.nameLbl.text = result[indexPath.row]["name"]  as? String ?? ""
            
            if let nationality = result[indexPath.row]["displayLabels"] as? [String], nationality.count > 0 {
                cell.descriptionLabel.text = nationality.joined(separator: ",") as? String ?? ""
            }
            
            if let imgUrl = result[indexPath.row]["avatarURLLarge"] as? String {
                
                cell.imgView.sd_setImage(with: URL(string: imgUrl), placeholderImage: CHANNELLOGOPLACEHOLDER)
                
            } else {
                
                cell.imgView.image = CHANNELLOGOPLACEHOLDER
            }
            
            if let counter = result[indexPath.row]["countFollowers"] as? Int {
                cell.secondCounterLbl.text = counter > 1 ? "\(counter) Fans" : "\(counter) Fan"
            } else {
                cell.secondCounterLbl.text = "0 Fan"
            }
        }
        return cell
    }
    
    func sectionOneCellSetup(tableView: UITableView, indexPath: IndexPath) -> FanCellXIB {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FanCellXIB", for:  indexPath) as! FanCellXIB
        cell.selectionStyle = .none
        cell.isUserInteractionEnabled = true
        cell.btn.isHidden = true
        cell.grayDot.layer.cornerRadius = cell.grayDot.frame.height/2
        cell.grayDot.layer.masksToBounds = true
        cell.redDot.layer.cornerRadius = cell.redDot.frame.height/2
        cell.redDot.layer.masksToBounds = true
        cell.imgContainerWidthCons.constant = 30
        cell.imgContainerHeightCons.constant = 30
        cell.imgView.layer.cornerRadius = 15
        cell.imgView.layer.masksToBounds = true
        
        
        cell.featureImageView.image = UIImage()
        cell.featureImageWidthCons.constant = 0
        cell.redDot.isHidden = false
        cell.grayDot.isHidden = true
        cell.secondCounterLbl.isHidden = true
        
        guard  self.userFollowList.count > indexPath.row else {return cell}
        //userFollowList
        if let tempChannel = self.userFollowList[indexPath.row] as? AnyObject {
            
            if let channelName = tempChannel["name"] as? String {
                cell.nameLbl.text = channelName
            } else {
                cell.nameLbl.text = ""
            }
            
            if let counter = tempChannel["countFollowers"] as? Int {
                cell.counterLbl.text = counter > 1 ? "\(counter) Fans" : "\(counter) Fan"
            } else {
                cell.counterLbl.text = "0 Fan"
            }
            
            if let imgUrl = tempChannel["avatarURLLarge"] as? String {
                cell.imgView.sd_setImage(with: URL(string: imgUrl), placeholderImage: CHANNELLOGOPLACEHOLDER)
            } else {
                cell.imgView.image = CHANNELLOGOPLACEHOLDER
            }
            
        }
        
        //TO DO : Height last bottom view.
        if indexPath.row == 2 {
            cell.bottomView.isHidden = true
        } else {
            cell.bottomView.isHidden = false
        }
        return cell
    }
    
    func fansDetails(row: Int) {
        self.hideSideMenu()
        print_debug(object: self.userFollowList[row])
        guard let list = self.userFollowList[row] as? [String: AnyObject] else { return }
        print_debug(object: list)
        guard let channelID = list["id"] as? String else { return }
        
        print_debug(object: channelID)
        if let dele = self.homeVCDelegate{
            dele.channelDetail(channelId: channelID, delegate: self)
        }
        //let vc = self.storyboard?.instantiateViewController(withIdentifier:"ChannelViewFanVC") as! ChannelViewFanVC
        //self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func seeAllBtnTap(sender: UIButton) {
        self.hideSideMenu()
        if let dele = self.homeVCDelegate{
            dele.allChannelShow()
        }
    }
    
    func channelDetails(row: Int) {
        self.hideSideMenu()
        guard let result = self.featureChannel["results"] as? [AnyObject] else { return }
        guard let channelID = result[row]["id"] as? String else { return }
        if let dele = self.homeVCDelegate{
            dele.channelDetail(channelId: channelID, delegate: self)
        }
        
    }
    
    func showChannelDetails(channelID :String) {
        
        
        if  let navi = self.childViewControllers.first as? UINavigationController {
            if let vc = navi.viewControllers.first as? HomeVC {
                vc.channelDetail(channelId: channelID, delegate: self)
            }
            print(navi)
        }
        
    }
    
    func showUserProfileDetails(userId : String) {
        
        if let id = CurrentUser.userId {
            if userId == id {
                return
            }
        }
        
        if  let navi = self.childViewControllers.first as? UINavigationController {
            let profileVC = self.storyboard?.instantiateViewController(withIdentifier:"ProfileVC") as! ProfileVC
            profileVC.profileVCState = ProfileVCState.OtherProfile
            profileVC.profileUserId = userId
            
            navi.pushViewController(profileVC, animated: true)
        }
    }
    
    func showSearchChannelDetails(searchText :String) {
        if  let navi = self.childViewControllers.first as? UINavigationController {
            if let homeVC = navi.viewControllers.first as? HomeVC {
                let vc = self.storyboard?.instantiateViewController(withIdentifier:"SearchChannelVC") as! SearchChannelVC
                vc.previoudDataIsAvalible = PrevioudDataIsAvalible.NotAvalible
                vc.searchChannelVCState = SearchChannelVCState.HomeVC
                let navVC = UINavigationController(rootViewController: vc)
                navVC.navigationBar.isHidden = true
                homeVC.present(navVC, animated: true) {
                    APP_DELEGATE.statusBarStyle = UIStatusBarStyle.default
                }
                CommonFunctions.delay(delay: 1.0, closure: {
                    vc.currentState = .Search
                    vc.searchChannel(text: searchText)
                    vc.searchBar.text = searchText
                })
                
            }
        }
    }
    
    func showSearchContentDetails(searchText :String) {
        
        self.tagText = searchText
        self.exploreButtonAction(sender: self.exploreButton)
    }
    
    func showBeepdetail(beepId: String) {
        if  let navi = self.childViewControllers.first as? UINavigationController {
            let postTime = Date()
            let dateFormat = DateFormatter()
            dateFormat.timeZone = TimeZone(identifier: "UTC")
            dateFormat.dateFormat =  "yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"
            
            
            var beep = [String : AnyObject]()
            beep["id"] = beepId as AnyObject
            beep["channels"] = [String]() as AnyObject
            beep["postTime"] = dateFormat.string(from: postTime) as AnyObject
            
            var beepData = [String : AnyObject]()
            beepData["beep"] = beep as AnyObject
            
            

            
        let vc = self.storyboard?.instantiateViewController(withIdentifier:"BeepDetailVC") as! BeepDetailVC
        vc.beepVCState = BeepVCState.AllTagVCState
//        if let dele = self.delegate {
//            vc.tabBarDelegate = dele
//        }
       // vc.delegte = self
        //vc.tagHeight = self.tagHeight(row)
            vc.hasTags =  [String]()
        //vc.isNotBeepDetail = false
            vc.beepData =  beepData as AnyObject
        vc.from = 0
        //self.currentRow = row
        navi.pushViewController(vc, animated: true)
        }
    }
    
    func hideSideMenu() {
        self.blureView.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        self.sideViewLeadingCons.constant = -SCREEN_WIDTH
        self.sideView.layoutIfNeeded()
        self.blureView.isHidden = true
    }
    
    
    
    
    //MARK:- WebService side menu
    //MARK:-
    func getFeatureChannelList() {
        
        //CommonFunctions.showLoader()
        let params = ["from" : 0, "size" : 3 ]
        WebServiceController.getFeatureChannelList(parameters: params as [String : AnyObject]) { (success, errorMessage, data) in
            
            if success {
                
                if let channels = data {
                    print_debug(object: channels)
                    
                    if !channels.isEmpty {
                        self.featureChannel = channels
                        self.tblView.reloadData()
                        
                    }
                }
            }
        }
    }
    
    func getUserFollowChannel(param: [String: AnyObject], userId: String) {
        
        let url = WS_UserChannelList + "/" + userId + "/following"
        print_debug(object: url)
        WebServiceController.getUserFollowChannels(url: url, param: param) { (sucess, errorMessage, data) in
            
            
            if sucess {
                if let from = param["from"] as? Int, from == 0 {
                    self.userFollowList.removeAll()
                }
                
                if let setData = data {
                    if setData.count < 10 && setData.count == 0 {
                        self.nextCounter = 0
                    }
                    self.userFollowList.append(contentsOf: setData)
                    self.spinner.stopAnimating()
                    self.tblView.reloadData()
                }
                self.tblView.reloadData()
            } else {
                self.spinner.stopAnimating()
                print_debug(object: errorMessage)
            }
        }
    }
    
    
    //MARK:- To store country List
    func getCountryList() {
        
        let param = [String : AnyObject]()
        WebServiceController.getCountryList(parameters: param) { (success, data) in
            
            if success {
                var allcountriesArr = [[String: String]]()
                if let array = data as? [[AnyObject]] {
                    for country in array {
                        let obj = [
                            "name" : country[0] as! String,
                            "code" : country[1] as! String
                        ]
                        allcountriesArr.append(obj)
                    }
                }
                var countryDict = [ String: [[String: String]] ]()
                for country in allcountriesArr {
                    var arr = countryDict[country["name"]![0]] ?? []
                    arr.append(country)
                    countryDict[country["name"]![0]] = arr
                }
                
                let sortedCountryDict = countryDict.sorted{ $0.0 < $1.0 }
                
                var rowVal           = [[[String: String]]]()
                //var sectionVal       = [String]()
                
                for (_, value) in sortedCountryDict {
                    
                    //sectionVal.append(key)
                    let sortedValues = value.sorted(by: { $0["name"]! < $1["name"]! })
                    rowVal.append(sortedValues)
                }
                
                var country = [[String: AnyObject]]()
                for temp in rowVal {
                    print_debug(object: temp)
                    for tem in temp {
                        country.append(tem as [String : AnyObject])
                    }
                }
                UserDefaults.setIntVal(value: country as AnyObject, forKey: NSUserDefaultKeys.PROFILECOUNTRYLIST)
                
                
                
                
            } else {
                
            }
        }
        
    }
    
    
    
    
    
}
    



//MARK:- Delegates
///MARK:-
extension TabBarVC: TabBarDelegate {
    
    
    
    func menuBtnTap(sender: UIButton, delegate: HomeVCDelegate) {
        self.homeVCDelegate = delegate
        self.blureView.isHidden = false
        self.blureView.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        UIView.animate(withDuration: 0.6, delay: 0.0, options: .curveEaseInOut, animations: {
            self.blureView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            self.sideViewLeadingCons.constant = 0
            self.sideView.layoutIfNeeded()
        }, completion: nil)
        
        self.view.bringSubview(toFront: self.blureView)
        self.view.bringSubview(toFront: self.sideView)
    }
    
    func tagBtnTap(tag: String, state: SetExploreVCDataState) {
        
        //self.homeButtonAction(self.homeButton)
        //        selectedState = .Home
        self.setExploreVCDataState = state
        self.tagText = tag
        self.exploreButtonAction(sender: self.exploreButton)
    }
    
    
    func exploreChannel(channelId: String, searchStr: String, state: Bool) {
        //NIU
        CommonFunctions.hideKeyboard()
        self.deselectBtn()
        self.selectBtn(sender: self.homeButton)
        
        self.removeAllChildViewControllers()
        
        APP_DELEGATE.statusBarStyle = UIStatusBarStyle.lightContent
        
        let channelViewFanVC = self.storyboard?.instantiateViewController(withIdentifier:"ChannelViewFanVC") as! ChannelViewFanVC
        channelViewFanVC.delegate = self
        channelViewFanVC.channelId = channelId
        
        //True for back move on content tab, false for channel tab
        if state == true {
            channelViewFanVC.channelViewFanVCState = ChannelViewFanVCState.ExploreContentVC
        } else  {
            channelViewFanVC.channelViewFanVCState = ChannelViewFanVCState.ExploreChannelVC
        }
        
        //self.exploreContentSearchString = searchStr
        let vc = UINavigationController(rootViewController: channelViewFanVC)
        vc.navigationBar.isHidden = true
        self.view.addSubview(vc.view)
        
        vc.view.frame = CGRect(x:0,y: 0,width: SCREEN_WIDTH,height: SCREEN_HEIGHT - 50)
        
        self.addChildViewController(vc)
        vc.willMove(toParentViewController: self)
        
        self.resetViewHierarchy()
        self.deselectButton(sender: self.homeButton, state: .Home)
        
    }
    
    func exploreBeepDetail(beep: AnyObject, tags: [String], height: CGFloat, searchStr: String) {
        //NIU
        self.deselectBtn()
        self.selectBtn(sender: self.homeButton)
        
        self.removeAllChildViewControllers()
        
        APP_DELEGATE.statusBarStyle = UIStatusBarStyle.lightContent
        
        let beepDetailVC = self.storyboard?.instantiateViewController(withIdentifier:"BeepDetailVC") as! BeepDetailVC
        beepDetailVC.tabBarDelegate = self
        beepDetailVC.beepVCState = BeepVCState.ExploreContentSearchStateVC
        beepDetailVC.tagHeight = height
        beepDetailVC.hasTags = tags
        beepDetailVC.beepData = beep
        self.tagText = searchStr
        self.setExploreVCDataState = SetExploreVCDataState.Content
        //self.exploreContentSearchString = searchStr
        let vc = UINavigationController(rootViewController: beepDetailVC)
        vc.navigationBar.isHidden = true
        self.view.addSubview(vc.view)
        
        vc.view.frame = CGRect(x:0,y: 0,width: SCREEN_WIDTH,height: SCREEN_HEIGHT - 50)
        
        self.addChildViewController(vc)
        vc.willMove(toParentViewController: self)
        
        self.resetViewHierarchy()
        self.deselectButton(sender: self.homeButton, state: .Home)
        
    }
    
    func backToExploreVC(state: SetExploreVCDataState) {
        
        
        self.setExploreVCDataState = state
        
        self.exploreButtonAction(sender: self.exploreButton)
        
        /*
         self.deselectBtn()
         self.selectBtn(self.exploreButton)
         
         self.removeAllChildViewControllers()
         
         APP_DELEGATE.statusBarStyle = UIStatusBarStyle.default
         
         let exploreContentSearchVC = self.storyboard?.instantiateViewController(withIdentifier:"ExploreContentSearchVC") as! ExploreContentSearchVC
         exploreContentSearchVC.delegate = self
         //exploreContentSearchVC.tagText = self.exploreContentSearchString
         //self.tagText = self.exploreContentSearchString
         let vc = UINavigationController(rootViewController: exploreContentSearchVC)
         vc.navigationBar.isHidden = true
         self.view.addSubview(vc.view)
         
         vc.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 50)
         
         self.addChildViewController(vc)
         vc.willMoveToParentViewController(self)
         
         self.resetViewHierarchy()
         self.deselectButton(self.exploreButton, state: .Explore)
         
         */
    }
    
    
    func moveToProfileVC(tempChannelId: String, userID: String, temExploreVC: UIViewController) {
        //NIU
        self.tempChannelId = tempChannelId
        self.otherUserId = userID
        self.profileVCState = ProfileVCState.OtherProfile
        self.temExploreVC = temExploreVC
        self.profileButtonAction(sender: self.profileButton)
        
    }
    /*
     func moveToProfileVC(tempChannelId: String, userID: String) {
     self.tempChannelId = tempChannelId
     self.otherUserId = userID
     self.profileVCState = ProfileVCState.OtherProfile
     self.
     self.profileButtonAction(self.profileButton)
     }
     */
    
    func profileToExploreVC(state: ChannelViewFanVCState) {
        //NIU
        /*
         CommonFunctions.hideKeyboard()
         self.deselectBtn()
         self.selectBtn(self.homeButton)
         
         self.removeAllChildViewControllers()
         
         APP_DELEGATE.statusBarStyle = UIStatusBarStyle.lightContent
         
         let channelViewFanVC = self.storyboard?.instantiateViewController(withIdentifier:"ChannelViewFanVC") as! ChannelViewFanVC
         channelViewFanVC.delegate = self
         channelViewFanVC.channelId = self.tempChannelId
         self.tempChannelId = ""
         channelViewFanVC.channelViewFanVCState = state
         
         //self.exploreContentSearchString = searchStr
         let vc = UINavigationController(rootViewController: channelViewFanVC)
         vc.navigationBar.isHidden = true
         self.view.addSubview(vc.view)
         
         vc.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 50)
         
         self.addChildViewController(vc)
         
         vc.willMoveToParentViewController(self)
         
         self.resetViewHierarchy()
         self.deselectButton(self.homeButton, state: .Home) */
        
        print_debug(object: self.temExploreVC)
        self.removeAllChildViewControllers()
        UIView.transition(with: SHARED_APP_DELEGATE.window!, duration: 0.5, options: UIViewAnimationOptions.transitionFlipFromLeft, animations: {
            SHARED_APP_DELEGATE.window?.rootViewController = self.temExploreVC
        }, completion: nil)
        
        
        //self.navigationController?.pushViewController(self.temExploreVC, animated: true)
        
    }
    
    func sideMenuUpdate() {
        
        CommonFunctions.delay(delay: 1.0, closure: {
            
            self.getFeatureChannelList()
            self.userFollowList.removeAll(keepingCapacity: false)
            self.nextCounter = -1
            self.from = 0
            var param = [String: AnyObject]()
            param["from"] = self.from as AnyObject
            param["size"] = self.size as AnyObject
            self.userFollowList.removeAll(keepingCapacity: false)
            if let uID = CurrentUser.userId {
                self.getUserFollowChannel(param: param, userId: uID)
            }
        })
        
    }
    
}


//MARK:- NSUserActivityDelegate
//MARK:-
extension TabBarVC: NSUserActivityDelegate {
    
    func userActivityWillSave(_ userActivity: NSUserActivity) {
        print_debug(object: "userActivity")
    }
    
    func userActivityWasContinued(_ userActivity: NSUserActivity) {
        print_debug(object: "userActivity")
    }
    
    func userActivity(_ userActivity: NSUserActivity?, didReceive inputStream: InputStream, outputStream: OutputStream) {
        print_debug(object: "userActivity")
    }
    
    override func updateUserActivityState(_ activity: NSUserActivity) {
        print_debug(object: "userActivity")
    }
    
}
