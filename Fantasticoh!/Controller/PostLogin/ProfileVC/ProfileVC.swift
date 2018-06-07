//
//  ProfileVC.swift
//  Fantasticoh!
//
//  Created by Appinventiv on 05/09/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import UIKit
import Accelerate
import Photos
import AVFoundation
import AssetsLibrary

enum ProfileVCState {
    
    case Personal, OtherProfile, None
}

protocol ProfileVCDelegate {
    func afterSearchChannelDataReset()
}

class ProfileVC: UIViewController, UITextViewDelegate, UITextFieldDelegate {
    
    enum PickerState {
        case Profession, Country, None
    }
    //MARK:- IBOutlet & Propertie's
    //MARK:-
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var nameTextFld: UITextField!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var msgBtn: UIButton!
    @IBOutlet weak var professionBtn: UIButton!
    
    @IBOutlet weak var professionTxtFld: UITextField!
    
    @IBOutlet weak var countryBtn: UIButton!
    @IBOutlet weak var exploreBtn: UIButton!
    @IBOutlet weak var imgChangeBtn: UIButton!
    @IBOutlet weak var fansBtn: UIButton!
    @IBOutlet weak var likesBtn: UIButton!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var nameSeprator: UIView!
    @IBOutlet weak var professionSeprator: UIView!
    @IBOutlet weak var countrySeprator: UIView!
    @IBOutlet weak var bioDescTextView: KMPlaceholderTextView!
    @IBOutlet weak var customPicker: UIPickerView!
    @IBOutlet weak var pickrContainerView: UIView!
    @IBOutlet weak var middleView: UIView!
    @IBOutlet weak var scrollV: UIScrollView!
    
    @IBOutlet weak var pickerTitleLbl: UILabel!
    
    @IBOutlet weak var bgBlurView: UIView!
    
    @IBOutlet weak var movableSepratorLeadingCons: NSLayoutConstraint!
    @IBOutlet weak var middleViewHeightCons: NSLayoutConstraint!
    @IBOutlet weak var nameSepratorHeightCons: NSLayoutConstraint!
    @IBOutlet weak var countryLeadingCons: NSLayoutConstraint!
    @IBOutlet weak var pickerBottomCons: NSLayoutConstraint!
    //@IBOutlet weak var slideContainerTopCons: NSLayoutConstraint!
    
    @IBOutlet weak var joinedDateLabel: UILabel!
    @IBOutlet weak var progessionWidth: NSLayoutConstraint!
    @IBOutlet weak var countryBtnWidth: NSLayoutConstraint!
    
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var DescriptionPopupView: UIView!
    
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var infoBtnWidthConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var reportPopUpView: UIView!
    
    @IBOutlet weak var reportTextView: KMPlaceholderTextView!
    
    @IBOutlet weak var reportButton: UIButton!
    @IBOutlet weak var serachButtonWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var navigationLabel: UILabel!
    //@IBOutlet weak var bioViewLeadingCons: NSLayoutConstraint!
    
    weak var tabBarDelegate: TabBarDelegate!
    var tabBarContainer: UIView!
    var profileVCState = ProfileVCState.None
    var pickerState: PickerState = PickerState.None
    let picker : UIImagePickerController = UIImagePickerController()
    var pickerDataSource = ["White", "Refgdfgdd", "Green", "Blue", "White", "Red", "Green", "Blue"]
    var countryArray = [String]()
    var countryArrayCode = [String]()
    var selectedPickerVal = String()
    var fansVC: FansVC!
    var likesVC: LikesVC!
    var profileUserId = String()
    
    var selecteCountryCode = ""
    var isDataChange = false
    var isProfileImgChang = false
    var isProfileImgRemove = false
    
