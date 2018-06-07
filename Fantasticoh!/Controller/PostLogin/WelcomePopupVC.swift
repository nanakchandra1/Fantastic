//
//  WelcomePopupVC.swift
//  Fantasticoh!
//
//  Created by Appinventiv on 10/08/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import UIKit

class WelcomePopupVC: UIViewController {
    
    //MARK:- @IBOutlet & Propertie's
    //MARK:-
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var descTextLbl: UILabel!
    @IBOutlet weak var codeTextFld: UITextField!
    @IBOutlet weak var goBtn: UIButton!
    @IBOutlet weak var skipBtn: UIButton!
    
    var code = String()
    
    //MARK:- View Life Cycle
    //MARK:-
    override func viewDidLoad() {
        super.viewDidLoad()
        self.codeTextFld.delegate = self
        self.initialSetup()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
   
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.view.endEditing(true)
    }
    
    //MARK:- @IBAction, Selector & Private method's
    //MARK:-
    @IBAction func goBtnTap(sender: UIButton) {
        if !self.code.isEmpty {
            
            CommonFunctions.showLoader()
            var param: [String : AnyObject]  = ["viaUser" : self.code as AnyObject]
            
            var authParam = [String: AnyObject]()
            authParam["facebookID"]      = CurrentUser.facebookId as AnyObject
            authParam["facebookToken"]   = CurrentUser.facebookToken as AnyObject
            authParam["googleID"]        = CurrentUser.googleId as AnyObject
            authParam["googleToken"]     = CurrentUser.googleToken as AnyObject
            param["id"]                 =  CurrentUser.userId as AnyObject
            param["authIDs"]            =  authParam as AnyObject
            param["avatarID"]           =  CurrentUser.avatarID as AnyObject
            param["createTime"]         =  CurrentUser.createTime as AnyObject
            param["loginTime"]          =  CurrentUser.loginTime as AnyObject
            param["loginIP"]            =  CurrentUser.loginIP as AnyObject
            param["loginPlatform"]      =  "ios" as AnyObject
            param["admin"]              =  CurrentUser.isAdmin as AnyObject
            param["closed"]             =  CurrentUser.closed as AnyObject
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
            param["notificationsEnabled"]  = CurrentUser.notificationsEnabled as AnyObject
            param["notificationChannels"]  = CurrentUser.notificationsChannels as AnyObject
            //param["location"]           =  CurrentUser.location
            //param["pushTokens"]            =  (CurrentUser.pushTokens ?? []) as AnyObject
            param["countFollowing"]        =  CurrentUser.countFollowing as AnyObject
            param["countFlags"]            =  CurrentUser.countFlags as AnyObject
            
            self.updateRefCode(param: param)
            
        } else  {
            let alert = UIAlertController(title: "Alert", message: CommonTexts.CODE_ALERT_MESSAGE, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func skipBtnTap(sender: UIButton) {
        self.mz_dismissFormSheetController(animated: true, completionHandler: nil)
    }

    private func initialSetup() {
        self.containerView.layer.cornerRadius = 5.0
        self.containerView.layer.masksToBounds = true
        self.descTextLbl.text = CommonTexts.WELCOME_POPUP_DESC_TEXT
        self.codeTextFld.layer.cornerRadius = 5.0
        self.codeTextFld.layer.masksToBounds = true
        self.goBtn.layer.cornerRadius = 5.0
        self.goBtn.layer.masksToBounds = true
    }    
}

//MARK:- UITextFieldDelegate extension
//MARK:-
extension WelcomePopupVC: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard let text = textField.text else { return true }
        self.code = textField.text!
        let newLength = text.characters.count + string.characters.count - range.length
        return newLength <= 8
        
    }
    
}

extension WelcomePopupVC {

     func updateRefCode(param: [String : AnyObject]) {
        
        let userId = CurrentUser.userId ?? ""
        WebServiceController.updateUserService(parameters: param, userId: userId) { (sucess, DataHeaderResponse, DataResultResponse) in
            CommonFunctions.hideLoader()
            if sucess {
                UserDefaults.setStringVal(value: self.code as AnyObject, forKey: NSUserDefaultKeys.VIAUSER)
                self.mz_dismissFormSheetController(animated: true, completionHandler: nil)
            } else {
                let alert = UIAlertController(title: "Alert", message: CommonTexts.INVALID_LOGIN, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }

}
