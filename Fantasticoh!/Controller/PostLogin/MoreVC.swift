
//
//  MoreVC.swift
//  Fantasticoh!
//
//  Created by Appinventiv on 19/08/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import UIKit
import SafariServices
import MessageUI

class MoreVC: UIViewController {
    
    //MARK:- @IBOutlet & Propertie's
    //MARK:-
    @IBOutlet weak var tableView: UITableView!
    
    let imageArray = ["share","request_channel_gray", "help", "refer", "dissatisfied", "contact_founder", "legal", "notifications", "logout"]
    let textArray = ["Share Fantasticoh!","Request new channels", "Help us get better. Share your feedback!", "Refer Friends", "Help/FAQ", "Contact V (founder)", "Legal", "Notifications", "Logout"]
    
    //MARK:- View Life Cycle
    //MARK:-
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        _ = self.is3DTouchAvailable()
        Globals.setScreenName(screenName: "More", screenClass: "More")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        APP_DELEGATE.statusBarStyle = .lightContent
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK:- IBAction, Selector & Private Method
    //MARK:-
     func logOutAlert() {
        
        let alert = UIAlertController(title: CommonTexts.LOGOUT_CONFIRMATION_TITLE, message: CommonTexts.LOGOUT_CONFIRMATION_MESSAGE, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            
            CommonFunctions.showLoader()
            
            UserDefaults.clean()
            //Note :: Facebook logout
            let loginManager: FBSDKLoginManager = FBSDKLoginManager()
            loginManager.logOut()
            
            //Note :: Google logout
            GIDSignIn.sharedInstance().signOut()
            
            
            CommonFunctions.delay(delay: 3.0, closure: {
                CommonFunctions.hideLoader()
                let loginVC = self.storyboard?.instantiateViewController(withIdentifier:"LoginVC") as! LoginVC
                self.present(loginVC, animated: true, completion: {
//                    LoginButtonAnimation.fbButtonAnimation(button: loginVC.loginFBBtn, btnConstraint: loginVC.fbbtnConstraints, constraintVal: 12, googleBtn: loginVC.loginGoogleBtn, googleBtnCons: loginVC.googlebtnConstraints, skipBtn: loginVC.skipBtn, view: loginVC.view)
                })
            })
            /*
            //UnFollow all channels
            if let tempList = UserDefaults.getStringArrayVal(key: NSUserDefaultKeys.FRIENDSLIST) as? [String]{
                for tempChannelId in tempList {
                    self.followChannel(tempChannelId, follow: false)
                }
            }*/
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    
     func loginAlert() {
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
    
     func notLoginAlert() {
        let alertController = CommonFunctions.showAlert(title: CommonTexts.NOT_LOGIN_ALERT_TEXT, message: "", btnLbl: "OK")
        self.present(alertController, animated: true, completion: nil)
    }
    
    func switchPressed(sender: AnyObject) {
        
        let nkswitch = (sender as! NKColorSwitch)
        guard CommonFunctions.checkLogin() else {
            nkswitch.isOn = false
            CommonFunctions.showLoginAlert(vc: self)
            return
        }
        
        if nkswitch.isOn {
            CommonFunctions.showAlertSucess(title: "Success", msg: "Notifications on") // nitin
            print("switchPressed ON")
            nkswitch.isOn = true
            self.updateUserDetail(flag: true)
        }
        else {
            CommonFunctions.showAlertSucess(title: "Success", msg: "Notifications Off") // nitin
            print("switchPressed OFF")
            nkswitch.isOn = false
            self.updateUserDetail(flag: false)
        }

    }
    
    func sendMail(subject: String){
        guard MFMailComposeViewController.canSendMail() else {
            let alertController = UIAlertController(title: CommonTexts.COUND_NOT_SEND_HEADING, message: CommonTexts.MAIL_NOT_SEND_DESC, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
                guard let settingsUrl = URL(string: "App-Prefs:root=ACCOUNT_SETTINGS") else {
                    return
                }
                
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                            print("Settings opened: \(success)") // Prints true
                        })
                    } else {
                        // Fallback on earlier versions
                        UIApplication.shared.openURL(settingsUrl)
                    }
                }
            }
            alertController.addAction(cancelAction)
            alertController.addAction(settingsAction)
            self.present(alertController, animated: true, completion: nil)
            return
        }
        
