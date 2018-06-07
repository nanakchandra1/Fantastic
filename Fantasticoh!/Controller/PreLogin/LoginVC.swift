//
//  LoginVC.swift
//  Fantasticoh!
//
//  Created by Shubham on 7/27/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import UIKit


class LoginVC: UIViewController  {
    
    //MARK:- IBOutlet and Properties
    //MARK:-
    @IBOutlet weak var loginFBBtn: UIButton!
    @IBOutlet weak var loginGoogleBtn: UIButton!
    @IBOutlet weak var skipBtn: UIButton!
    //@IBOutlet weak var fbbtnConstraints: NSLayoutConstraint!
    //@IBOutlet weak var googlebtnConstraints: NSLayoutConstraint!
    @IBOutlet weak var skipbtnConstraints: NSLayoutConstraint!
    
    //MARK:- View Life Cycle
    //MARK:-
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initialSetup()
        GIDSignIn.sharedInstance().uiDelegate = self as GIDSignInUIDelegate
        GIDSignIn.sharedInstance().delegate = self as GIDSignInDelegate
        
        //LoginButtonAnimation.fbButtonAnimation(self.loginFBBtn, btnConstraint: self.fbbtnConstraints, constraintVal: 12, googleBtn: self.loginGoogleBtn, googleBtnCons: self.googlebtnConstraints, skipBtn: self.skipBtn, view: self.view)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        APP_DELEGATE.statusBarStyle = UIStatusBarStyle.lightContent
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK:- IBAction, Selector & Private Method
    //MARK:-
    @IBAction func loginFBBtnTap(sender: UIButton) {
        APP_DELEGATE.statusBarStyle = UIStatusBarStyle.default
        self.loginWithFB()
    }
    
    
    @IBAction func loginGoogleBtnTap(sender: UIButton) {
        APP_DELEGATE.statusBarStyle = UIStatusBarStyle.default
        GIDSignIn.sharedInstance().signOut()
        GIDSignIn.sharedInstance().signIn()
        
    }
    
    
    @IBAction func skipBtnTap(sender: UIButton) {
        //self.dismissViewControllerAnimated(true, completion: nil)
       // SHARED_APP_DELEGATE.window?.rootViewController = self.storyboard?.instantiateViewController(withIdentifier:"TabBarVC") as! TabBarVC
        let vc = self.storyboard?.instantiateViewController(withIdentifier:"TabBarVC") as! TabBarVC
        vc.home3DTouchState = Home3DTouchState.Home
        let navi = UINavigationController(rootViewController: vc)
        navi.navigationBar.isHidden = true
        SHARED_APP_DELEGATE.window?.rootViewController = navi
    }
    
    private func initialSetup() {
        
        self.loginFBBtn.backgroundColor = CommonColors.fbBtnColor()
        self.loginGoogleBtn.backgroundColor = CommonColors.googleBtnColor()
        
        self.loginFBBtn.isHidden = false
        self.loginGoogleBtn.isHidden = false
        self.skipBtn.isHidden = false
        
        self.loginFBBtn.alpha = 1.0
        self.loginGoogleBtn.alpha = 1.0
        self.skipBtn.alpha = 1.0
        
//        self.fbbtnConstraints.constant = -(120 + 45)
//        self.googlebtnConstraints.constant = -(300 + 40 + 45)
//        self.skipbtnConstraints.constant = 10
        self.view.layoutIfNeeded()
        
        self.loginFBBtn.layer.cornerRadius = 5
        self.loginFBBtn.layer.masksToBounds = true
        
        self.loginGoogleBtn.layer.cornerRadius = 5
        self.loginGoogleBtn.layer.masksToBounds = true
    }
    
    private func loginWithFB() {
        
        let login = FBSDKLoginManager()
        login.logOut()
        
        
        login.logIn(withReadPermissions: ["email","public_profile"], from: self) { (result, error) in
            if error != nil{
                print_debug(object: "\(String(describing: error))")
                CommonFunctions.hideLoader()
            }
            else if (result?.isCancelled)! {
                CommonFunctions.hideLoader()
            }
            else {
                CommonFunctions.hideLoader()
                if (result?.grantedPermissions.contains("email"))!{
                    CommonFunctions.showLoader()
                    let facebookParam = ["fields" : "id, email, name, first_name, last_name, gender, picture.type(large)  "]
                    
                    if FBSDKAccessToken.current() != nil{
                        
                        
                        FBSDKGraphRequest(graphPath: "me", parameters: facebookParam).start(completionHandler: { (connection, result, erroe) in
                            
                            if let result = result as? [String : AnyObject] {
                                var param = [ "platform": "ios",
                                              "facebookID": "",
                                              "facebookToken": "",
                                              "name": "",
                                              "email": "",
                                              "bio": "Entrepreneur",
                                              "avatarURL": "",
                                              "country": "",
                                              "birthYear": 1978,
                                              "gender": -1] as [String : Any]
                                
                                if let tempId = result["id"]  as? String {
                                    param["facebookID"] = tempId
                                    let picUrl = "https://graph.facebook.com/\(tempId)/picture?type=large"
                                    param["avatarURL"] =  picUrl
                                }
                                
                                if let tempAccessToken = FBSDKAccessToken.current().tokenString {
                                    param["facebookToken"] = tempAccessToken
                                }
                                
                                if let tempName = result["name"]  as? String {
                                    param["name"] =  tempName
                                }
                                
                                if let tempEmail = result["email"]  as? String {
                                    param["email"] =  tempEmail
                                }
                                
                                // if let picUrl = result.objectForKey("picture.type(large)")  as? String {
                                //  param["avatarURL"] =  picUrl
                                // }
                                CommonFunctions.showLoader()
                                self.loginUser(param: param as [String : AnyObject])
                                
                            }
                        })
                    }
                    
                }
                
            }
        }
        
        
        
        
        
        
    }
    
}