    var otherUserDetail  = [String : AnyObject]()
    var isSaveMode = true
    
    
    //MARK:- View Life cycle
    //MARK:-
    override func viewDidLoad() {
        super.viewDidLoad()
        
        APP_DELEGATE.statusBarStyle = UIStatusBarStyle.lightContent
        
        self.customPicker.dataSource = self
        self.customPicker.delegate = self
        self.bioDescTextView.delegate = self
        self.nameTextFld.delegate = self
        self.professionTxtFld.delegate = self
        self.bioDescTextView.placeholder = "Enter status..."
        self.DescriptionPopupView.isHidden = true
        self.initSetup()
        self.scrollViewSetup()
        
        self.exploreBtn.isSelected = !self.exploreBtn.isSelected
        //self.bioDescTextView.placeholderText = "Enter your bio"
        //self.reportTextView.delegate = self
        if let countryArray = UserDefaults.getStringArrayVal(key: NSUserDefaultKeys.PROFILECOUNTRYLIST) as? [[String: AnyObject]] {
            for cou in countryArray {
                print_debug(object: cou)
                guard let country = cou["name"] as? String else { return }
                guard let code = cou["code"] as? String else { return }
                self.countryArray.append(country)
                self.countryArrayCode.append(code)
                
            }
        }
        
        if self.profileVCState == ProfileVCState.Personal {
            self.editBtn.setImage(UIImage(named: "pencil"), for: .normal)
            self.backBtn.isHidden = true
            self.editBtn.isHidden = false
            self.msgBtn.isHidden = true
            self.saveMode()
            if let id = CurrentUser.userId {
                self.getUserDetails(userId: id)
                self.profileUserId = id
            }
            Globals.setScreenName(screenName: "UserProfile", screenClass: "UserProfile")
            
            self.navigationLabel.text = "My Profile"
            
        } else {
            ///self.editBtn.setImage(UIImage(named: "pencil"), for:  .normal)
            self.backBtn.isHidden = false
            self.editBtn.isHidden = true
            self.msgBtn.isHidden = false
            
            self.nameTextFld.isHidden = true
            //self.professionBtn.isHidden = true
            self.professionTxtFld.isHidden = true
            self.countryBtn.isHidden = true
            self.bioDescTextView.isHidden = true
            
            self.saveMode()
            self.getUserDetails(userId: self.profileUserId)
            Globals.setScreenName(screenName: "OtherUserProfile", screenClass: "OtherUserProfile")
            self.infoButton.setImage(UIImage(named: "nav_dots"), for: .normal)
            self.navigationLabel.text = "User Profile"
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        APP_DELEGATE.setStatusBarHidden(false, with: .slide)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.nameTextFld.endEditing(true)
        self.bioDescTextView.endEditing(true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        fansVC.view.frame = CGRect(x:0,y: 0,width: SCREEN_WIDTH,height: self.scrollV.frame.size.height)
        likesVC.view.frame = CGRect(x:SCREEN_WIDTH,y: 0,width: SCREEN_WIDTH,height: self.scrollV.frame.size.height)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        
        //        if range.toRange()?.lowerBound == 0 {
        //            self.middleViewHeightCons.constant = 100
        //
        //        } else {
        //            var textHeight: CGFloat = 0
        //            if let text = self.bioDescTextView.text {
        //                textHeight = self.getTextHeightWdith(param: text).height
        //            }
        //            self.bioDescTextView.textContainer.maximumNumberOfLines = 10
        //            self.bioDescTextView.textContainer.lineBreakMode = NSLineBreakMode.byClipping
        //            self.middleViewHeightCons.constant = 90 + textHeight
        //        }
        
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.characters.count
        return numberOfChars < 200
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        
        var textHeight: CGFloat = 0
        if let text = self.bioDescTextView.text {
            textHeight = self.getTextHeightWdith(param: text).height
        }
        self.bioDescTextView.textContainer.maximumNumberOfLines = 10
        self.bioDescTextView.textContainer.lineBreakMode = NSLineBreakMode.byClipping
        self.middleViewHeightCons.constant = 90 + textHeight
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        //self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //MARK:- IBAction, Selector &  method's
    //MARK:-
    func initSetup() {
        self.scrollV.showsHorizontalScrollIndicator = false
        
        let imageViewTap = UITapGestureRecognizer(target:self, action:#selector(self.showFull(img:)))
        self.profileImageView.addGestureRecognizer(imageViewTap)
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.height/2
        self.profileImageView.layer.borderWidth = 1.0
        self.profileImageView.layer.borderColor = CommonColors.globalRedColor().cgColor
        self.profileImageView.layer.masksToBounds = true
        
        self.imgChangeBtn.layer.cornerRadius = self.profileImageView.frame.height/2
        self.imgChangeBtn.layer.masksToBounds = true
        
        self.nameSepratorHeightCons.constant = 0.5
        
        self.msgBtn.layer.cornerRadius = 5
        self.msgBtn.layer.masksToBounds = true
        
        self.middleViewHeightCons.constant = 80
        
        if SCREEN_WIDTH < 350 {
            self.progessionWidth.constant = 60
            self.countryBtnWidth.constant = 60
            
        } else  if SCREEN_WIDTH < 400 {
            self.progessionWidth.constant = 80
            self.countryBtnWidth.constant = 80
            
        } else {
            self.progessionWidth.constant = 120
            self.countryBtnWidth.constant = 120
            
        }
        
        self.nameTextFld.placeholder = "Name"//CurrentUser.name
        
        self.btnInsetSetting(sender: self.countryBtn)
        self.professionTxtFld.placeholder = "Profession"
        self.countryBtn.titleLabel?.textAlignment = .left
        
        self.bgBlurView.isHidden = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(ProfileVC.bgBlureHide(sender:)))
        self.bgBlurView.addGestureRecognizer(gesture)
        
        
        self.countryBtn.setTitle("Country", for:  UIControlState.normal)
        //self.nameTextFld.text = "Name"
        //self.bioDescTextView.textContainer.maximumNumberOfLines = 0
        
        //self.bioDescTextView.textContainerInset = UIEdgeInsetsZero
        reportTextView.placeholder = CommonTexts.Enter_Report_Reason_Placeholder
    }
    
    func btnInsetSetting(sender: UIButton) {
        /*
         sender.imageEdgeInsets = UIEdgeInsetsMake(5, -6, 0, 0)
         sender.transform = CGAffineTransformMakeScale(-1.0, 1.0)
         sender.titleLabel!.transform = CGAffineTransformMakeScale(-1.0, 1.0)
         sender.imageView!.transform = CGAffineTransformMakeScale(-1.0, 1.0)  */
        
        sender.imageEdgeInsets = UIEdgeInsetsMake(5, -6, 0, 0)
        sender.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        sender.titleLabel!.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        sender.imageView!.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
    }
    
    func getTextHeightWdith(param: String)-> CGRect{
        
        let str = param
        let font = CommonFonts.SFUIText_Regular(setsize: 13.0)
        let boundingRect = str.boundingRect(with: CGSize(width: SCREEN_WIDTH - 29,height: 1000), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName:font], context: nil)
        //For Height = boundingRect.height
        //For Weight = boundingRect.width
        return boundingRect
    }
    
    func editMode() {
        if self.profileVCState == ProfileVCState.Personal {
            self.infoButton.isHidden = true
        } else {
            self.infoBtnWidthConstraint.constant = 40.0
        }
        self.serachButtonWidthConstraint.constant = 0.0
        self.infoBtnWidthConstraint.constant = 0.0
        self.nameTextFld.isUserInteractionEnabled = true
        self.professionTxtFld.isUserInteractionEnabled = true
        self.countryBtn.isUserInteractionEnabled = true
        self.bioDescTextView.isUserInteractionEnabled = true
        
        self.nameSeprator.isHidden = false
        self.professionSeprator.isHidden = false
        self.countrySeprator.isHidden = false
        //self.imgChangeBtn.isHidden = false
        
        self.imgChangeBtn.setImage(UIImage(named: "cam_placeholder"), for:  .normal)
        self.imgChangeBtn.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.4)
        
        if let text = self.professionTxtFld.text {
            
            if !text.isEmpty {
                self.professionTxtFld.text = text
            }
            
        }
        //let textP = String(self.professionBtn.titleLabel!.text!.characters.dropLast())
        //self.professionBtn.setTitle(textP, for:  .normal)
        //self.professionBtn.setImage(UIImage(named: "drop_down_arrow"), for:  .normal)
        
        if let textc = self.countryBtn.titleLabel?.text {
            self.countryBtn.setTitle("\(textc)", for:  .normal)
        } else {
            self.countryBtn.setTitle("", for: .normal)
        }
        //let textC = "\(self.countryBtn.titleLabel!.text!)"
        //self.countryBtn.setTitle(textC, for:  .normal)
        self.countryBtn.setImage(UIImage(named: "drop_down_arrow"), for: .normal)
        
        //self.countryLeadingCons.constant = 15.0
        
        //self.editBtn.setImage(UIImage(named: "profile_tick"), for:  .normal)
        //self.msgBtn.isHidden = true
        
        self.countryBtn.isHidden = false
        
        self.exploreBtnTap(sender: self.exploreBtn)
        self.exploreBtn.isHidden = false
        self.joinedDateLabel.isHidden = true
    }
    
    func saveMode() {
        self.serachButtonWidthConstraint.constant = 40.0
        self.joinedDateLabel.isHidden = false
        self.nameTextFld.isUserInteractionEnabled = false
        self.professionTxtFld.isUserInteractionEnabled = false
        self.countryBtn.isUserInteractionEnabled = false
        self.bioDescTextView.isUserInteractionEnabled = false
        
        self.nameSeprator.isHidden = true
        self.professionSeprator.isHidden = true
        self.countrySeprator.isHidden = true
        //self.imgChangeBtn.isHidden = true
        self.imgChangeBtn.setImage(nil, for: .normal)
        self.imgChangeBtn.backgroundColor = UIColor.clear
        //let textP = "\(self.professionBtn.titleLabel!.text!),"
        //self.professionBtn.setTitle(textP, for:  .normal)
        //self.professionBtn.setImage(UIImage(), for:  .normal)
        
        if let textc = self.countryBtn.titleLabel?.text {
            
            if textc == "Country" {
                //CommonFunctions.showAlert(title: "", message: CommonTexts.COUNTY_ALERT_TEXT, btnLbl: "OK")
                //self.countryBtn.isHidden = true
                //                let alertController = UIAlertController(title: "", message: CommonTexts.COUNTY_ALERT_TEXT, preferredStyle: .Alert)
                //                let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                //                alertController.addAction(OKAction)
                //                self.present(alertController, animated: true, completion: nil)
                //                //return
                //
            } else {
                self.countryBtn.isHidden = false
                self.countryBtn.setTitle("\(textc)", for: .normal)
            }
            
        } else {
            self.countryBtn.isHidden = true
            //self.countryBtn.setTitle("", for:  .normal)
        }
        
        if (self.bioDescTextView.text) != nil {
            //text.remov
        }
        
        if self.profileVCState == ProfileVCState.Personal {
            if let temp = self.bioDescTextView.text {
                if temp.count > 0 {
                    self.descriptionTextView.text = temp
                    self.infoButton.isHidden = false
                    self.infoBtnWidthConstraint.constant = 40.0
                } else {
                    self.descriptionTextView.text = ""
                    self.infoButton.isHidden = true
                    self.infoBtnWidthConstraint.constant = 0.0
                }
            } else {
                self.descriptionTextView.text = ""
                self.infoButton.isHidden = true
                self.infoBtnWidthConstraint.constant = 0.0
            }
        } else {
            self.infoBtnWidthConstraint.constant = 40.0
        }
        //let textC = "\(self.countryBtn.titleLabel!.text!)"
        //self.countryBtn.setTitle(textC, for:  .normal)
        self.countryBtn.setImage(UIImage(), for: .normal)
        
        //self.countryLeadingCons.constant = 10.0
        
        //self.msgBtn.isHidden = false
        self.exploreBtnTap(sender: self.exploreBtn)
        self.middleViewHeightCons.constant = 60.0
        self.exploreBtn.isHidden = true
        self.pickerBottomCons.constant = -260
        
        if SCREEN_WIDTH < 350 {
            self.progessionWidth.constant = 60
            self.countryBtnWidth.constant = 60
            
        } else  if SCREEN_WIDTH < 400 {
            self.progessionWidth.constant = 80
            self.countryBtnWidth.constant = 80
            
        } else {
            self.progessionWidth.constant = 120
            self.countryBtnWidth.constant = 120
            
        }
        
        if self.isDataChange {
            
            var param = [String: AnyObject]()
            
            guard var profession = self.professionTxtFld.text  else { return }
            //            if !profession.isEmpty {
            //                profession = String(profession.characters.dropLast())
            //                param["tagLine"] = profession as AnyObject
            //            }
            //            param["country"] = self.selecteCountryCode as AnyObject
            //            param["name"] = self.nameTextFld.text as AnyObject
            //            param["bio"] = self.bioDescTextView.text as AnyObject
            //
            //            var authParam = [String: AnyObject]()
            //            authParam["facebookID"]      = CurrentUser.facebookId as AnyObject
            //            authParam["facebookToken"]   = CurrentUser.facebookToken as AnyObject
            //            authParam["googleID"]        = CurrentUser.googleId as AnyObject
            //            authParam["googleToken"]     = CurrentUser.googleToken as AnyObject
            //            param["authIDs"]             =  authParam as AnyObject
            //            param["id"]                  =  CurrentUser.userId as AnyObject
            //            param["avatarID"]            =  CurrentUser.avatarID as AnyObject
            //            param["createTime"]           =  (CurrentUser.createTime  ?? "") as AnyObject
            //            param["loginTime"]           =  (CurrentUser.loginTime ?? "") as AnyObject
            //            param["loginIP"]             =  (CurrentUser.loginIP ?? "") as AnyObject
            //            param["loginPlatform"]       =  "ios" as AnyObject
            //            param["admin"]               =  (CurrentUser.isAdmin ?? false) as AnyObject
            //            param["closed"]              =  (CurrentUser.closed ?? false) as AnyObject
            //            param["viaUser"]             =  (CurrentUser.viaUser ?? "") as AnyObject
            //            param["viaCode"]             =  (CurrentUser.viaCode ?? "") as AnyObject
            //            param["avatarExtURL"]        =  (CurrentUser.avatarExtURL ?? "") as AnyObject
            //            param["headerIDs"]           =  (CurrentUser.headerIDs ?? []) as AnyObject
            //            param["email"]               =  (CurrentUser.email ?? "") as AnyObject
            //
            //            param["locationName"]        =  (CurrentUser.locationName ?? "") as AnyObject
            //            param["birthYear"]           =  (CurrentUser.birthYear ?? 0) as AnyObject
            //            param["gender"]              =  0 as AnyObject
            //            param["notificationsEnabled"]  = (CurrentUser.notificationsEnabled ?? false) as AnyObject
            //            param["notificationChannels"]  = (CurrentUser.notificationsChannels ?? []) as AnyObject
            //            //param["location"]            =  CurrentUser.location ?? ""
            //            //param["pushTokens"]            =  (CurrentUser.pushTokens ?? [])as AnyObject
            //            param["countFollowing"]        =  (CurrentUser.countFollowing ?? 0) as AnyObject
            //            param["countFlags"]            =  (CurrentUser.countFlags ?? 0) as AnyObject
            
            
            
            param["avatarID"]            =  CurrentUser.avatarID as AnyObject
            param["headerIDs"]           =  (CurrentUser.headerIDs ?? []) as AnyObject
            param["country"] = self.selecteCountryCode as AnyObject
            param["name"] = self.nameTextFld.text as AnyObject
            param["bio"] = self.bioDescTextView.text as AnyObject
            param["birthYear"]           =  (CurrentUser.birthYear ?? 0) as AnyObject
            param["gender"]              =  0 as AnyObject
            param["viaUser"]             =  (CurrentUser.viaUser ?? "") as AnyObject
            if !profession.isEmpty {
                profession = String(profession.dropLast())
                param["tagLine"] = profession as AnyObject
            }
            var authParam = [String: AnyObject]()
            authParam["facebookID"]      = CurrentUser.facebookId as AnyObject
            authParam["facebookToken"]   = CurrentUser.facebookToken as AnyObject
            authParam["googleID"]        = CurrentUser.googleId as AnyObject
            authParam["googleToken"]     = CurrentUser.googleToken as AnyObject
            param["authIDs"]            =  authParam as AnyObject
            
            print_debug(object: param)
            
            //            "avatarID": string,
            //            "headerIDs": string array,
            //            "country": string,
            //            "birthYear": int,
            //            "gender": int,
            //            "viaUser": string,
            //            "name": string,
            //            "tagLine": string,
            //            "bio": string,
            //            "authIDs": <authIDs object - see below for example>
            
            
            self.updateUserDetail(param: param)
        }
        
        
        print_debug(object: self.isProfileImgChang)
        if self.isProfileImgChang {
            if let img = self.profileImageView.image {
                self.uploadProfilePic(tempImg: img)
            }
            // nitin
            if self.profileImageView.image != UIImage(named: "user_placeholder") {
                UserDefaults.setBoolVal(state: true, forKey: NSUserDefaultKeys.SHOWREMOVEPROFILEPIC)
            } else {
                UserDefaults.setBoolVal(state: false, forKey: NSUserDefaultKeys.SHOWREMOVEPROFILEPIC)
            }
            self.isProfileImgRemove = false
            self.isProfileImgChang = false
        }
        //self.editBtn.setImage(UIImage(named: "pencil"), for:  .normal)
    }
    
    func setPickerCons(flag: Bool) {
        self.view.endEditing(true)
        
        if flag {
            
            UIView.animate(withDuration: 0.5, animations: {
                self.view.bringSubview(toFront: self.pickrContainerView)
                self.tabBarContainer.isHidden = true
                self.bgBlurView.isHidden = false
                self.pickerBottomCons.constant = -50
                self.view.layoutIfNeeded()
            }, completion: nil)
        } else {
            
            UIView.animate(withDuration: 0.5, animations: {
                self.pickerBottomCons.constant = -260
                self.view.layoutIfNeeded()
            }, completion: { (flag: Bool) in
                self.bgBlurView.isHidden = true
                self.tabBarContainer.isHidden = false
            })
        }
        
    }
    
    func scrollViewSetup() {
        
        self.scrollV.delegate = self
        
        self.fansVC = self.storyboard!.instantiateViewController(withIdentifier:"FansVC") as! FansVC
        
        self.fansVC.fanId = self.profileUserId
        if let dele =  self.tabBarDelegate {
            self.fansVC.tabBarDelegate = dele
        }
        self.fansVC.channelId = ""
        if self.profileVCState == ProfileVCState.Personal {
            self.fansVC.vCState = VCState.Personal
        } else {
            self.fansVC.vCState = VCState.OtherProfile
        }
        
        self.addChildViewController(fansVC)
        self.scrollV.addSubview(fansVC.view)
        fansVC.didMove(toParentViewController: self)
        fansVC.view.frame = CGRect(x:0,y: 0,width: SCREEN_WIDTH,height: self.scrollV.frame.size.height)
        
        likesVC = self.storyboard!.instantiateViewController(withIdentifier:"LikesVC") as! LikesVC
        self.likesVC.fanId = self.profileUserId
        if self.profileVCState == ProfileVCState.Personal {
            self.likesVC.vCState = VCState.Personal
        } else {
            self.likesVC.vCState = VCState.OtherProfile
        }
        
        
        self.addChildViewController(likesVC)
        self.scrollV.addSubview(likesVC.view)
        likesVC.didMove(toParentViewController: self)
        
        self.scrollV.contentSize = CGSize(width: SCREEN_WIDTH * 2,height: 0)
        
        self.fansVC.likeVCDelegate = self.likesVC
        self.likesVC.fansVCDelegate = self.fansVC
    }
    
    func bgBlureHide(sender:UITapGestureRecognizer){
        self.setPickerCons(flag: false)
    }
    
    func showFull(img: UIGestureRecognizer) {
        
        print_debug(object: "Show full image")
        if self.isSaveMode {
            
        } else {
            
        }
    }
    
    
    func showReportView() {
        self.reportTextView.text = ""
        self.reportPopUpView.alpha = 0.0
        self.reportPopUpView.isHidden = false
        UIView.animate(withDuration: 0.5) {
            self.reportPopUpView.alpha = 1.0
        }
    }
    
    func HideReportView() {
        UIView.animate(withDuration: 0.5, animations: {
            self.reportPopUpView.alpha = 0.0
        }) { (complete) in
            self.reportPopUpView.isHidden = true
        }
    }
    
    @IBAction func backBtnTap(sender: UIButton) {
        //self.view.removeFromSuperview()
        
        //self.removeFromParentViewController()
        //self.tabBarDelegate.profileToExploreVC(ChannelViewFanVCState.None)
        self.navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func editBtnTap(sender: UIButton) {
        
        if sender.isSelected {
            self.isSaveMode = true
            self.editBtn.setImage(UIImage(named: "pencil"), for: .normal)
            print_debug(object: "Edit save")
            self.saveMode()
        } else {
            self.isSaveMode = false
            print_debug(object: "Edit mode")
            self.editBtn.setImage(UIImage(named: "profile_tick"), for: .normal)
            self.isDataChange = true
            self.editMode()
            self.exploreBtn.isSelected = true
            self.exploreBtnTap(sender: self.exploreBtn)
            self.bioDescTextView.becomeFirstResponder()
        }
        sender.isSelected = !sender.isSelected
        
    }
    
    @IBAction func searchBtnTap(sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier:"SearchChannelVC") as! SearchChannelVC
        vc.previoudDataIsAvalible = PrevioudDataIsAvalible.NotAvalible
        vc.searchChannelVCState = SearchChannelVCState.ProfileVC
        vc.multiDelegate = self
        let navVC = UINavigationController(rootViewController: vc)
        navVC.navigationBar.isHidden = true
        self.present(navVC, animated: true) {
            APP_DELEGATE.statusBarStyle = UIStatusBarStyle.default
        }
    }
    
    @IBAction func imgChangeBtnTap(sender: UIButton) {
        
        
        if self.isSaveMode {
            print_debug(object: "Show full image")
            
            guard let meta = self.otherUserDetail["meta"] as? [String: AnyObject] else { return }
            
            guard let url = meta["avatarURL"] as? String else { return }
            
            if self.profileVCState == ProfileVCState.Personal && CurrentUser.showRemoveProfilePic == false {
                return
            }
            
            print_debug(object: url)
            if !url.isEmpty {
                _ =  SKPhoto.photoWithImageURL(url)
                var images = [SKPhoto]()
                //let photo = SKPhoto.photoWithImage(self.profileImageView.image ?? PROFILEPLACEHOLDER!)// add some UIImage
                let photo = SKPhoto.photoWithImageURL(url)
                photo.shouldCachePhotoURLImage = true
                images.append(photo)
                
                let browser = SKPhotoBrowser(photos: images)
                browser.delegate = self
                browser.initializePageIndex(0)
                present(browser, animated: true, completion: {
                    
                    APP_DELEGATE.setStatusBarHidden(true, with: .slide)
                })
            }
            
            
            
            
        } else {
            
            // nitin
            self.view.endEditing(true)
            self.getAccessforCamea(completionHandler: { (success) in
                if success {
                    self.checkPhotoLibraryPermission(completionHandler: { (success) in
                        if success {
                            self.selectType()
                        }
                    })
                }
            })
            
            
        }
        
        
    }
    
    @IBAction func professionBtnTap(sender: UIButton) {
        
        let arr = ["Designer", "Lawyer", "Teacher", "Engineer", "Doctor", "Lorem", "Ipsum", "Developer", "DataAnalysist"]
        self.pickerDataSource = arr
        self.customPicker.reloadAllComponents()
        self.pickerTitleLbl.text = "Profession"
        self.pickerState = .Profession
        if let text = sender.titleLabel?.text {
            self.selectedPickerVal = "\(text)"
        } else {
            self.selectedPickerVal = ""
        }
        //self.selectedPickerVal = (sender.titleLabel?.text)!
        self.setPickerCons(flag: true)
        
    }
    
    @IBAction func countryBtnTap(sender: UIButton) {
        
        // let arr = ["India", "Japan", "Austrila", "United America", "Dubai", "Wascodigama", "China", "Koia", ]
        
        self.pickerDataSource = self.countryArray
        //self.pickerDataSource = arr
        self.customPicker.reloadAllComponents()
        //TODO: picker value set.
        /*
         if self.pickerState == PickerState.Country {
         let country = self.countryBtn.titleLabel?.text
         self.customPicker.selectRow(20, inComponent: 0, animated: false)
         }
         */
        self.pickerTitleLbl.text = "Country"
        self.pickerState = .Country
        if let text = sender.titleLabel?.text {
            self.selectedPickerVal = text
        } else {
            self.selectedPickerVal = ""
        }
        self.setPickerCons(flag: true)
    }
    
    @IBAction func msgBtnTap(sender: UIButton) {
        
        
        guard CommonFunctions.checkLogin() else {
            CommonFunctions.showLoginAlert(vc: self)
            return
        }
        
        if self.otherUserDetail.isEmpty { return }
        let vc = self.storyboard?.instantiateViewController(withIdentifier:"UserChatVC") as! UserChatVC
        vc.toUserDetail = self.otherUserDetail
        vc.openFromChat = OpenFromChat.Channel
        let navVC = UINavigationController(rootViewController: vc)
        navVC.navigationBar.isHidden = true
        self.present(navVC, animated: true, completion: nil)
        
        
    }
    
    @IBAction func exploreBtnTap(sender: UIButton) {
        
        if !sender.isSelected {
            var textHeight: CGFloat = 0
            
            if let text = self.bioDescTextView.text {
                textHeight = self.getTextHeightWdith(param: text).height
            }
            
            if  textHeight < 16.0 {
                //return
            }else {
                self.exploreBtn.isHidden = false
            }
            
            self.bioDescTextView.textContainer.maximumNumberOfLines = 0
            self.bioDescTextView.textContainer.lineBreakMode = NSLineBreakMode.byClipping
            UIView.animate(withDuration: 0.28, delay: 0.0, options: .curveEaseInOut, animations: {
                sender.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI))
                self.middleViewHeightCons.constant = 90 + textHeight
                self.middleView.layoutIfNeeded()
            }, completion: { (flag: Bool) in
                self.bgBlurView.isHidden = true
            })
            
        }  else {
            
            //            UIView.animate(withDuration: 0.28, delay: 0.0, options: .transitionCurlUp, animations: {
            //                sender.transform = CGAffineTransform(rotationAngle: CGFloat(0))
            //                self.bioDescTextView.textContainer.maximumNumberOfLines = 1
            //                self.bioDescTextView.textContainer.lineBreakMode = NSLineBreakMode.byTruncatingTail
            //                self.middleViewHeightCons.constant = 100
            //                self.middleView.layoutIfNeeded()
            //            }, completion: { (flag: Bool) in
            //
            //            })
            
            var textHeight: CGFloat = 0
            
            if let text = self.bioDescTextView.text {
                textHeight = self.getTextHeightWdith(param: text).height
            }
            
            if  textHeight < 16.0 {
                self.exploreBtn.isHidden = true
            } else {
                self.exploreBtn.isHidden = true
            }
            
            
            self.bioDescTextView.textContainer.maximumNumberOfLines = 1
            self.bioDescTextView.textContainer.lineBreakMode = NSLineBreakMode.byTruncatingTail
            self.bioDescTextView.layoutIfNeeded()
            
            UIView.animate(withDuration: 0.2, animations: {
                self.middleViewHeightCons.constant = 90 + textHeight
                self.middleView.layoutIfNeeded()
            })
            //             UIView.animate(withDuration: 0.28, delay: 0.0, options: .transitionCurlUp, animations: {
            //             self.middleViewHeightCons.constant = 90 + textHeight
            //             self.middleView.layoutIfNeeded()
            //             }, completion: { (flag: Bool) in
            //
            //
            //             })
            
        }
        sender.isSelected = !sender.isSelected
        
    }
    
    @IBAction func cancelBtnTap(sender: UIButton) {
        self.setPickerCons(flag: false)
    }
    
    @IBAction func doneBtnTap(sender: UIButton) {
        
        if self.pickerState == PickerState.Country {
            self.countryBtn.setTitle(self.selectedPickerVal, for: UIControlState.normal)
        } else if self.pickerState == PickerState.Profession {
            //self.professionBtn.setTitle(self.selectedPickerVal, for: UIControlState.normal)
        }
        
        self.setPickerCons(flag: false)
    }
    
    @IBAction func fansBtnTap(sender: UIButton) {
        //self.initSetup()
        self.scrollV.setContentOffset(CGPoint.zero, animated: true)
        self.movableSepratorLeadingCons.constant = 0
        
        self.likesBtn.setTitleColor(CommonColors.tabBarLblGrayColor(), for: .normal)
        sender.setTitleColor(CommonColors.globalRedColor(), for: .normal)
    }
    
    @IBAction func likesBtnTap(sender: UIButton) {
        
        self.scrollV.setContentOffset(CGPoint(x: SCREEN_WIDTH, y: 0), animated: true)
        self.movableSepratorLeadingCons.constant = SCREEN_WIDTH / 2
        self.fansBtn.setTitleColor(CommonColors.tabBarLblGrayColor(), for: .normal)
        sender.setTitleColor(CommonColors.globalRedColor(), for: .normal)
    }
    
    @IBAction func infoBtnTap(_ sender: Any) {
        if self.profileVCState == ProfileVCState.Personal {
            self.DescriptionPopupView.alpha = 0.0
            self.DescriptionPopupView.isHidden = false
            UIView.animate(withDuration: 0.5) {
                self.DescriptionPopupView.alpha = 1.0
                
            }
        } else {
            
            let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let description = UIAlertAction(title: "View Bio", style: .default, handler: {
                
                (alert: UIAlertAction!) -> Void in
                
                self.DescriptionPopupView.alpha = 0.0
                self.DescriptionPopupView.isHidden = false
                UIView.animate(withDuration: 0.5) {
                    self.DescriptionPopupView.alpha = 1.0
                    
                }
                
            })
            
            
            let report = UIAlertAction(title: "Report User", style: .default, handler: {
                
                (alert: UIAlertAction!) -> Void in
                
                let optionMenu = UIAlertController(title: CommonTexts.FlagThisUser, message: nil, preferredStyle: .alert)
                
                let yesAction = UIAlertAction(title: "Yes", style: .default, handler: {
                    
                    (alert: UIAlertAction!) -> Void in
                    
                    self.showReportView()
                    self.reportTextView.becomeFirstResponder()
                    //self.reportUser(userId: uID)
                })
                
                let noAction = UIAlertAction(title: "No", style: .destructive, handler: {
                    
                    (alert: UIAlertAction!) -> Void in
                    
                })
                optionMenu.addAction(yesAction)
                optionMenu.addAction(noAction)
                
                self.present(optionMenu, animated: true, completion: nil)
                
            })
            
            
            let blockAction = UIAlertAction(title: "Block User", style: .default, handler: {
                
                (alert: UIAlertAction!) -> Void in
                
                guard CommonFunctions.checkLogin() else {
                    CommonFunctions.showLoginAlert(vc: self)
                    return
                }
                
                let optionMenu = UIAlertController(title: CommonTexts.blockThisUser, message: nil, preferredStyle: .alert)
                
                let yesAction = UIAlertAction(title: "Yes", style: .default, handler: {
                    
                    (alert: UIAlertAction!) -> Void in
                    
                    self.blockUser(userId: self.profileUserId, block: true)

                    
                    
//                    let optionMenu = UIAlertController(title: CommonTexts.blockThisUserSure, message: nil, preferredStyle: .alert)
//
//                    let yesAction = UIAlertAction(title: "Yes", style: .default, handler: {
//
//                        (alert: UIAlertAction!) -> Void in
//
//                        self.blockUser(userId: self.profileUserId, block: true)
//
//
//                        //self.reportUser(userId: uID)
//                    })
                    
//                    let noAction = UIAlertAction(title: "No", style: .destructive, handler: {
//                        
//                        (alert: UIAlertAction!) -> Void in
//                        
//                        
//                    })
//                    optionMenu.addAction(yesAction)
//                    optionMenu.addAction(noAction)
//                    
//                    self.present(optionMenu, animated: true, completion: nil)
//                    
//                    
//                    //self.reportUser(userId: uID)
                })
                
                let noAction = UIAlertAction(title: "No", style: .destructive, handler: {
                    
                    (alert: UIAlertAction!) -> Void in
                    
                    
                })
                optionMenu.addAction(yesAction)
                optionMenu.addAction(noAction)
                
                self.present(optionMenu, animated: true, completion: nil)
                
            })
            
            
            
            let unBlockAction = UIAlertAction(title: "Unblock User", style: .default, handler: {
                
                (alert: UIAlertAction!) -> Void in
                
                guard CommonFunctions.checkLogin() else {
                    CommonFunctions.showLoginAlert(vc: self)
                    return
                }
                
                let optionMenu = UIAlertController(title: CommonTexts.unblockThisUser, message: nil, preferredStyle: .alert)
                
                let yesAction = UIAlertAction(title: "Yes", style: .default, handler: {
                    
                    (alert: UIAlertAction!) -> Void in
                    
                        
                        self.blockUser(userId: self.profileUserId, block: false)
                        
                        
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
            
            if let temp = self.bioDescTextView.text {
                if temp.characters.count > 0 {
                    //                                            self.bioDescTextView.isHidden = false
                    //                                            self.infoButton.isHidden = false
                    //                                            self.infoBtnWidthConstraint.constant = 40.0
                    optionMenu.addAction(description)
                }
            }
            
            
            optionMenu.addAction(report)
            optionMenu.addAction(blockAction)
            optionMenu.addAction(unBlockAction)
            optionMenu.addAction(cancelAction)
            
            
            
            self.present(optionMenu, animated: true, completion: nil)
            
        }
        
        
        
        
    }
    @IBAction func descCloseBtnTap(_ sender: Any) {
        UIView.animate(withDuration: 0.5, animations: {
            self.DescriptionPopupView.alpha = 0.0
        }) { (complete) in
            self.DescriptionPopupView.isHidden = true
        }
    }
    
    @IBAction func reportCloseBtnTap(_ sender: Any) {
        self.HideReportView()
    }
    @IBAction func reportBtnTap(_ sender: Any) {
        
        guard let reportText = self.reportTextView.text else {
            return
        }
        
        if reportText.removeExcessiveSpaces.isEmpty {
            CommonFunctions.showAlertWarning(msg: CommonTexts.Please_Enter_Reason_To_Report)
        } else {
            self.reportUser()
            self.HideReportView()
        }
    }
    
}

//MARK:- UIScrollViewDelegate
//MARK:-
extension ProfileVC: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let inset  = scrollView.contentOffset
        
        if inset.x > 0  && inset.x <  SCREEN_WIDTH {
            self.movableSepratorLeadingCons.constant = inset.x / 2
        }
    }
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.setctorSetting(scrollView: scrollView)
    }
    
    
    func setctorSetting(scrollView: UIScrollView) {
        
        if scrollView.contentOffset.x == 0  {
            self.fansBtn.setTitleColor(CommonColors.globalRedColor(), for: .normal)
            self.likesBtn.setTitleColor(CommonColors.tabBarLblGrayColor(), for: .normal)
        } else {
            self.likesBtn.setTitleColor(CommonColors.globalRedColor(), for: .normal)
            self.fansBtn.setTitleColor(CommonColors.tabBarLblGrayColor(), for: .normal)
        }
    }
    
    /*
     var blurredImage = originalImage.applyBlurWithRadius(
     CGFloat(radius),
     tintColor: nil,
     saturationDeltaFactor: 1.0,
     maskImage: nil
     ) */
    
}

