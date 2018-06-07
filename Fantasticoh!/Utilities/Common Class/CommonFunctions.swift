//
//  CommonClass.swift
//  Fantasticoh!
//
//  Created by Shubham on 7/27/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import Foundation
import UIKit
import Firebase

//import KRProgressHUD

class CommonFunctions {
    
    //MARK:- dealey Block
    class func delay(delay:Double, closure:@escaping ()->()) {
        
        let when = DispatchTime.now() + delay
        DispatchQueue.main.asyncAfter(deadline: when) {
            closure()
        }
    }
    
    class func showLoader() {
        
        KRProgressHUD.setDefaultActivityIndicatorStyle(style: .Color(CommonColors.globalRedColor(), UIColor.yellow))
        KRProgressHUD.show()
    }
    
    class func hideLoader() {
        KRProgressHUD.dismiss()
    }
    
    class func showAlertWarning(msg: String) {
        
        ISMessages.showCardAlert(withTitle: "Warning", message: msg, iconImage: nil, duration: 3.0, hideOnSwipe: true, hideOnTap: true, alertType: ISAlertType.warning, alertPosition: ISAlertPosition.top)
        
    }
    
    class func showAlertSucess(title: String, msg: String) {
        
        ISMessages.showCardAlert(withTitle: title, message: msg, iconImage: nil, duration: 3.0, hideOnSwipe: true, hideOnTap: true, alertType: ISAlertType.success, alertPosition: ISAlertPosition.top)
        
    }
    
    class func showInfoAlert(title: String, msg: String) {
        
        ISMessages.showCardAlert(withTitle: title, message: msg, iconImage: nil, duration: 3.0, hideOnSwipe: true, hideOnTap: true, alertType: ISAlertType.info, alertPosition: ISAlertPosition.top)
    }
    
    //MARK:- Show alert
    class func showAlert(title: String, message: String, btnLbl: String )-> UIAlertController {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let defaultAction  = UIAlertAction(title: btnLbl, style: UIAlertActionStyle.default) { (action: UIAlertAction) in
        }
        
        alertController.addAction(defaultAction)
        
        return alertController
    }
    
    class func showLoginAlert(vc: UIViewController) {
        
