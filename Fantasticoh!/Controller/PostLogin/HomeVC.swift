//
//  HomeVC.swift
//  Fantasticoh!
//
//  Created by Shubham on 8/2/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import UIKit
protocol HomeVCDelegate : class {
    
    func channelDetail(channelId: String, delegate: TabBarDelegate)
    func allChannelShow()
}

class HomeVC: UIViewController {
    
    //MARK:- IBOutlet & Propertie's
    //MARK:-
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var blureView: UIView!
    @IBOutlet weak var sideView: UIView!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var menuBtn: UIButton!
    @IBOutlet weak var containerView: UIView!
    
    weak var delegate: TabBarDelegate!
    
    var items = NSArray()
    var carbonTabSwipeNavigation: CarbonTabSwipeNavigation = CarbonTabSwipeNavigation()
    weak var allTagVCDelegate: AllTagVC!
    //MARK:- View Life Cycle
    //MARK:-
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "CarbonKit"
        items = ["#all", "#news", "#photos", "#videos", "#official"] // nitin
        carbonTabSwipeNavigation = CarbonTabSwipeNavigation(items: items as [AnyObject], delegate: self)
        
        carbonTabSwipeNavigation.pagesScrollView?.layer.shouldRasterize = true;
        carbonTabSwipeNavigation.pagesScrollView?.layer.rasterizationScale = UIScreen.main.scale;
        
        //self.removeAllChildViewControllers()
        self.headerView.backgroundColor = CommonColors.globalRedColor()
        self.carbonTabSwipeNavigation.insert(intoRootViewController: self, andTargetView: self.containerView)
        //self.carbonTabSwipeNavigation.insert(intoRootViewController: self, frame: CGRect(x:0,y: self.view.frame.origin.y+64,width: self.view.frame.size.width,height: self.view.frame.size.height-64))
//        self.carbonTabSwipeNavigation.view.autoresizesSubviews = true
//        self.navigationController?.view.autoresizesSubviews = true
//        self.view.autoresizesSubviews = true
        self.style()
        self.friendListSetup()
        
        let swipeLeftOrange:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(slideToLeftWithGestureRecognizer))
        swipeLeftOrange.direction = UISwipeGestureRecognizerDirection.right;
        self.view.addGestureRecognizer(swipeLeftOrange)
        
        Globals.setScreenName(screenName: "Home", screenClass: "Home")
        
        // Register PushNotification
        SHARED_APP_DELEGATE.registerForRemonteNotification()
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
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
    
    //MARK:- @IBAction, Selector & Private method's
    //MARK:-
    @IBAction func menuBtnTap(sender: UIButton) {

        guard CommonFunctions.checkLogin() else {
            self.showLoginAlert()
            return
        }
        if let dele = self.delegate{
            dele.menuBtnTap(sender: sender, delegate: self)
        }

    }
    
    @IBAction func searchBtnTap(sender: UIButton) {
        
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier:"SearchChannelVC") as! SearchChannelVC
        vc.previoudDataIsAvalible = PrevioudDataIsAvalible.NotAvalible
        vc.searchChannelVCState = SearchChannelVCState.HomeVC
        let navVC = UINavigationController(rootViewController: vc)
        navVC.navigationBar.isHidden = true        
        self.present(navVC, animated: true) {
            APP_DELEGATE.statusBarStyle = UIStatusBarStyle.default
        }
    }
    
    func slideToLeftWithGestureRecognizer
        (gestureRecognizer:UISwipeGestureRecognizer)
    {
       self.menuBtnTap(sender: self.self.menuBtn)
    }
    
    private func friendListSetup() {
        if let list = UserDefaults.getStringArrayVal(key: NSUserDefaultKeys.FRIENDSLIST) as? [String] {
            print_debug(object: list)
        }
    }
    
    private func removeAllChildViewControllers() {
        for viewController in self.childViewControllers {
            viewController.view.removeFromSuperview()
            viewController.removeFromParentViewController()
        }
    }
    
    private func showLoginAlert() {
        
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
    
}

//MARK:- CarbonTabSwipeNavigationDelegate extension
//MARK:-
extension HomeVC: CarbonTabSwipeNavigationDelegate {
    