//MARK:- Webservice method's
//MARK:-
extension ProfileVC {
    
    func getUserDetails(userId: String) {
        CommonFunctions.showLoader()
        WebServiceController.getUserDetail(userID: userId) { (success, errorMessage, data) in
            
            if success {
                
                if let tempData = data {
                    
                    self.otherUserDetail = tempData
                    
                    if let user = tempData["user"] as? [String: AnyObject] {
                        
                        if let name = user["name"] as? String {
                            print_debug(object: "name found.")
                            self.nameTextFld.text = name.capitalized
                        } else  {
                            self.nameTextFld.text = ""
                        }
                        
                        if let bio = user["bio"] as? String {
                            self.bioDescTextView.text = bio
                            self.descriptionTextView.text = bio
                        } else  {
                            self.bioDescTextView.text = ""
                            self.descriptionTextView.text = ""
                        }
                        
                        if (user["avatarExtURL"] as? String) != nil {
                            //self.profileImageView.sd_setImage(with: URL(string: url), placeholderImage: PROFILEPLACEHOLDER)
                        } else  {
                            //self.profileImageView.image = PROFILEPLACEHOLDER
                        }
                        
                        self.countryBtn.isHidden = true
                        if let country = user["country"] as? String {
                            
                            var index = -1
                            for temp in self.countryArrayCode {
                                index = index + 1
                                if country == temp {
                                    self.selecteCountryCode = temp
                                    break
                                }
                            }
                            if !self.selecteCountryCode.isEmpty {
                                self.countryBtn.isHidden = false
                                self.countryBtn.setTitle(self.countryArray[index], for: UIControlState.normal)
                            }
                        } else  {
                            self.countryBtn.setTitle("", for: UIControlState.normal)
                        }
                        
                        if let profession =  CurrentUser.profession {
                            print("\(profession)")
                            self.professionTxtFld.text = "\(profession.capitalized)"
                        } else {
                            print("profession not found.")
                        }
                        
                        if let joinedTime = user["createTime"] as? String, let lastSeen = user["loginTime"] as? String {
                            let dateFormat = DateFormatter()
                            dateFormat.timeZone = TimeZone(identifier: "UTC")
                            dateFormat.dateFormat =  "yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"
                            
                            let preConvertedDate = dateFormat.date(from: joinedTime)
                            let lastSeenDate = dateFormat.date(from: lastSeen)
                            
                            dateFormat.dateFormat = "MMM,dd,yyyy"
                            dateFormat.timeZone = TimeZone.current
                            dateFormat.locale = NSLocale.current
                            let convertedDateString = dateFormat.string(from: preConvertedDate!)
                            let lastSeenDateString = dateFormat.string(from: lastSeenDate!)
                            
                            self.joinedDateLabel.text = "Joined: \(convertedDateString)  Last Seen: \(lastSeenDateString)"
                        }
                        
                        if let joinedTime = user["joinDateDisplay"] as? String, let lastSeen = user["loginDateDisplay"] as? String {
                            
                            
                            self.joinedDateLabel.text = "Joined: \(joinedTime)  Last Seen: \(lastSeen)"
                        }
                        
                        
                    }
                    
                    if let meta = self.otherUserDetail["meta"] as? [String: AnyObject] {
                        if let url = meta["avatarURL"] as? String {
                            
                            URLCache.shared.removeAllCachedResponses()
                            URLCache.shared.diskCapacity = 0
                            URLCache.shared.memoryCapacity = 0
                            
                            print_debug(object: url)
                            //self.profileImageView.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: "user_placeholder")!)
                        }
                        
                        if let joinedTime = meta["joinDateDisplay"] as? String, let lastSeen = meta["loginDateDisplay"] as? String {
                            
                            
                            self.joinedDateLabel.text = "Joined: \(joinedTime)  Last Seen: \(lastSeen)"
                        }
                    }
                    
                    if let meta = tempData["meta"] as? [String: AnyObject] {
                        
                        if let url = meta["avatarURL"] as? String {
                            print_debug(object: url)
                            
                            URLCache.shared.removeAllCachedResponses()
                            URLCache.shared.diskCapacity = 0
                            URLCache.shared.memoryCapacity = 0
                            
                            
                            self.profileImageView.imageFromUrl(urlString: url)
                            
                            if self.profileVCState == ProfileVCState.Personal {
                                UserDefaults.setStringVal(value: url as AnyObject, forKey: NSUserDefaultKeys.AVATAREXTURL)
                            }
                            
                            //self.profileImageView.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: "user_placeholder")!)
                        } else { self.profileImageView.image = PROFILEPLACEHOLDER }
                    } else { self.profileImageView.image = PROFILEPLACEHOLDER }
                    
                    
                    
                    if self.profileVCState == ProfileVCState.OtherProfile {
                        
                        if let temp = self.nameTextFld.text {
                            if temp.characters.count > 0 {
                                self.nameTextFld.isHidden = false
                            } else {
                                self.nameTextFld.isHidden = true
                            }
                        } else {
                            self.nameTextFld.isHidden = true
                        }
                        
                        //                        if let temp = self.bioDescTextView.text {
                        //                            if temp.characters.count > 0 {
                        //                                self.bioDescTextView.isHidden = false
                        //                                self.infoButton.isHidden = false
                        //                                self.infoBtnWidthConstraint.constant = 40.0
                        //                            } else {
                        //                                self.bioDescTextView.isHidden = true
                        //                                self.infoButton.isHidden = true
                        //                                self.infoBtnWidthConstraint.constant = 0.0
                        //                            }
                        //                        } else {
                        //                            self.bioDescTextView.isHidden = true
                        //                            self.infoButton.isHidden = true
                        //                            self.infoBtnWidthConstraint.constant = 0.0
                        //                        }
                        
                        
                        if let temp = self.countryBtn.titleLabel?.text {
                            
                            print(temp)
                            if temp.characters.count == 0 || temp == "Country" {
                                self.countryBtn.isHidden = true
                            } else {
                                self.countryBtn.isHidden = false
                            }
                        } else {
                            self.countryBtn.isHidden = true
                        }
                        
                        if let tmep = self.professionTxtFld.text {
                            if tmep.characters.count > 0 {
                                self.professionTxtFld.isHidden = true
                            } else {
                                self.professionTxtFld.isHidden = true
                            }
                        } else {
                            self.professionTxtFld.isHidden = true
                        }
                        
                        
                    } else {
                        if let profession =  CurrentUser.profession {
                            print("\(profession)")
                            self.professionTxtFld.text = "\(profession.capitalized)"
                        } else {
                            print("profession not found.")
                        }
                        
                        if let temp = self.bioDescTextView.text {
                            if temp.characters.count > 0 {
                                self.bioDescTextView.isHidden = false
                                self.infoButton.isHidden = false
                                self.infoBtnWidthConstraint.constant = 40.0
                            } else {
                                self.bioDescTextView.isHidden = true
                                self.infoButton.isHidden = true
                                self.infoBtnWidthConstraint.constant = 0.0
                            }
                        } else {
                            self.bioDescTextView.isHidden = true
                            self.infoButton.isHidden = true
                            self.infoBtnWidthConstraint.constant = 0.0
                        }
                    }
                    //                    self.exploreBtn.isSelected = true
                    //                    self.exploreBtnTap(sender: self.exploreBtn)
                }
                if self.profileVCState == ProfileVCState.OtherProfile {
                self.viewUser(userId: userId)
                }
            } else  {
                print_debug(object: errorMessage)
            }
            CommonFunctions.hideLoader()
        }
        
    }
    