        let iOSVersion = UIDevice.current.systemVersion
        let appVersionString: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
        
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.setToRecipients(subject == NEW_CHANNEL_TITLE ? [REQUEST_NEW_CHANNEL_EMAIL] : [CLIENT_EMAIL])
        mailComposerVC.setSubject(subject)
        mailComposerVC.setMessageBody("<p>\("")</p> <br> User Name: \(CurrentUser.name ?? "Guest User") <br> iOS Version: \(iOSVersion) <br> iPhone Model: \(UIDevice.current.modelName) <br> App Version: \(appVersionString)", isHTML: true)
        
        //mailComposerVC.setMessageBody("Body", isHTML: false)
        //self.present(mailComposerVC, animated: true, completion: nil)
        self.present(mailComposerVC, animated: true, completion: {
            APP_DELEGATE.statusBarStyle = .default
        })
    }
    
      func is3DTouchAvailable() -> Bool {
        if #available(iOS 9, *) {
            if self.traitCollection.forceTouchCapability == UIForceTouchCapability.available {
                self.registerForPreviewing(with: self, sourceView: self.tableView)
                return true
            } else { return false }
        } else { return false}
    }
    
    
     func displayShareSheet(shareContent: String) {
        
        let activityVC = UIActivityViewController(activityItems: [shareContent as NSString], applicationActivities: nil)
        
        activityVC.completionWithItemsHandler = { activity, success, items, error in
            
            if !success{
                print("cancelled")
                return
            } else {
                
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
    
    func legalTap() {
        
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let termsOfUse = UIAlertAction(title: "Terms of Use", style: .default, handler: {
            
            (alert: UIAlertAction!) -> Void in
            if #available(iOS 9.0, *) {
                let safariVC = SFSafariViewController(url: URL(string: TERMS_OF_USE)!)
                self.present(safariVC, animated: true, completion: {
                    APP_DELEGATE.statusBarStyle = .default
                })
            } else {
                let webViewVC = self.storyboard?.instantiateViewController(withIdentifier:"WebViewVC") as! WebViewVC
                webViewVC.urlString = TERMS_OF_USE
                self.present(webViewVC, animated: true, completion: {
                    APP_DELEGATE.statusBarStyle = .default
                })
            }
            
            
        })
        let privacyPolicy = UIAlertAction(title: "Privacy Policy", style: .default, handler: {
            
            (alert: UIAlertAction!) -> Void in
            
            if #available(iOS 9.0, *) {
                let safariVC = SFSafariViewController(url: URL(string: PRIVACY_POLICY)!)
                self.present(safariVC, animated: true, completion: {
                    APP_DELEGATE.statusBarStyle = .default
                })
            } else {
                let webViewVC = self.storyboard?.instantiateViewController(withIdentifier:"WebViewVC") as! WebViewVC
                webViewVC.urlString = PRIVACY_POLICY
                self.present(webViewVC, animated: true, completion: {
                    APP_DELEGATE.statusBarStyle = .default
                })
            }
            
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            
            (alert: UIAlertAction!) -> Void in
            
            
        })
        
        
        optionMenu.addAction(termsOfUse)
        optionMenu.addAction(privacyPolicy)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
        
        
    }
}

