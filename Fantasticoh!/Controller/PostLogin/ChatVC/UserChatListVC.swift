//
//  UserChatListVC.swift
//  Fantasticoh!
//
//  Created by MAC on 5/29/17.
//  Copyright © 2017 AppInventiv. All rights reserved.
//

//
import UIKit

class UserChatListVC: UIViewController {
    
    //MARK:- @IBOutlet & Propertie's
    //MARK:-
    @IBOutlet weak var headerLbl: UILabel!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var noDataLbl: UILabel!
    
    var usetList = [AnyObject]()
    var from = 0
    var size = 20
    
    //MARK:- ViewLife cycle
    //MARK:-
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.size = -1
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK:- @IBAction, Selector & Private method's
    //MARK:-
    private func initSetup() {
        
        self.getUsersListAPI()
        
        self.activityIndicator.color = CommonColors.globalRedColor()
        self.tblView.isHidden = true
        self.noDataLbl.isHidden = true
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
        
        self.tblView.delegate = self
        self.tblView.dataSource = self
        self.tblView.tableHeaderView = nil
        self.tblView.tableFooterView = nil
        self.tblView.register(UINib(nibName: "UserChatListXIB", bundle: nil), forCellReuseIdentifier: "UserChatListXIB")
        // nitin
        self.noDataLbl.text = CommonTexts.userListEmpty
    }
    
    @IBAction func closeBtnTap(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
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
    
    func userImageBtnTap(sender: UIButton) {
        
        guard let indexPath = sender.tableViewIndexPath(tableView: self.tblView) else { return }
        guard let creator = self.usetList[indexPath.row]["user"] as? [String : AnyObject] else { return }
        guard let uID = creator["id"] as? String else { return }
        // TODO:
        // CHECKING FOR USER ID AND NAVIGATION
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
    
    func reportBtnTap(sender: UIButton) {
        
        guard let indexPath = sender.tableViewIndexPath(tableView: self.tblView) else { return }
        guard let creator = self.usetList[indexPath.row]["user"] as? [String : AnyObject] else { return }
        guard let uID = creator["id"] as? String else { return }
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        
        let blockAction = UIAlertAction(title: "Block this user", style: .default, handler: {
            
            (alert: UIAlertAction!) -> Void in
            
            guard CommonFunctions.checkLogin() else {
                CommonFunctions.showLoginAlert(vc: self)
                return
            }
            
            let optionMenu = UIAlertController(title: CommonTexts.blockThisUser, message: nil, preferredStyle: .alert)
            
            let yesAction = UIAlertAction(title: "Yes", style: .default, handler: {
                
                (alert: UIAlertAction!) -> Void in
                
                
                
                let optionMenu = UIAlertController(title: CommonTexts.blockThisUserSure, message: nil, preferredStyle: .alert)
                
                let yesAction = UIAlertAction(title: "Yes", style: .default, handler: {
                    
                    (alert: UIAlertAction!) -> Void in
                    
                    self.blockUser(userId: uID, block: true)
                    
                    
                    //self.reportUser(userId: uID)
                })
                
                let noAction = UIAlertAction(title: "No", style: .destructive, handler: {
                    
                    (alert: UIAlertAction!) -> Void in
                    
                    
                })
                optionMenu.addAction(yesAction)
                optionMenu.addAction(noAction)
                
                self.present(optionMenu, animated: true, completion: nil)
                
                
                //self.reportUser(userId: uID)
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
        
        
        optionMenu.addAction(blockAction)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
    }
}

//MARK:- UITableViewDelegate & DataSource
//MARK:-
extension UserChatListVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.usetList.count
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "UserChatListXIB", for:  indexPath) as! UserChatListXIB
        cell.selectionStyle = .none
        
        if let unread = self.usetList[indexPath.row]["unread"] as? Bool {
            
            if unread == true {
                cell.redDotView.isHidden = false
                cell.redDotView.backgroundColor = UIColor.red
                cell.nameLbl.font = CommonFonts.SFUIText_Bold(setsize: 16)
            } else {
                cell.redDotView.isHidden = true
                cell.nameLbl.font = CommonFonts.SFUIText_Regular(setsize: 16)
            }
            
        }
        if let user = self.usetList[indexPath.row]["user"] as? [String: AnyObject] {
            cell.nameLbl.text   = user["name"] as? String ?? ""
            let url             = user["avatarURL"] as? String ?? ""
            cell.userImageView.sd_setImage(with: URL(string: url), placeholderImage: PROFILEPLACEHOLDER)
            cell.userProfileImageBtn.addTarget(self, action: #selector(self.userImageBtnTap(sender:)), for: .touchUpInside)
            cell.flagButton.addTarget(self, action: #selector(self.reportBtnTap(sender:)), for: .touchUpInside)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier:"UserChatVC") as! UserChatVC
        vc.openFromChat = OpenFromChat.ChatList
        if let tmep = self.usetList[indexPath.row] as? [String: AnyObject] {
            vc.toUserDetail = tmep
        }
        self.navigationController?.pushViewController(vc, animated: true)
        if let unread = self.usetList[indexPath.row]["unread"] as? Bool, unread == true  {
            if var obj = self.usetList[indexPath.row] as? [String : AnyObject] {
                obj["unread"] = false as AnyObject
                self.usetList[indexPath.row] = obj as AnyObject
                tableView.reloadRows(at: [indexPath], with: .none)
                
                if let user = self.usetList[indexPath.row]["user"] as? [String: AnyObject], let userId = user["id"] as? String {
                    self.markChatReadAPI(userId: userId)
                }
                
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if self.usetList.count-1 == indexPath.row {
            self.from = self.from+20
            if self.size != -1 {
                self.getUsersListAPI()
            }
        }
        
    }
    
    
}

//MARK:- Service's method's
//MARK:-
extension UserChatListVC {
    
    func getUsersListAPI() {
        
        var param = [String : AnyObject]()
        param["from"]   = self.from as AnyObject
        param["size"]   = self.size as AnyObject
        
        WebServiceController.getUserChatList(url: WS_UserChatList, parameters: param) { (sucess, errorMessage, data) in
            
            
            if sucess {
                
                guard let tempData = data else {  return }
                
                if tempData.count > 0 {
                    for temp in tempData {
                        self.usetList.append(temp)
                    }
                } else {
                    self.from = 0
                    self.size = -1
                }
                
                self.tblView.reloadData()
            }
            
            if self.usetList.count == 0 {
                self.tblView.isHidden = true
                self.noDataLbl.isHidden = false
                self.activityIndicator.isHidden = true
            } else {
                self.tblView.isHidden = false
                self.noDataLbl.isHidden = true
                self.activityIndicator.isHidden = true
            }
            
        }
    }
    
    func markChatReadAPI(userId : String) {
        DispatchQueue.global(qos: .background).async {
            
            var param = [String : AnyObject]()
            param["targetUserID"]   = userId as AnyObject
            param["read"]   = "true" as AnyObject
            WebServiceController.markChatRead(url: WS_MarkChatRead, parameters: param) { (sucess, errorMessage, data) in
                print_debug(object: data)
                print_debug(object: errorMessage)
                if sucess {
                    
                }
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
                self.usetList.removeAll()
                self.from = 0
                self.size = 20 // nitin
                self.tblView.reloadData()
                self.getUsersListAPI()
            } else {
                //CommonFunctions.showAlertWarning(msg: "Detail is not update.")
            }
            
        }
        
    }
}