    func updateUserDetail(param: [String: AnyObject]) {
        
        guard let userId = CurrentUser.userId else { return }
        print_debug(object: param)
        
        WebServiceController.updateUserService(parameters: param, userId: userId) { (sucess, DataHeaderResponse, DataResultResponse) in
            
            if sucess {
                
                
                print_debug(object: DataResultResponse)
                
                print_debug(object: CurrentUser.name)
                print_debug(object: CurrentUser.bio)
                print_debug(object: CurrentUser.country)
                print_debug(object: CurrentUser.profession)
                print_debug(object: CurrentUser.tagLine)
                
                if let name = param["name"] as? String {
                    UserDefaults.setStringVal(value: name as AnyObject, forKey: NSUserDefaultKeys.NAME)
                }
                if let bio = param["bio"] as? String {
                    UserDefaults.setStringVal(value: bio as AnyObject, forKey: NSUserDefaultKeys.BIO)
                }
                if let country = param["country"] as? String {
                    UserDefaults.setStringVal(value: country as AnyObject, forKey: NSUserDefaultKeys.COUNTRY)
                }
                
                //On TagLine Key & Profession key have same data
                if let tagLine = param["tagLine"] as? String {
                    UserDefaults.setStringVal(value: tagLine as AnyObject, forKey: NSUserDefaultKeys.TAGLINE)
                }
                
                if let profession = self.professionTxtFld.text {
                    UserDefaults.setStringVal(value: profession as AnyObject, forKey: NSUserDefaultKeys.PROFESSION)
                }
                
                print_debug(object: CurrentUser.name)
                print_debug(object: CurrentUser.bio)
                print_debug(object: CurrentUser.country)
                print_debug(object: CurrentUser.profession)
                print_debug(object: CurrentUser.tagLine)
                
                
                
            } else {
                CommonFunctions.showAlertWarning(msg: "Detail is not update.")
            }
        }
        
        
        
        /* WebServiceController.updateUserWithImageService(url, parameters: [String : AnyObject](), imagData: img, userId: "") { (sucess, DataHeaderResponse, DataResultResponse) in
         
         if sucess {
         
         if let name = param["name"] as? String {
         UserDefaults.setStringVal(name, forKey: NSUserDefaultKeys.NAME)
         }
         if let bio = param["bio"] as? String {
         UserDefaults.setStringVal(bio, forKey: NSUserDefaultKeys.BIO)
         }
         if let country = param["country"] as? String {
         UserDefaults.setStringVal(country, forKey: NSUserDefaultKeys.COUNTRY)
         }
         if let tagLine = param["tagLine"] as? String {
         UserDefaults.setStringVal(tagLine, forKey: NSUserDefaultKeys.TAGLINE)
         }
         
         
         } else {
         
         CommonFunctions.showAlert(title: "Failed", message: CommonTexts.UPDATE_PROFILE_FAILD, btnLbl: "OK")
         }
         print_debug(object: sucess)
         print_debug(object: DataHeaderResponse)
         print_debug(object: DataResultResponse)
         }  */
        
    }
    