//MARK:- TableViewDelegate & DataSource Extension
//MARK:-
extension MoreVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.textArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // nitin
        if indexPath.row == 8 && CommonFunctions.checkLogin() == false {
            return 0
        }
        return 52
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MoreVCCell", for:  indexPath) as! MoreVCCell
        cell.leftImageView.image = UIImage(named: self.imageArray[indexPath.row])
        cell.lbl?.text = self.textArray[indexPath.row]
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.switchContainerView.tintBorderColor = CommonColors.globalRedColor()
        cell.switchContainerView.tintColor = UIColor.white
        //cell.switchContainerView.addTarget(self, action: #selector(self.switchPressed), for:  UIControlEvents.valueChanged)
        cell.switchContainerView.addTarget(self, action: #selector(MoreVC.switchPressed(sender:)), for: .valueChanged)
        switch indexPath.row {
        case 1...6:
            cell.rightImageView.isHidden = false
            cell.switchContainerView.isHidden = true
            
        case 7:
            cell.rightImageView.isHidden = true
            cell.switchContainerView.isHidden = false
            if let isOn = CurrentUser.notificationsEnabled {
                cell.switchContainerView.isOn = isOn
            } else {
                cell.switchContainerView.isOn = false
            }
        case 0:
            cell.rightImageView.isHidden = false
            cell.switchContainerView.isHidden = true
        case 8:
            cell.rightImageView.isHidden = true
            cell.switchContainerView.isHidden = true
            
        default:
            fatalError("Inside MoreVC")
        }
    
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        
//        let channelPreviewVC = self.storyboard?.instantiateViewController(withIdentifier:"ChannelPreviewVC") as! ChannelPreviewVC
//        self.navigationController?.pushViewController(channelPreviewVC, animated: true)
//        return 
        switch indexPath.row {
        case 1:
            self.sendMail(subject: NEW_CHANNEL_TITLE)
            
        case 2:
            self.sendMail(subject: DISSATISFIED_CHANNEL_TITLE)
            
        case 3:
            guard CommonFunctions.checkLogin() else {
                CommonFunctions.showLoginAlert(vc: self)
                return
            }
            let vc = self.storyboard?.instantiateViewController(withIdentifier:"ReferFriendsVC") as! ReferFriendsVC
            self.navigationController?.pushViewController(vc, animated: true)

        case 4:
            if #available(iOS 9.0, *) {
                let safariVC = SFSafariViewController(url: URL(string: HELP_URL)!)
                self.present(safariVC, animated: true, completion: { 
                    APP_DELEGATE.statusBarStyle = .default
                })
            } else {
                let webViewVC = self.storyboard?.instantiateViewController(withIdentifier:"WebViewVC") as! WebViewVC
                webViewVC.urlString = HELP_URL
                self.present(webViewVC, animated: true, completion: { 
                    APP_DELEGATE.statusBarStyle = .default
                })
            }
            
        case 5:
            self.sendMail(subject: "")
            
        case 6:
            self.legalTap()
            
        case 7:
            print("Notofication srow")
        case 0:
            // nitin
            self.displayShareSheet(shareContent: SHARE_Fantasticoh_URL)
            
        case 8:
            
            if let flag = UserDefaults.getBoolVal(key: NSUserDefaultKeys.ISLOGIN)  {
                
                if flag {
                    self.logOutAlert()
                } else {
                    CommonFunctions.showLoginAlert(vc: self)
                }
            } else {
                CommonFunctions.showLoginAlert(vc: self)
            }
            
        default:
            fatalError("Inside MoreVC")
        }
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        let version = UILabel(frame: CGRect(x: 8, y: 15, width: tableView.frame.width - 8, height: 30))
        version.font = version.font.withSize(14)
        if let versionNo = Bundle.main.releaseVersionNumber {
         version.text = "Version \( versionNo)"
        }
        
        version.textColor = UIColor.lightGray
        version.textAlignment = .center;
        
        view.addSubview(version)
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 30
    }
}


//MARK:- Mail Delegate
//MARK:-
extension MoreVC: MFMailComposeViewControllerDelegate {

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result {
        case .cancelled:
            print("Mail cancelled")
        case .saved:
            print("Mail saved")
        case .sent:
            print("Mail sent")
        case .failed:
            print("Mail sent failure: \(String(describing: error?.localizedDescription))")
        default:
            break
        }
        APP_DELEGATE.statusBarStyle = .lightContent
        self.dismiss(animated: true, completion: nil)
    }

}



//MARK:- UIViewControllerPreviewingDelegate
//MARK:-
extension MoreVC: UIViewControllerPreviewingDelegate {

    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
     
        guard #available(iOS 9.0, *) else { return nil }
            
        guard let indexPath = previewingContext.sourceView.tableViewIndexPath(tableView: self.tableView) else { return nil }
        
        // 3 5
        
        guard let cell = self.tableView.cellForRow(at: indexPath) as? MoreVCCell else { return nil }
        
        let safariVC: SFSafariViewController!
        if indexPath.row == 4 {
            safariVC = SFSafariViewController(url: URL(string: HELP_URL)!)
        } else if indexPath.row == 6 {
            safariVC = SFSafariViewController(url: URL(string: TERMS_OF_USE)!)
        } else {
            return nil
        }
        
        /*
         Set the height of the preview by setting the preferred content size of the detail view controller.
         Width should be zero, because it's not used in portrait.
         */
        safariVC.preferredContentSize = CGSize(width: 0.0, height: 0.0)
        