        let alert = UIAlertController(title: CommonTexts.LOGIN_CONFIRMATION_TITLE, message: CommonTexts.LOGIN_CONFIRMATION_MESSAGE, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            let loginVC = vc.storyboard?.instantiateViewController(withIdentifier:"LoginVC") as! LoginVC
            vc.present(loginVC, animated: true, completion: {
                //                LoginButtonAnimation.fbButtonAnimation(button: loginVC.loginFBBtn, btnConstraint: loginVC.fbbtnConstraints, constraintVal: 12, googleBtn: loginVC.loginGoogleBtn, googleBtnCons: loginVC.googlebtnConstraints, skipBtn: loginVC.skipBtn, view: loginVC.view)
            })
            
        }))
        vc.present(alert, animated: true, completion: nil)
        
    }
    
    //MARK:- Check user is login or not.
    class func checkLogin()-> Bool {
        
        if let flag = UserDefaults.getBoolVal(key: NSUserDefaultKeys.ISLOGIN)  {
            if flag {
                return true
            } else {
                return false
            }
        }
        return false
    }
    
    //MARK:- Blur image
    class func makeBlurImage(image:UIImage)->(UIImage){
        let imageToBlur = CIImage(image: image)
        let blurfilter = CIFilter(name: "CIGaussianBlur")
        blurfilter!.setValue("15", forKey:kCIInputImageKey)
        blurfilter!.setValue(imageToBlur, forKey: "inputImage")
        let resultImage = blurfilter!.value(forKey: "outputImage") as! CIImage
        let blurredImage = UIImage(ciImage: resultImage)
        return blurredImage
    }
    
    class func hideKeyboard() {
        UIApplication.shared.keyWindow?.rootViewController?.view.endEditing(true)
    }
    
    
    //MARK:- Check Source Typ for image
    class func checkSourceType(str: String) -> (sourceName: String, sourceImg: UIImage, channelImage: UIImage) {
        
        print_debug(object: str)
        
        //TO_DO-BAD_LOGIC
        //
        if str.contains(SourctTypeEnum.twitter.rawValue) {
            return ("Twitter", UIImage(named: "source_twitter")!, UIImage(named: "channel_twitter")!)
        } else if str.contains(SourctTypeEnum.facebook.rawValue) {
            return ("Facebook", UIImage(named: "source_facebook")!, UIImage(named: "channel_facebook")!)
        } else if str.contains(SourctTypeEnum.youtube.rawValue) {
            return ("YouTube", UIImage(named: "source_youtube")!, UIImage(named: "channel_youtube")!)
        } else if str.contains(SourctTypeEnum.vimeo.rawValue) {
            return ("Vimeo", UIImage(named: "source_vimeo")!, UIImage(named: "channel_vimeo")!)
        } else if str.contains(SourctTypeEnum.instagram.rawValue) {
            return ("Instagram", UIImage(named: "source_instagram")!, UIImage(named: "channel_instagram")!)
        } else if str.contains(SourctTypeEnum.pinterest.rawValue) {
            return ("Pinterest", UIImage(named: "source_pinterest")!, UIImage(named: "channel_pinterest")!)
        } else if str.contains(SourctTypeEnum.soundcloud.rawValue) {
            return ("Soundcloud", UIImage(named: "source_soundcloud")!, UIImage(named: "channel_soundcloud")!)
        } else if str.contains(SourctTypeEnum.foursquare.rawValue) {
            return ("Foursquare", UIImage(named: "source_foursquare")!, UIImage(named: "channel_foursquare")!)
        } else if str.contains(SourctTypeEnum.vine.rawValue) {
            return ("Vine", UIImage(named: "source_vine")!, UIImage(named: "channel_vine")!)
        } else if str.contains(SourctTypeEnum.twitch.rawValue) {
            return ("Twitch", UIImage(named: "source_twitch")!, UIImage(named: "channel_twitch")!)
        } else if str.contains(SourctTypeEnum.flickr.rawValue) {
            return ("Flickr", UIImage(named: "source_flickr")!, UIImage(named: "channel_flickr")!)
        } else if str.contains(SourctTypeEnum.tumblr.rawValue) {
            return ("Tumblr", UIImage(named: "source_tumblr")!, UIImage(named: "channel_tumblr")!)
        } else if str.contains(SourctTypeEnum.google.rawValue) {
            return ("Google", UIImage(named: "source_google")!, UIImage(named: "channel_google")!)
        } else if str.contains(SourctTypeEnum.gplus.rawValue) {
            return ("Google Plus", UIImage(named: "source_googleplus")!, UIImage(named: "channel_googleplus")!)
        } else {
            return (str, UIImage(named: "source_rss")!, UIImage(named: "channel_rss")!)
        }
    }
    // nitin
    class func getTextHeightWdith(param: String, font : UIFont)-> CGRect{
        
        let str = param
        // let font = CommonFonts.SFUIText_Medium(15.5)
        let boundingRect = str.boundingRect(with: CGSize(width:SCREEN_WIDTH - 20,height: 1000), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName:font], context: nil)
        //For Height = boundingRect.height
        //For Weight = boundingRect.width
        return boundingRect
    }
    
    
    //MARk: Fan button Setting 
    class func fanBtnTap(sender: UIButton) {
        
        if !sender.isSelected {
            print_debug(object: "oN")
            CommonFunctions.fanBtnOnFormatting(btn: sender)
        } else {
            print_debug(object: "oFF")
            CommonFunctions.fanBtnOffFormatting(btn: sender)
        }
        
        sender.isSelected = !sender.isSelected
    }
    
    class func fanBtnOnFormatting(btn: UIButton) {
        
        btn.backgroundColor = CommonColors.globalRedColor()
        btn.setTitleColor(UIColor.white, for:  .selected)
        btn.setImage(UIImage(named: "tick_Other"), for:  .selected)
        btn.setTitle(" FAN", for:  .selected)
        btn.layer.borderWidth = 0.0
        btn.layer.borderColor = UIColor.clear.cgColor
        btn.layer.cornerRadius = 2.0
        btn.layer.masksToBounds = true
    }
    
    class func fanBtnOffFormatting(btn: UIButton) {
        btn.backgroundColor = UIColor.clear
        btn.setTitleColor(CommonColors.fanlblTextColor(), for:  .normal)
        btn.setImage(UIImage(named: "plus"), for:  .normal)
        btn.setTitle(" FAN", for:  .normal)
        btn.layer.borderWidth = 1.0
        btn.layer.borderColor = CommonColors.globalRedColor().cgColor
        btn.layer.cornerRadius = 2.0
        btn.layer.masksToBounds = true
    }
    
    //MARK: calculate date
    class func calculateDateTime(dateToCompare: NSDate) -> String{
        let curentDate = Date()
        let days = curentDate.offsetFrom(date: dateToCompare as Date)
        return days
    }
    
    //MARK: check internet connection
    class func isConnectedToNetwork()-> Bool {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection) ? true : false
        
    }
    
    //MARK: Reload tableview without move.
    class func reloadTableView(tableView: UITableView) {
        let contentOffset = tableView.contentOffset
        tableView.reloadData()
        tableView.layoutIfNeeded()
        tableView.setContentOffset(contentOffset, animated: false)
    }
    
    //MARK: get indexPath
    
    class func getIndexPathforCellItem(item: AnyObject, inTable tableView: UITableView) -> IndexPath? {
        let buttonPosition = item.convert(CGPoint.zero, to: tableView)
        //return tableView.indexPathForRow(at: buttonPosition) as NSIndexPath?
        return tableView.indexPathForRow(at: buttonPosition)
    }
    
    class func getTableViewCellForItem(item: AnyObject, inTable tableView: UITableView) -> UITableViewCell? {
        if let indexPath = CommonFunctions.getIndexPathforCellItem(item: item, inTable: tableView){
            //return tableView.cellForRow(at: indexPath)
            return tableView.cellForRow(at: indexPath)
        }
        return nil
    }
    
    class func endAllEditing() {
        
        //APP_DELEGATE.keyWindow?.rootViewController?.view.endEditing(true)
        SHARED_APP_DELEGATE.window?.rootViewController?.view.endEditing(true)
        for temp in APP_DELEGATE.windows {
            
            print(temp)
            //temp.rootViewController?.view.endEditing(true)
        }
    }
    
    class func verifyUrl (urlString: String?) -> Bool {
        //Check for nil
        if let urlString = urlString {
            // create NSURL instance
            if let url = URL(string: urlString) {
                // check if your application can open the NSURL instance
                return UIApplication.shared.canOpenURL(url)
            }
        }
        return false
    }
    
    class func displayShareSheet(shareContent: String, viewController : UIViewController) {
        
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
        viewController.present(activityVC, animated: true) {
            
            print("compleatsef")
        }
        
    }
    
    class func checkUserSession() {
        WebServiceController.userSession { (sucess, DataHeaderResponse, DataResultResponse) in
            if let jsonDict = DataHeaderResponse {
                if let statusCode = jsonDict["status"]?.int64Value {
                    if statusCode == 401 {
                        
                        UserDefaults.clean()
                        //Note :: Facebook logout
                        let loginManager: FBSDKLoginManager = FBSDKLoginManager()
                        loginManager.logOut()
                        //Note :: Google logout
                        GIDSignIn.sharedInstance().signOut()
                        if let vc = APP_DELEGATE.keyWindow?.rootViewController {
                        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                        let loginVC = storyboard.instantiateViewController(withIdentifier:"LoginVC") as! LoginVC
                        vc.present(loginVC, animated: true, completion: {
                        })
                        }
                        CommonFunctions.delay(delay: 0.5, closure: {
                            CommonFunctions.showAlertWarning(msg: CommonTexts.sesssionExpired)
                        })
                        
                    }
                }
            }
        }
    }
    
}