    func uploadProfilePic(tempImg: UIImage) {
        
        guard let userId = CurrentUser.userId else { return }
        
        guard let tempImg = self.profileImageView.image else {
            //img = ["image": tempImg]
            return
        }
        
        let url = WS_UploadImage + "?userAvatar=true&seedImgID=\(userId)&channelChat=false&userChat=false"
        
        WebServiceController.uploadUserImage(url: url, parameters: [String : AnyObject](), img: tempImg) { (sucess, DataHeaderResponse, DataResultResponse) in
            
            if let jsonDict = DataHeaderResponse {
                if let statusCode = jsonDict["status"]?.int64Value {
                    if statusCode == 403 {
                        CommonFunctions.showAlertWarning(msg: CommonTexts.ImageUploadFail)
                    }
                }
            }
            
            if sucess {
                guard let responseDic = DataResultResponse else { return }
                guard let id = responseDic["id"] else { return }
                print_debug(object: id)
                
                var param = [String: AnyObject]()
                
                //                var authParam = [String: AnyObject]()
                //                authParam["facebookID"]      = CurrentUser.facebookId as AnyObject
                //                authParam["facebookToken"]   = CurrentUser.facebookToken as AnyObject
                //                authParam["googleID"]        = CurrentUser.googleId as AnyObject
                //                authParam["googleToken"]     = CurrentUser.googleToken as AnyObject
                //                param["id"]                 =  CurrentUser.userId as AnyObject
                //                param["authIDs"]            =  authParam as AnyObject
                //                param["avatarID"]           =  id as AnyObject
                //                param["createTime"]           =  CurrentUser.createTime as AnyObject
                //                param["loginTime"]          =  CurrentUser.loginTime as AnyObject
                //                param["loginIP"]            =  CurrentUser.loginIP as AnyObject
                //                param["loginPlatform"]      =  "ios" as AnyObject
                //                param["admin"]              =  CurrentUser.isAdmin as AnyObject
                //                param["closed"]             =  CurrentUser.closed as AnyObject
                //                param["viaUser"]            =  CurrentUser.viaUser as AnyObject
                //                param["viaCode"]            =  CurrentUser.viaCode as AnyObject
                //                param["avatarExtURL"]       =  CurrentUser.avatarExtURL as AnyObject
                //                param["headerIDs"]          =  CurrentUser.headerIDs as AnyObject
                //                param["name"]               =  CurrentUser.name as AnyObject
                //                param["tagLine"]            =  CurrentUser.tagLine as AnyObject
                //                param["bio"]                =  CurrentUser.bio as AnyObject
                //                param["email"]              =  CurrentUser.email as AnyObject
                //
                //                param["locationName"]       =  CurrentUser.locationName as AnyObject
                //                param["country"]            =  CurrentUser.country as AnyObject
                //                param["birthYear"]          =  CurrentUser.birthYear as AnyObject
                //                param["gender"]             =  0 as AnyObject
                //                param["notificationsEnabled"]  = CurrentUser.notificationsEnabled as AnyObject
                //                param["notificationChannels"]  = CurrentUser.notificationsChannels as AnyObject
                //                //param["location"]           =  CurrentUser.location
                //                //param["pushTokens"]            =  (CurrentUser.pushTokens ?? []) as AnyObject
                //                param["countFollowing"]        =  CurrentUser.countFollowing as AnyObject
                //                param["countFlags"]            =  CurrentUser.countFlags as AnyObject
                
                
                
                param["avatarID"]            =  id as AnyObject
                param["headerIDs"]           =  (CurrentUser.headerIDs ?? []) as AnyObject
                param["country"] = CurrentUser.country as AnyObject
                param["name"] = CurrentUser.name as AnyObject
                param["bio"] = CurrentUser.bio as AnyObject
                param["birthYear"]           =  (CurrentUser.birthYear ?? 0) as AnyObject
                param["gender"]              =  0 as AnyObject
                param["viaUser"]             =  (CurrentUser.viaUser ?? "") as AnyObject
                param["tagLine"] = CurrentUser.tagLine as AnyObject
                var authParam = [String: AnyObject]()
                authParam["facebookID"]      = CurrentUser.facebookId as AnyObject
                authParam["facebookToken"]   = CurrentUser.facebookToken as AnyObject
                authParam["googleID"]        = CurrentUser.googleId as AnyObject
                authParam["googleToken"]     = CurrentUser.googleToken as AnyObject
                param["authIDs"]            =  authParam as AnyObject
                
                print_debug(object: param)
                print_debug(object: param)
                
                self.updateUserDetail(param: param)
                
            }
        }
        
    }
    
    
    func reportUser() {
        
        
        CommonFunctions.showLoader()
        let url = WS_ReportUser + "\(self.profileUserId)?flag=true"
        
        var params = [String: AnyObject]()
        params["reason"]      = self.reportTextView.text.removeExcessiveSpaces as AnyObject
        
        
        WebServiceController.ReportUser(url: url, parameters: params) { (sucess, msg, DataResultResponse) in
            CommonFunctions.hideLoader()
            if sucess {
                CommonFunctions.showAlertSucess(title: CommonTexts.Success, msg: CommonTexts.Reported_SuccessFully) // nitin
                
            } else {
                //CommonFunctions.showAlertWarning(msg: "Detail is not update.")
            }
            
        }
        
    }
    