        // Set the source rect to the cell frame, so surrounding elements are blurred.
        previewingContext.sourceRect = cell.frame
        
        return safariVC
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        self.present(viewControllerToCommit, animated: true, completion: {
            APP_DELEGATE.statusBarStyle = .default
        })
    }
    
}

//MARK:- WebService
//MARK:-
extension MoreVC {

     func updateUserDetail(flag: Bool) {
        
        guard let userId = CurrentUser.userId else { return }
        var param = [String: AnyObject]()
        param["notificationsEnabled"] = flag as AnyObject
        
        var authParam = [String: AnyObject]()
        authParam["facebookID"]      = CurrentUser.facebookId as AnyObject
        authParam["facebookToken"]   = CurrentUser.facebookToken as AnyObject
        authParam["googleID"]        = CurrentUser.googleId as AnyObject
        authParam["googleToken"]     = CurrentUser.googleToken as AnyObject
        param["id"]                 =  CurrentUser.userId as AnyObject
        param["authIDs"]            =  authParam as AnyObject
        param["avatarID"]           =  CurrentUser.avatarID as AnyObject
        param["createTime"]           =  CurrentUser.createTime as AnyObject
        param["loginTime"]          =  CurrentUser.loginTime as AnyObject
        param["loginIP"]            =  CurrentUser.loginIP as AnyObject
        param["loginPlatform"]      =  "ios" as AnyObject
        param["admin"]              =  CurrentUser.isAdmin as AnyObject
        param["closed"]             =  CurrentUser.closed as AnyObject
        param["viaUser"]            =  CurrentUser.viaUser as AnyObject
        param["viaCode"]            =  CurrentUser.viaCode as AnyObject
        param["avatarExtURL"]       =  CurrentUser.avatarExtURL as AnyObject
        param["headerIDs"]          =  CurrentUser.headerIDs as AnyObject
        param["name"]               =  CurrentUser.name as AnyObject
        param["tagLine"]            =  CurrentUser.tagLine as AnyObject
        param["bio"]                =  CurrentUser.bio as AnyObject
        param["email"]              =  CurrentUser.email as AnyObject
        
        param["locationName"]       =  CurrentUser.locationName as AnyObject
        param["country"]            =  CurrentUser.country as AnyObject
        param["birthYear"]          =  CurrentUser.birthYear as AnyObject
        param["gender"]             =  0 as AnyObject
        param["notificationChannels"]  = CurrentUser.notificationsChannels as AnyObject
        //param["location"]           =  CurrentUser.location
        //param["pushTokens"]            =  (CurrentUser.pushTokens ?? []) as AnyObject
        param["countFollowing"]        =  CurrentUser.countFollowing as AnyObject
        param["countFlags"]            =  CurrentUser.countFlags as AnyObject
        
        
        
        WebServiceController.updateUserService(parameters: param, userId: userId) { (sucess, DataHeaderResponse, DataResultResponse) in
            
            if sucess {
                print_debug(object: CurrentUser.notificationsEnabled)
                UserDefaults.setBoolVal(state: flag, forKey: NSUserDefaultKeys.NOTIFICATIONENABLED)
                print_debug(object: CurrentUser.notificationsEnabled)
            } else {
                CommonFunctions.showAlertWarning(msg: "Detail is not update.")
                self.tableView.reloadData()
            }
        }
    }
    
    /* private func followChannel(channelId: String, follow: Bool) {
        
        let params: [String: AnyObject] = ["channelID" : channelId, "virtualChannel" : false, "follow": follow]
        WebServiceController.follwUnfollowChannel(params) { (sucess, errorMessage, data) in
            
            if sucess {
                if let dele = TABBARDELEGATE {
                    dele.sideMenuUpdate()
                }
                print_debug(object: "Sucess unfollow")
            } else {
                print_debug(object: errorMessage)
            }
        }
    } */
}


//MARK:- UITableViewCell Class
//MARK:-
class MoreVCCell: UITableViewCell {
    
    @IBOutlet weak var leftImageView: UIImageView!
    @IBOutlet weak var rightImageView: UIImageView!
    @IBOutlet weak var switchContainerView: NKColorSwitch!
    @IBOutlet weak var lbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.switchContainerView.layer.cornerRadius = self.switchContainerView.bounds.height/2
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
}
extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
}
