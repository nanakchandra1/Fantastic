//
//  ExploreChannelsVC.swift
//  Fantasticoh!
//
//  Created by Appinventiv on 19/09/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import UIKit
//import IQKeyboardManager

class ExploreChannelsVC: UIViewController {
    
    //MARK:- IBOutlet & Propertie's
    //MARK:-
    
    @IBOutlet weak var notFoundLbl: UILabel!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var activityIndiacator: UIActivityIndicatorView!
    
    weak var delegate: TabBarDelegate!
    var endEditingDelegate: EndEditingDelegate!
    var exploreContentSearchDelegate: ExploreContentSearchDelegate!
    var searchArray = [AnyObject]()
    var from = 0
    var size = 1000
    var channelSearchText = ""
    //MARK:- View Life cycle
    //MARK:-
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tblView.delegate = self
        self.tblView.dataSource = self
        
        self.activityIndiacator.isHidden = true
        self.notFoundLbl.isHidden = true
        self.tblView.isHidden = true
        
        let searchChannelUserXIB = UINib(nibName: "SearchChannelUserXIB", bundle: nil)
        self.tblView.register(searchChannelUserXIB, forCellReuseIdentifier: "SearchChannelUserXIB")
        self.notFoundLbl.isHidden = true
        self.tblView.isHidden = true
        self.channelSearchText = ""
        self.tblView.estimatedRowHeight = 45
        self.tblView.rowHeight = UITableViewAutomaticDimension
        self.activityIndiacator.color = CommonColors.globalRedColor()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print_debug(object: "Will Appear...")
        print_debug(object: self.channelSearchText)
        if !self.channelSearchText.isEmpty {
            if let dele = self.exploreContentSearchDelegate {
                dele.setChannelText(text: self.channelSearchText)
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        //self.view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK:- IBOutlet & Propertie's
    //MARK:-
    
    internal func searchChannelText(text: String) {
        
        if text.characters.count >= 2 {
            self.channelSearchText = text.removeExcessiveSpaces
            self.searchChannel(text: text.getSearchFormatedString())
        } else  {
            self.notFoundLbl.isHidden = true
            self.tblView.isHidden = true
            self.searchArray.removeAll(keepingCapacity: false)
            self.tblView.reloadData()
        }
        
    }
    
     func infoBtnTap(sender: UIButton) {
        
        guard CommonFunctions.checkLogin() else {
            CommonFunctions.showLoginAlert(vc: self)
            return
        }
        let currentRow = sender.tableViewIndexPath(tableView: self.tblView)!.row
        
        print_debug(object: currentRow)
        
        print_debug(object: self.searchArray[currentRow])
        
        guard let channelID = self.searchArray[currentRow]["id"] as? String else { return }
        if !sender.isSelected {
            print_debug(object: "oN")
            CommonFunctions.fanBtnOnFormatting(btn: sender)
            //sender.setTitleColor(UIColor.white, for:  .Selected)
            self.followChannel(channelId: channelID, follow: true)
            self.showSharePopup(name: self.searchArray[currentRow]["name"]  as? String ?? "")
        } else {
            print_debug(object: "oFF")
            CommonFunctions.fanBtnOffFormatting(btn: sender)
            //sender.setTitleColor(CommonColors.fanlblTextColor(), for:  .Selected)
            self.followChannel(channelId: channelID, follow: false)
        }
        
        sender.isSelected = !sender.isSelected
        
        /*
        let indexPath = sender.tableViewIndexPath(tableView: self.tblView)!
        
        guard let selectedChannel = self.searchArray[indexPath.row] as? AnyObject else { return }
        guard let channelID = selectedChannel["id"] as? String else { return }
        if let deleg = self.endEditingDelegate {
            deleg.searchBarEditing(true)
        }
        if let dele = self.delegate {
            //CommonFunctions.hideKeyboard()
            dele.exploreChannel(channelID, searchStr: self.channelSearchText, state: false)
            
            print_debug(object: channelID)
        }
        
         */
        /*CommonFunctions.hideKeyboard()
        let vc = self.storyboard?.instantiateViewController(withIdentifier:"ChannelViewFanVC") as! ChannelViewFanVC
        self.navigationController?.pushViewController(vc, animated: true)
        */
        
    /*
        let indexPath = sender.tableViewIndexPath(tableView: self.tblView)!
        print(indexPath.row)
        if let data  = self.searchArray[indexPath.row] as? [String: AnyObject] {
            
            if let id = data["id"] as? String {
                
                print(id)
            }
        }
        
        print("INfo TAbl")*/
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

//MARK:- UITableView Delegate & DataSource Extension
//MARK:-
extension ExploreChannelsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45.0
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchChannelUserXIB", for:  indexPath) as!
        SearchChannelUserXIB
        cell.isUserInteractionEnabled = true
        cell.selectionStyle = .none
        cell.textLblTopCons.constant = 1
        cell.textLblLeadingCons.constant = 5
        cell.tagLbl.isHidden = false
        cell.textLblTrailingCons.constant = 70 + 20
        cell.bottomView.backgroundColor = CommonColors.sepratorColor()
        cell.fanBtnSetup()
        //cell.infoBtn.isUserInteractionEnabled = true
        cell.infoBtn.addTarget(self, action: #selector(ExploreChannelsVC.infoBtnTap(sender:)), for: .touchUpInside)
        
        if let data  = self.searchArray[indexPath.row] as? [String: AnyObject] {
           
            if let pic = data["avatarURL"] as? String {
            
                cell.imgView.sd_setImage(with: URL(string: pic), placeholderImage: CHANNELLOGOPLACEHOLDER)
                cell.imgView.contentMode = .scaleToFill
                cell.imgView.clipsToBounds = true
                
            }
            //cell.imgView.image = UIImage(named: "dp1")
            
            if let name = data["name"] as? String {
                cell.textLbl.text = name
            }
            
            if let hashtags = data["categoryTags"] as? NSArray {
                
                var tagString = ""
                if hashtags.count > 0 {
                    if let str = hashtags.lastObject as? [String] {
                        _ = str.map({ (temp: String) in
                            if !temp.hasPrefix("_") {
                                //tagString.append("#\(temp)")
                                tagString.append("#\(temp) ")
                            }
                            
                        })
                    }
                }
                cell.tagLbl.text = tagString
            } else {
                cell.tagLbl.text = ""
            }

            cell.textLbl.textColor = UIColor.black
            
            if let currentCellFanId  = data["id"]  as? String {
                if let list = UserDefaults.getStringArrayVal(key: NSUserDefaultKeys.FRIENDSLIST) as? [String] {
                    print_debug(object: "List Id : \(list)")
                    print_debug(object: "current cell Id : \(currentCellFanId)")
                    for temp in list{
                        print_debug(object: "temp Id : \(temp)")
                        if temp == currentCellFanId {
                            CommonFunctions.fanBtnOnFormatting(btn: cell.infoBtn)
                            cell.infoBtn.isSelected = true
                            break
                        } else {
                            CommonFunctions.fanBtnOffFormatting(btn: cell.infoBtn)
                            cell.infoBtn.isSelected = false
                        }
                    }
                    
                } else {
                    CommonFunctions.fanBtnOffFormatting(btn: cell.infoBtn)
                    cell.infoBtn.isSelected = false
                }
                
                if let status = data["isUserFan"] as? Bool, status == true {
                    CommonFunctions.fanBtnOnFormatting(btn: cell.infoBtn)
                    cell.infoBtn.isSelected = true
                }
                
            } else {
                CommonFunctions.fanBtnOffFormatting(btn: cell.infoBtn)
                cell.infoBtn.isSelected = false
                
            }

            
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let selectedChannel = self.searchArray[indexPath.row] as? AnyObject else { return }
        guard let channelID = selectedChannel["id"] as? String else { return }
        
        let channelViewFanVC = self.storyboard?.instantiateViewController(withIdentifier:"ChannelViewFanVC") as! ChannelViewFanVC
        channelViewFanVC.channelId = channelID
        if let nationality = selectedChannel["displayLabels"] as? [String], nationality.count > 0 {
            channelViewFanVC.displayLabel = nationality
        }
        channelViewFanVC.channelViewFanVCState = ChannelViewFanVCState.ExploreChannelVC
        self.navigationController?.pushViewController(channelViewFanVC, animated: true)

    }
    
}

//MARK:- Webservice
//MARK:-
extension ExploreChannelsVC {
    
     func searchChannel(text: String) {
        
        //let param: [String : AnyObject] = ["name" : text, "from" : self.from, "size" : self.size]
        print_debug(object: text + "dAZ     ")
        
        let trimmedString = text.trimmingCharacters(in: .whitespaces)
        
        print_debug(object: trimmedString + "334     ")
        
        let url = WS_SearchChannel + "?text=\(trimmedString)"
        
        if CommonFunctions.verifyUrl(urlString: url) {
        
            print_debug(object: "true")
        } else {
            print_debug(object: "false")
            return
        }
        
        
        WebServiceController.searchChannelsService(url: url) { (success, data) in
            
            self.activityIndiacator.isHidden = true
            guard success else {
                self.notFoundLbl.isHidden = false
                self.tblView.isHidden = true
                return
            }
            
            if let searchData = data {
                
                if searchData.count > 0 {
                    self.notFoundLbl.isHidden = true
                    self.tblView.isHidden = false
                    self.searchArray = searchData
                    self.tblView.reloadData()
                    
                } else  {
                    self.notFoundLbl.isHidden = false
                    self.tblView.isHidden = true
                }
                
            }
            
            
            
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
                    if let list = UserDefaults.getStringArrayVal(key: NSUserDefaultKeys.FRIENDSLIST) as? [String], list.count > 0 {
                        var tempList = list
                        var index = 0
                        for tempChannelId in tempList {
                            if tempChannelId == channelId {
                                break
                            }
                            index = index + 1
                        }
                        tempList.remove(at: index)
                        UserDefaults.setStringVal(value: tempList as AnyObject, forKey: NSUserDefaultKeys.FRIENDSLIST)
                    }
                }
                
            } else {
                print_debug(object: errorMessage)
            }
        }
    }
}

extension ExploreChannelsVC : shareDelegate {
    func shareData() {
        CommonFunctions.displayShareSheet(shareContent: SHARE_Fantasticoh_URL, viewController: self)
    }
}