    func style() {
        let color: UIColor = CommonColors.globalRedColor()
        self.carbonTabSwipeNavigation.toolbar.isTranslucent = false
        self.carbonTabSwipeNavigation.setIndicatorColor(color)
        self.carbonTabSwipeNavigation.setTabExtraWidth(2)
        self.carbonTabSwipeNavigation.setTabBarHeight(32)
        self.carbonTabSwipeNavigation.carbonSegmentedControl!.setWidth(80, forSegmentAt: 0)
        self.carbonTabSwipeNavigation.carbonSegmentedControl!.setWidth(80, forSegmentAt: 1)
        self.carbonTabSwipeNavigation.carbonSegmentedControl!.setWidth(80, forSegmentAt: 2)
        self.carbonTabSwipeNavigation.carbonSegmentedControl!.setWidth(80, forSegmentAt: 3)
        self.carbonTabSwipeNavigation.carbonSegmentedControl!.setWidth(80, forSegmentAt: 4)
        
        //self.carbonTabSwipeNavigation.setNormalColor(UIColor.black.withAlphaComponent(0.2))
        self.carbonTabSwipeNavigation.setNormalColor(CommonColors.lightGrayColor(), font: CommonFonts.SFUIText_Regular(setsize: 15.5))
        self.carbonTabSwipeNavigation.setSelectedColor(color, font: CommonFonts.SFUIText_Regular(setsize: 14.0))
        self.carbonTabSwipeNavigation.setIndicatorHeight(1)
    }
    
    func carbonTabSwipeNavigation(_ carbonTabSwipeNavigation: CarbonTabSwipeNavigation, viewControllerAt index: UInt) -> UIViewController {

        switch index {
        case 0:
            let allTagVC = self.storyboard!.instantiateViewController(withIdentifier:"AllTagVC") as! AllTagVC
            if let dele = self.delegate {
                allTagVC.delegate = dele
            }
            allTagVC.vcTag = ""
            return allTagVC

        case 1:
            let allTagVC = self.storyboard!.instantiateViewController(withIdentifier:"AllTagVC") as! AllTagVC
            if let dele = self.delegate {
                allTagVC.delegate = dele
            }
            allTagVC.vcTag = "news"
            return allTagVC
            
        case 2:
            let allTagVC = self.storyboard!.instantiateViewController(withIdentifier:"AllTagVC") as! AllTagVC
            if let dele = self.delegate {
                allTagVC.delegate = dele
            }
            allTagVC.vcTag = "photos"
            return allTagVC
            
        case 3:
            let allTagVC = self.storyboard!.instantiateViewController(withIdentifier:"AllTagVC") as! AllTagVC
            if let dele = self.delegate {
                allTagVC.delegate = dele
            }
            allTagVC.vcTag = "videos"
            return allTagVC
            // nitin
//        case 4:
//            let allTagVC = self.storyboard!.instantiateViewController(withIdentifier:"AllTagVC") as! AllTagVC
//            if let dele = self.delegate {
//                allTagVC.delegate = dele
//            }
//            allTagVC.vcTag = "blogs"
//            return allTagVC
            
        case 4:
            let allTagVC = self.storyboard!.instantiateViewController(withIdentifier:"AllTagVC") as! AllTagVC
            if let dele = self.delegate {
                allTagVC.delegate = dele
            }
            allTagVC.vcTag = "official"
            return allTagVC
            
        default:
            fatalError("Wrong tag, in HomeVC inside \"carbonTabSwipeNavigation\" mthod.")
        }
        
    }
    
    func carbonTabSwipeNavigation(_ carbonTabSwipeNavigation: CarbonTabSwipeNavigation, didMoveAt index: UInt) {
        NSLog("Did move at index: %ld", index)
    }
    
    func barPositionForCarbonTabSwipeNavigation(carbonTabSwipeNavigation: CarbonTabSwipeNavigation) -> UIBarPosition {
        return UIBarPosition.top
    }
    
}

extension HomeVC: HomeVCDelegate {

    func channelDetail(channelId: String, delegate: TabBarDelegate){
        let channelViewFanVC = self.storyboard?.instantiateViewController(withIdentifier:"ChannelViewFanVC") as! ChannelViewFanVC
        channelViewFanVC.delegate = delegate
        channelViewFanVC.channelId = channelId
        channelViewFanVC.channelViewFanVCState = ChannelViewFanVCState.SideMenuState
        self.navigationController?.pushViewController(channelViewFanVC, animated: true)
    }
    
    func allChannelShow() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier:"SuggestedChannelsVC") as! SuggestedChannelsVC
        //vc.delegate = self
        vc.suggestedChannelsVCState = SuggestedChannelsVCState.SideMenuState
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