//MARK:- Google SignIn Delegagte
//MARK:-
extension LoginVC : GIDSignInUIDelegate, GIDSignInDelegate {
   

    
    // pressed the Sign In button
    func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
    }
    
    // Present a view that prompts the user to sign in with Google
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        self.present(viewController, animated: true, completion: nil)
    }
    
    // Dismiss the "Sign in with Google" view
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        self.dismiss(animated: true, completion: nil)
    }
    
     func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        if error != nil {
            CommonFunctions.hideLoader()
            print_debug(object: "We got error at Google signIn time \(error)")
            
        } else {
            CommonFunctions.showLoader()
            print_debug(object: "Sucessfully google signIn \(user.profile.name)")
            
            var param = [ "platform": "ios",
                          "googleID": "",
                          "googleToken": "",
                          "name": "",
                          "email": "",
                          "bio": "Entrepreneur",
                          "avatarURL": "",
                          "country": "",
                          "birthYear": 1978,
                          "gender": -1] as [String : Any]
            
            
            if let tempId = user.userID {
                param["googleID"] = tempId
            }
            
            if let tempAccessToken = user.authentication.accessToken {
                param["googleToken"] = tempAccessToken
            }
            
            if let tempName = user.profile.name {
                param["name"] =  tempName
            }
            
            if let tempEmail = user.profile.email {
                param["email"] =  tempEmail
            }
            
            var imageUrl: NSURL!
            if user.profile.hasImage {
                imageUrl = user.profile.imageURL(withDimension: 400)! as NSURL
                
                param["avatarURL"] = imageUrl.absoluteString
            }
            
            //TODO update code.
            
            print_debug(object: param)
            
            self.loginUser(param: param as [String : AnyObject])
            
            /*
             let tempCookHeader = "MTQ4NzkyMDE5MXxoUWVnT1dNTkxHQ3dPU0p4bnNQYV9PeExTMmlBQ0JicFhpei1zcWZrTWx1TE9FQktOT21ocmtpUzRxcWVxeEE4NTlHWEhIeFNEa25XdkE9PXyri4JEj_h14kjb5nkS769BlfkMuhW-08GNDa-S1GXdlg=="
             UserDefaults.setStringVal(tempCookHeader, forKey: tempCookHeader)
             
             _ = CurrentUser(param: [String : AnyObject]())
             UserDefaults.setBoolVal(true, forKey: NSUserDefaultKeys.ISLOGIN)
             
             let tabBarVC = self.storyboard?.instantiateViewController(withIdentifier:"TabBarVC") as! TabBarVC
             let vc = UINavigationController(rootViewController: tabBarVC)
             vc.navigationBar.isHidden = true
             vc.willMoveToParentViewController(self)
             SHARED_APP_DELEGATE.window?.rootViewController = vc
             */
            
            
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        print_debug(object: "didDisconnectWithUser")
    }
}

//MARK:- Webservice
//MARK:
extension LoginVC {
    
    func loginUser(param: [String : AnyObject]) {
        
        //        var tempParam = param
        //        //tempParam["pushTokens"] = SHARED_APP_DELEGATE.deviceToken
        //
        //        print(SHARED_APP_DELEGATE.deviceToken)
        //
        //        print(tempParam)
        
        WebServiceController.loginService(parameters: param) { (sucess, DataHeaderResponse, DataResultResponse) in
            
            print_debug(object: "______________")
            print_debug(object: DataResultResponse)
            
            CommonFunctions.hideLoader()
            guard sucess else {
                let presentAlert = CommonFunctions.showAlert(title: CommonTexts.INVALID_LOGIN_TITLE, message: CommonTexts.INVALID_LOGIN, btnLbl: "OK")
                self.present(presentAlert, animated: true, completion: nil)
                return
            }
            
            //Verify is new user or not
            var isNewUser = false
            guard let data = DataResultResponse else {
                return
            }
            if let newUser = data["newUser"] as? Bool {
                isNewUser = newUser
            }
            
            
            //Response header store in UserDefault
            if let dataHeader = DataHeaderResponse {
                if let cookieAddress = dataHeader["X-Bbsc"] as? String {
                    
                    UserDefaults.setStringVal(value: cookieAddress as AnyObject, forKey: NSUserDefaultKeys.COOKIEADDRESS)
                }
            }
            
            //Save user information
            if let result = DataResultResponse {
                _ = CurrentUser(param: result)
                UserDefaults.setBoolVal(state: true, forKey: NSUserDefaultKeys.ISLOGIN)
                
                print_debug(object: CurrentUser.createTime)
                print_debug(object: CurrentUser.loginTime)
                print_debug(object: CurrentUser.loginIP)
            }
            
            if isNewUser {
                let countryVC = self.storyboard?.instantiateViewController(withIdentifier:"CountryVC") as! CountryVC
                let navController = UINavigationController(rootViewController: countryVC)
                navController.navigationBar.isHidden = true
                self.present(navController, animated:true, completion: nil)
                
            } else {
                let tabBarVC = self.storyboard?.instantiateViewController(withIdentifier:"TabBarVC") as! TabBarVC
                let vc = UINavigationController(rootViewController: tabBarVC)
                vc.navigationBar.isHidden = true
                vc.willMove(toParentViewController: self)
                SHARED_APP_DELEGATE.window?.rootViewController = vc
                
            }
        }
        
        
    }
}