    func blockUser(userId : String, block : Bool) {
        
        CommonFunctions.showLoader()
        let url = WS_BlockUser + "\(CurrentUser.userId ?? "")/block"
        var param = [String:AnyObject]()
        param["userID"] = userId as AnyObject
        param["block"] = block as AnyObject
        
        WebServiceController.blockUser(url: url, parameters: param) { (sucess, msg, DataResultResponse) in
            CommonFunctions.hideLoader()
            if sucess {
                if block {
                CommonFunctions.showAlertSucess(title: CommonTexts.Success, msg: CommonTexts.Blocked_SuccessFully) // nitin
                } else {
                    CommonFunctions.showAlertSucess(title: CommonTexts.Success, msg: CommonTexts.UnBlocked_SuccessFully) // nitin
                }
                
            } else {
                //CommonFunctions.showAlertWarning(msg: "Detail is not update.")
            }
            
        }
        
    }
    
    func viewUser(userId : String) {
        
        let url = WS_ViewUser + "\(userId)"
        
        WebServiceController.viewUser(url: url, parameters: [String:AnyObject]()) { (sucess, msg, DataResultResponse) in
            if sucess {
                print_debug(object: "Success")
            } else {
                print_debug(object: "fail")
            }
            
        }
        
    }
    
}

//MARK:- UIPickerViewDataSource & Delegate
//MARK:-
extension ProfileVC: UIPickerViewDataSource, UIPickerViewDelegate{
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.pickerDataSource.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.pickerDataSource[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectedPickerVal = self.pickerDataSource[row]
        if self.pickerState == PickerState.Country {
            let country = self.countryBtn.titleLabel?.text
            print_debug(object: country)
            self.selecteCountryCode = self.countryArrayCode[row]
        }
        
    }
}