extension UINavigationController {
    
    public func pushViewController(viewController: UIViewController,
                                   animated: Bool,
                                   completion: (() -> Void)?) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        pushViewController(viewController, animated: animated)
        CATransaction.commit()
    }
    
    
    public func popViewController(animated: Bool,
                                  completion: (() -> Void)?) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        popViewController(animated: animated)
        CATransaction.commit()
    }
    
}





class Globals {
    
    
    class func setScreenName(screenName: String,screenClass: String) {
        DispatchQueue.global(qos: .unspecified).async {
            
            print_debug(object: "tracking screen : \(screenName)")
            FIRAnalytics.setScreenName(screenName, screenClass: screenClass)
        }
        
    }
    
    class func getUniqueIdentifier() -> String {
        
        return "\(Date().timeIntervalSince1970*1000)"
    }
    
    
    
    
}

class CustomImageCache: SKImageCacheable {
    var cache: SDImageCache
    
    init() {
        cache = SDImageCache()
    }
    
    func imageForKey(_ key: String) -> UIImage? {
        return SDWebImageManager.shared().imageCache?.imageFromDiskCache(forKey: key)
    }
    
    func setImage(_ image: UIImage, forKey key: String) {
        SDWebImageManager.shared().imageCache?.store(image, forKey: key)
    }
    
    func removeImageForKey(_ key: String) {
        SDWebImageManager.shared().imageCache?.removeImage(forKey: key)
    }
    
    
}