//MARK:- SKPhotoBrowserDelegate
//MARK:-
extension ProfileVC :  SKPhotoBrowserDelegate {
    
    func didDismissAtPageIndex(_ index: Int) {
        
        APP_DELEGATE.setStatusBarHidden(false, with: .slide)
        
    }
    
    
}

//MARK:- UIImagePickerController & UINavigationController Delegate
//MARK:-
extension ProfileVC :  UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    func selectType() {
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let removeAction = UIAlertAction(title: "Remove Photo", style: .default, handler: {
            
            (alert: UIAlertAction!) -> Void in
            
            if self.profileImageView.image != UIImage(named: "user_placeholder") {
                self.profileImageView.image = UIImage(named: "user_placeholder")
                self.isProfileImgChang = true
                self.isProfileImgRemove = true
            }
            
        })
        
        
        
        let photoLib = UIAlertAction(title: "Photo Library", style: .default, handler: {
            
            (alert: UIAlertAction!) -> Void in
            self.checkAndOpenLibrary(forTypes: ["\(kUTTypeImage)"])
            
        })
        
        
        let takePhotoAction = UIAlertAction(title: "Take Photo", style: .default, handler: {
            
            (alert: UIAlertAction!) -> Void in
            self.checkAndOpenCamera(forTypes: ["\(kUTTypeImage)"])
            
        })
        
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            
            (alert: UIAlertAction!) -> Void in
            
            
            
        })
        
        // nitin
        if CurrentUser.showRemoveProfilePic == true {
            if self.isProfileImgChang == true {
                if self.isProfileImgRemove == false {
                    optionMenu.addAction(removeAction)
                }
                
                
            } else {
                optionMenu.addAction(removeAction)
            }
        } else {
            if self.isProfileImgChang == true {
                if self.isProfileImgRemove == false {
                    optionMenu.addAction(removeAction)
                }
            }
        }
        
        
        
        optionMenu.addAction(photoLib)
        
        optionMenu.addAction(takePhotoAction)
        
        optionMenu.addAction(cancelAction)
        
        
        
        self.present(optionMenu, animated: true, completion: nil)
        
        
        
    }
    
    func checkAndOpenLibrary(forTypes: [String]) {
        
        self.picker.delegate = self
        
        self.picker.mediaTypes = forTypes
        
        
        
        let status: PHAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        
        if (status == .notDetermined) {
            
            let sourceType: UIImagePickerControllerSourceType = UIImagePickerControllerSourceType.photoLibrary
            
            self.picker.sourceType = sourceType
            
            navigationController!.present(self.picker, animated: true, completion: nil)
            
        }
            
        else {
            if status == .restricted {
                let alert = UIAlertController(title: "Error", message: CommonTexts.LIBRARY_RESTRICTED_ALERT_TEXT, preferredStyle: UIAlertControllerStyle.alert)
                let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (action) in
                    self.dismiss(animated: true, completion: nil)
                }
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
            }
            else {
                
                if status == .denied {
                    
                    
                    
                    let alert = UIAlertController(title: "Error", message: CommonTexts.LIBRARY_ALLOW_ALERT_TEXT, preferredStyle: UIAlertControllerStyle.alert)
                    
                    let settingsAction = UIAlertAction(title: "Settings", style: UIAlertActionStyle.default, handler: { (action) in
                        
                        UIApplication.shared.openURL(NSURL(string: UIApplicationOpenSettingsURLString)! as URL)
                        
                    })
                    
                    let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (action) in
                        
                        self.dismiss(animated: true, completion: nil)
                        
                    }
                    
                    
                    
                    alert.addAction(settingsAction)
                    
                    alert.addAction(cancelAction)
                    
                    self.present(alert, animated: true, completion: nil)
                    
                }
                    
                else {
                    
                    if status == .authorized {
                        
                        let sourceType: UIImagePickerControllerSourceType = UIImagePickerControllerSourceType.photoLibrary
                        
                        self.picker.sourceType = sourceType
                        
                        self.picker.allowsEditing = true
                        
                        self.navigationController!.present(self.picker, animated: true, completion: nil)
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
    
    func checkAndOpenCamera(forTypes: [String]) {
        
        
        
        self.picker.delegate = self
        
        let authStatus: AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        
        if authStatus == AVAuthorizationStatus.authorized {
            
            let sourceType: UIImagePickerControllerSourceType = UIImagePickerControllerSourceType.camera
            
            if UIImagePickerController.isSourceTypeAvailable(sourceType) {
                
                self.picker.sourceType = sourceType
                
                self.picker.mediaTypes = forTypes
                
                self.picker.allowsEditing = true
                
                if self.picker.sourceType == UIImagePickerControllerSourceType.camera {
                    
                    self.picker.showsCameraControls = true
                    
                }
                
                self.navigationController!.present(self.picker, animated: true, completion: nil)
                
            }
                
            else {
                
                DispatchQueue.main.async(execute: {
                    
                    //PKCommonClass.showTSMessageForError("Sorry! Camera not supported on this device")
                    
                })
                
            }
            
        }
            
        else {
            
            if authStatus == AVAuthorizationStatus.notDetermined {
                
                AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: {(granted: Bool) in                DispatchQueue.main.async(execute: {
                    
                    if granted {
                        
                        let sourceType: UIImagePickerControllerSourceType = UIImagePickerControllerSourceType.camera
                        
                        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
                            
                            self.picker.sourceType = sourceType
                            
                            if self.picker.sourceType == UIImagePickerControllerSourceType.camera {
                                
                                self.picker.showsCameraControls = true
                                
                            }
                            
                            self.navigationController!.present(self.picker, animated: true, completion: nil)
                            
                        }
                            
                        else {
                            
                            DispatchQueue.main.async(execute: {
                                
                                //PKCommonClass.showTSMessageForError("Sorry! Camera not supported on this device")
                                
                            })
                            
                        }
                        
                    }
                    
                })
                    
                })
                
            }
                
            else {
                
                if authStatus == AVAuthorizationStatus.restricted {
                    
                    let alert = UIAlertController(title: "Error", message: CommonTexts.CAMERA_RESTRICTED_ALERT_TEXT, preferredStyle: UIAlertControllerStyle.alert)
                    
                    let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (action) in
                        
                        self.dismiss(animated: true, completion: nil)
                        
                    }
                    
                    alert.addAction(cancelAction)
                    
                    self.present(alert, animated: true, completion: nil)
                    
                }
                    
                else {
                    
                    let alert = UIAlertController(title: "Error", message: CommonTexts.CAMERA_ALLOW_ALERT_TEXT, preferredStyle: UIAlertControllerStyle.alert)
                    
                    
                    let settingsAction = UIAlertAction(title: "Settings", style: UIAlertActionStyle.default, handler: { (action) in
                        
                        UIApplication.shared.openURL(NSURL(string: UIApplicationOpenSettingsURLString)! as URL)
                        
                    })
                    
                    
                    
                    let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (action) in
                        
                        self.dismiss(animated: true, completion: nil)
                        
                    }
                    
                    
                    
                    alert.addAction(settingsAction)
                    
                    alert.addAction(cancelAction)
                    
                    
                    
                    self.present(alert, animated: true, completion: nil)
                    
                }
                
            }
            
        }
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        
        
        let mediaType = info[UIImagePickerControllerMediaType] as! NSString
        
        print_debug(object: info)
        
        if mediaType == kUTTypeImage {
            
            self.picker.dismiss(animated: true, completion: {
                
                
                if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
                    
                    self.profileImageView.image = image
                    self.isProfileImgChang = true
                    self.isProfileImgRemove = false // nitin
                }
                
            })
            
        } else {
            
            print_debug(object: "Data not found.")
            
        }
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.picker.dismiss(animated: true, completion: nil)
    }
    
}

//MARK:- ProfileVCDelegate extension
//MARK:-
extension ProfileVC: ProfileVCDelegate {
    
    func afterSearchChannelDataReset() {
        likesVC.setInitData()
        fansVC.initDataSetUp()
    }
}


// MARK:- Camera & Gallery permission
// MARK:
extension ProfileVC {
    
    //Access Camera
    func getAccessforCamea(completionHandler: @escaping CompletionHandler) {
        
        let authStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        //let authStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        switch authStatus {
        case .authorized: completionHandler(true)  // Do your stuff here i.e. allowScanning()
        case .denied: alertToEncourageCameraAccess(); completionHandler(false)
        case .notDetermined:
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { (granted :Bool) in
                if granted { completionHandler(true) } else { self.alertToEncourageCameraAccess(); completionHandler(false) }
            })
        default: alertToEncourageCameraAccess(); completionHandler(false);
        }
    }
    
    func alertToEncourageCameraAccess() {
        
        let alert = UIAlertController(title: "Alert", message: "Camera access required for this aap", preferredStyle:UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Allow Gallery", style: .default, handler: { (alert) -> Void in
            UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)! )
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    //Access Gallery
    func checkPhotoLibraryPermission(completionHandler: @escaping CompletionHandler) {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized: completionHandler(true)
        //handle authorized status
        case .denied, .restricted : self.alertToEncourageGalleryAccess(); completionHandler(false)
        //handle denied status
        case .notDetermined:
            // ask for permissions
            PHPhotoLibrary.requestAuthorization() { (status) -> Void in
                switch status {
                case .authorized:
                    completionHandler(true)
                case .denied, .restricted:
                    //self.alertToEncourageGalleryAccess()
                    completionHandler(false)
                case .notDetermined:
                    //self.alertToEncourageGalleryAccess()
                    completionHandler(false)
                }
            }
        }
    }
    
    func alertToEncourageGalleryAccess() {
        
        
        let alert = UIAlertController(title: "Alert", message: "Gallery access required for this aap", preferredStyle: UIAlertControllerStyle.alert)
        
        let allowAction = UIAlertAction(title: "Allow Gallery", style: .default){ (action) in
            UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (action) in
            
        }
        alert.addAction(allowAction)
        alert.addAction(cancelAction)
        
        /*
         alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
         alert.addAction(UIAlertAction(title: "Allow Gallery", style: .Cancel, handler: { (alert) -> Void in
         UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
         }))*/
        self.present(alert, animated: true, completion: nil)
    }
}

typealias CompletionHandler = (_ success:Bool) -> Void


extension UIImageView {
    public func imageFromUrl(urlString: String) {
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url )
            
            NSURLConnection.sendAsynchronousRequest(request, queue: OperationQueue.main, completionHandler: { (res, data, error) in
                if let f = data {
                    self.image = UIImage(data: f)
                }
            })
            
            /*
             NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {
             (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
             self.image = UIImage(data: data)
             } */
        }
    }
}
