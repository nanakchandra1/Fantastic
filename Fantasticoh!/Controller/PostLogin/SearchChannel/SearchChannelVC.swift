//
//  SearchChannelVC.swift
//  Fantasticoh!
//
//  Created by Appinventiv on 13/09/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import UIKit
import MessageUI

enum CurrentState {
    case Search, Normal, None
}

enum SearchChannelVCState {
    case SuggestedChannelsVC, HomeVC, ProfileVC, None
}

enum PrevioudDataIsAvalible {
    case Avalible, NotAvalible, None
}

class SearchChannelVC: UIViewController {
    
    //MARK:- IBOutlet & Propertie's
    //MARK:-
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tblView: UITableView!
    
    var from = 0
    var size = 1000
    var searchArray = [AnyObject]()
    var currentState = CurrentState.None
    var seeMoreState = false
    var searchTempText = [AnyObject]()
    
    var tendingImg = [UIImage(named: "dp1"), UIImage(named: "dp2"), UIImage(named: "dp1"), UIImage(named: "dp2")]
    var tendingText = ["Virat", "Megan", "Mila", "Brad"]
    
    var previoudDataIsAvalible = PrevioudDataIsAvalible.None
    var searchChannelVCState = SearchChannelVCState.None
    var featureChannel = [String: AnyObject]()
    var multiDelegate: AnyObject!
    
    //MARK:- View Life cycle
    //MARK:-
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.searchBar.delegate = self
        self.tblView.delegate = self
        self.tblView.dataSource = self
        self.searchBar.enablesReturnKeyAutomatically = true
        self.searchBar.returnKeyType = UIReturnKeyType.search
        
        let searchChannelUserXIB = UINib(nibName: "SearchChannelUserXIB", bundle: nil)
        self.tblView.register(searchChannelUserXIB, forCellReuseIdentifier: "SearchChannelUserXIB")
        
        let seeAllCell = UINib(nibName: "SeeAllCell", bundle: nil)
        self.tblView.register(seeAllCell, forCellReuseIdentifier: "SeeAllCell")
        
        //MARK: hide search icon.
        let textFieldInsideSearchBar = self.searchBar.value(forKey: "searchField") as! UITextField
        textFieldInsideSearchBar.leftViewMode = UITextFieldViewMode.never
        
        if let arr = UserDefaults.getCustomArrayVal(key: NSUserDefaultKeys.CHANNELSEARCHARRAY) {
            self.searchTempText = arr
        } else {
            print_debug(object: "Recent search data not found.")
        }
        
        self.currentState = .Normal
        self.searchBar.becomeFirstResponder()
        
        if self.previoudDataIsAvalible == PrevioudDataIsAvalible.Avalible {
            print_debug(object: self.featureChannel.count)
        } else {
            self.getFeatureChannelList()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        APP_DELEGATE.statusBarStyle = UIStatusBarStyle.default
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        APP_DELEGATE.statusBarStyle = UIStatusBarStyle.lightContent
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        searchBar.setShowsCancelButton(false, animated: true)
        self.searchBar.endEditing( true )
    }
    
    
    //MARK:- IBAction & Selector Method
    //MARK:-

    @IBAction func backBtnTap(sender: UIButton) {
        self.view.endEditing(true)
        IsShowTap = true
        switch self.searchChannelVCState {
        case .SuggestedChannelsVC :
            if let dele = self.multiDelegate as? SuggestedChannelVCDelegate {
                dele.afterSearchChannelDataReset()
            }
            
        case .HomeVC :
            ALLTAGVCDELEGATE.beepDataReload()
            
        case .ProfileVC :
            if let dele = self.multiDelegate as? ProfileVCDelegate {
                dele.afterSearchChannelDataReset()
            }
            
        default:
            self.dismiss(animated: true) {
                APP_DELEGATE.statusBarStyle = UIStatusBarStyle.lightContent
            }
        }
        self.dismiss(animated: true) {
            APP_DELEGATE.statusBarStyle = UIStatusBarStyle.lightContent
        }
 
    }
    
    @IBAction func requestNewChannelBtnTap(sender: UIButton) {
        self.view.endEditing(true)
        self.sendMail(subject: NEW_CHANNEL_TITLE)
        
    }
    
    func seeAllBtnTap(sender: UIButton) {
        self.view.endEditing(true)
        self.seeMoreState = true
        self.tblView.reloadData()
    }
    
    func fansDetails(channelId: String, displayList: [String]) {
        IsShowTap = false
        let vc = self.storyboard?.instantiateViewController(withIdentifier:"ChannelViewFanVC") as! ChannelViewFanVC
        vc.channelViewFanVCState = ChannelViewFanVCState.AllTagVCChannelState
        if let dele = ALLTAGVCDELEGATE {
            vc.allTagVCDelegate = dele
        }

        if let dele = TABBARDELEGATE {
            vc.delegate = dele
        }
        vc.channelId = channelId
        vc.displayLabel = displayList
        self.navigationController?.pushViewController(vc, animated: true)
        
//        print_debug(object: selectedData)
//        let VC1 = self.storyboard!.instantiateViewController(withIdentifier:"ChannelViewFanVC") as! ChannelViewFanVC
//        let navController = UINavigationController(rootViewController: VC1)
////        navController.navigationBar.isHidden = true
//        navController.pushViewController(VC1, animated: true)
////        self.present(navController, animated:true, completion: nil)
        
        
        
//        SHARED_APP_DELEGATE.window = UIWindow(frame: UIScreen.mainScreen().bounds)
//        let nav1 = UINavigationController()
//        let mainView = ChannelViewFanVC(nibName: nil, bundle: nil) //ViewController = Name of your controller
//        nav1.viewControllers = [mainView]
//        
//        SHARED_APP_DELEGATE.window!.rootViewController = nav1
//        SHARED_APP_DELEGATE.window?.makeKeyAndVisible()

//        let vc = self.storyboard?.instantiateViewController(withIdentifier:"ChannelViewFanVC") as! ChannelViewFanVC
//
//        nav1.pushViewController(vc, animated: true)
//        
//        self.navigationController?.pushViewController(vc, animated: true)
        
        //vc.pushViewController(channelViewFanVC, animated: true)
        
//        self.dismiss(animated: true) { 
//        
//            let vc = self.storyboard?.instantiateViewController(withIdentifier:"ChannelViewFanVC") as! ChannelViewFanVC
//            self.navigationController?.pushViewController(vc, animated: true)
//        }
//        
        
        /*
         let vc = self.storyboard?.instantiateViewController(withIdentifier:"ChannelViewFanVC") as! ChannelViewFanVC
         self.navigationController?.pushViewController(vc, animated: true)
         */
        /*
        let rootTabBarController = SHARED_APP_DELEGATE.window?.rootViewController as! UINavigationController
        
        let firstVC = self.storyboard?.instantiateViewController(withIdentifier:"TabBarVC") as! TabBarVC
        rootTabBarController.viewControllers[0] = firstVC
        
        let channelViewFanVC = self.storyboard?.instantiateViewController(withIdentifier:"ChannelViewFanVC") as! ChannelViewFanVC
        //self.firstVC?.pushViewController(vc, animated: true)
        rootTabBarController.pushViewController(channelViewFanVC, animated: true)
        */

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
        mailComposerVC.setToRecipients([REQUEST_NEW_CHANNEL_EMAIL])
        mailComposerVC.setSubject(subject)
        mailComposerVC.setMessageBody("<p>\("")</p> <br> User Name: \(CurrentUser.name ?? "Guest User") <br> iOS Version: \(iOSVersion) <br> iPhone Model: \(UIDevice.current.modelName) <br> App Version: \(appVersionString)", isHTML: true)
        //mailComposerVC.setMessageBody("Body", isHTML: false)
        //self.present(mailComposerVC, animated: true, completion: nil)
        self.present(mailComposerVC, animated: true, completion: {
            APP_DELEGATE.statusBarStyle = .default
        })
    }
}

//MARK:- UITableView Delegate & DataSource Extension
//MARK:-
extension SearchChannelVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if currentState == CurrentState.Search {
            return 1
        } else {
            
            if self.seeMoreState {
                return 1
            } else {
                return 2
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if currentState == CurrentState.Search {
            return self.searchArray.count
        } else {
            
            if self.seeMoreState {
                return self.searchTempText.count
                
            } else {
                if section == 0 {
                    if searchTempText.count <= 2 {
                        return searchTempText.count
                    } else  {
                        return 3
                    }
                } else {
                    //return self.tendingText.count
                    if let result = self.featureChannel["results"] as? [AnyObject] {
                        return (result.count)
                    } else {
                        return 0
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if currentState == CurrentState.Search {
            return 0
        } else {
            
            if self.seeMoreState {
                return 0
                
            } else {
                
                if section == 0 {
                
                    if searchTempText.count != 0 {
                        return 28
                    } else {
                        return 0
                    }
                } else  {
                    return 28
                }
                
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        
        if currentState == CurrentState.Search {
            return UIView()
        } else {
            
            if self.seeMoreState {
                return UIView()
                
            } else {
                
                let header = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 28.0))
                header.backgroundColor = CommonColors.tableSectionHeaderBGColor()
                let lbl = UILabel(frame: CGRect(x: 12, y: 0, width: 200, height: 28))
                lbl.textColor = UIColor.black
                lbl.font = CommonFonts.SFUIText_Bold(setsize: 17.0)//(17.0)
                header.addSubview(lbl)
                if section == 0 {
                    lbl.text = "Recently Searched"
                } else {
                    lbl.text = "Trending"
                }
                return header
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Search Users
        if currentState == CurrentState.Search {
        
            let cell = tableView.dequeueReusableCell(withIdentifier: "SearchChannelUserXIB", for:  indexPath) as!
            SearchChannelUserXIB
            cell.selectionStyle = .none
            cell.contentView.backgroundColor = .clear
            cell.infoBtn.isHidden = true
            cell.arrowImageView.isHidden = true
            cell.bottomView.isHidden = true
            if let data  = self.searchArray[indexPath.row] as? [String: AnyObject] {
                
                // When search result found.
                if (data["id"] as? String) != nil {
                    cell.textLblTopCons.constant = 1
                    cell.textLblLeadingCons.constant = 5
                    cell.tagLbl.isHidden = false
                    cell.imgView.contentMode = .scaleToFill
                    cell.imgView.clipsToBounds = true
                    
                    cell.imgView.image = UIImage(named: "dp1")
                    
                    if let name = data["name"] as? String {
                        cell.textLbl.text = name
                    }
                    
                    if let imgUrl = data["avatarURL"] as? String {
                        cell.imgView.sd_setImage(with: URL(string: imgUrl) , placeholderImage: CHANNELLOGOPLACEHOLDER)
                    } else  {
                        cell.imgView.image = CHANNELLOGOPLACEHOLDER
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
                    
                    
                    
                        
//                    if indexPath.row == 0 {
//                        cell.textLbl.textColor = UIColor.black
//                    } else {
//                        cell.textLbl.textColor = UIColor.black
//                    }
                    cell.textLbl.textColor = UIColor.black
                } else {
                    // When search result not found.
                    cell.textLblTopCons.constant = 6
                    cell.textLblLeadingCons.constant = 8
                    cell.tagLbl.isHidden = true
                    cell.imgView.contentMode = .center
                    cell.imgView.clipsToBounds = true
                    
                    if let img = data["image"] as? UIImage {
                        cell.imgView.image = img
                    }
                    
                    if let name = data["text"] as? String {
                        cell.textLbl.text = name
                    }
                    if indexPath.row == 0 {
                        cell.textLbl.textColor = UIColor.black
                    } else {
                        cell.textLbl.textColor = CommonColors.globalRedColor()
                    }
                }
            }
            return cell
        } else {
            
            
            if self.seeMoreState {
            
                //Recent Search
                let cell = tableView.dequeueReusableCell(withIdentifier: "SearchChannelUserXIB", for:  indexPath) as!
                SearchChannelUserXIB
                cell.selectionStyle = .none
                cell.infoBtn.isHidden = true
                cell.arrowImageView.isHidden = true
                cell.bottomView.isHidden = true
                cell.textLblTopCons.constant = 6
                cell.textLblLeadingCons.constant = 8
                cell.tagLbl.isHidden = true
                cell.imgView.contentMode = .center
                cell.imgView.clipsToBounds = true
                cell.imgView.contentMode = .center
                cell.imgView.clipsToBounds = true
                
                cell.imgView.image = UIImage(named: "ghadi")
                if let data  = self.searchTempText[indexPath.row] as? [String: AnyObject] {
                    
                    if let name = data["name"] as? String {
                        cell.textLbl.text = name
                    }
                }

                return cell
                
            } else {
            
            // Sugesation Table View Block
                if indexPath.section == 0 {
                // Section zero recent search block
                    
                switch indexPath.row {
                case 0,1:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "SearchChannelUserXIB", for:  indexPath) as!
                    SearchChannelUserXIB
                    cell.selectionStyle = .none
                    cell.infoBtn.isHidden = true
                    cell.arrowImageView.isHidden = true
                    cell.bottomView.isHidden = true
                    cell.textLblTopCons.constant = 6
                    cell.textLblLeadingCons.constant = 8
                    cell.tagLbl.isHidden = true
                    cell.imgView.contentMode = .center
                    cell.imgView.clipsToBounds = true
                    cell.textLbl.textColor = UIColor.black

                    cell.imgView.image = UIImage(named: "ghadi")
                    if let data  = self.searchTempText[indexPath.row] as? [String: AnyObject] {
                        
                        if let name = data["name"] as? String {
                            cell.textLbl.text = name
                        }
                    }
                    return cell
    
                default:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "SeeAllCell", for:  indexPath) as!
                    SeeAllCell
                    // Nitin
                    //cell.btnLeadingCons.constant = 50
                    cell.seeAllBtn.setTitle("See More...", for:  .normal)
                    cell.seeAllBtn.addTarget(self, action: #selector(SearchChannelVC.seeAllBtnTap(sender:)), for: UIControlEvents.touchUpInside)
                    cell.topView.isHidden = true
                    cell.bottomView.isHidden = true
                    return cell
                }
                
            } else  {
                
                // Section one Trending block
                let cell = tableView.dequeueReusableCell(withIdentifier: "SearchChannelUserXIB", for:  indexPath) as!
                SearchChannelUserXIB
                cell.selectionStyle = .none
                cell.infoBtn.isHidden = true
                cell.arrowImageView.isHidden = true
                cell.bottomView.isHidden = true
                cell.textLblTopCons.constant = 6
                cell.textLblLeadingCons.constant = 8
                cell.tagLbl.isHidden = true
                cell.imgView.contentMode = .scaleToFill
                cell.imgView.clipsToBounds = true
                cell.textLbl.textColor = UIColor.black
                    
                //cell.textLbl.text = self.tendingText[indexPath.row]
                //cell.imgView.image = UIImage(named: "dp1")
                    
                    if let result = self.featureChannel["results"] as? [AnyObject] {
                        
                        cell.textLbl.text = result[indexPath.row]["name"]  as? String ?? ""
                        
                        if let imgUrl = result[indexPath.row]["avatarURLLarge"] as? String {
                            
                            cell.imgView.sd_setImage(with: URL(string: imgUrl), placeholderImage: CHANNELLOGOPLACEHOLDER)
                            
                        } else {
                            
                            cell.imgView.image = CHANNELLOGOPLACEHOLDER
                        }
                    }

                return cell
            }
            }
            
        }
    }
    // nitin
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.searchBar.endEditing(true)
        if currentState == CurrentState.Search {
            if indexPath.row >= self.searchArray.count {
                return
            }
            let selectedData = self.searchArray[indexPath.row]
            self.saveChannelAndDetail(selectedData: selectedData)
        } else {
            
            if self.seeMoreState {
                if indexPath.row >= self.searchTempText.count {
                    return
                }
                let selectedData = self.searchTempText[indexPath.row]
                self.saveChannelAndDetail(selectedData: selectedData)
//                if let selectedId = selectedData["id"] as? String {
//                    self.fansDetails(selectedId)
//                }
            } else {
                if indexPath.section == 0 {
                    if searchTempText.count <= 2 {
                        if indexPath.row >= self.searchTempText.count {
                            return
                        }
                        let selectedData = self.searchTempText[indexPath.row]
                         self.saveChannelAndDetail(selectedData: selectedData)
//                        if let selectedId = selectedData["id"] as? String {
//                            self.fansDetails(selectedId)
//                        }
                    } else  {
                        if indexPath.row <= 2 {
                            if indexPath.row >= self.searchTempText.count {
                                return
                            }
                            let selectedData = self.searchTempText[indexPath.row]
                            self.saveChannelAndDetail(selectedData: selectedData)
//                            if let selectedId = selectedData["id"] as? String {
//                                self.fansDetails(selectedId)
//                            }
                        } else {
                            self.view.endEditing(true)
                            self.seeMoreState = true
                            self.tblView.reloadData()
                        }
                    }
                } else {
                    guard let result = self.featureChannel["results"] as? [AnyObject] else { return }
                    if indexPath.row >= result.count {
                        return
                    }
                    guard let selectedData = result[indexPath.row] as? AnyObject else  { return }
                    self.saveChannelAndDetail(selectedData: selectedData)
                }
            }
        }
        
    }
    
    // nitin
    private func saveChannelAndDetail(selectedData: AnyObject) {
    
        var flag = true
        var counter = 0
        for tem in self.searchTempText {
            if let tempId = tem["id"] as? String{
                if let selectedId = selectedData["id"] as? String {
                    if tempId == selectedId {
                        flag = false
                        break
                    }
                }
            }
            counter += 1
        }
        
        if flag {
            self.searchTempText.insert(selectedData, at: 0)
            UserDefaults.setCustomArrayVal(value: self.searchTempText, forKey:  NSUserDefaultKeys.CHANNELSEARCHARRAY)
        } else {
            self.searchTempText.remove(at: counter)
            self.searchTempText.insert(selectedData, at: 0)
            UserDefaults.setCustomArrayVal(value: self.searchTempText, forKey:  NSUserDefaultKeys.CHANNELSEARCHARRAY)
        }
        if let selectedId = selectedData["id"] as? String {
            
            if let displayLabel = selectedData["displayLabels"] as? [String]{
               self.fansDetails(channelId: selectedId, displayList: displayLabel)
            }
            
        }
        
        self.tblView.reloadData()
    }
    
}

//MARK:- UISearchBarDelegate Extension
//MARK:-
extension SearchChannelVC : UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        // nitin
        if searchBar.text?.characters.count == 0 && text == " " {
            return false
        }
        
        let characterset = CharacterSet(charactersIn:  "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.- ")
        if text.rangeOfCharacter(from: characterset.inverted, options: String.CompareOptions.caseInsensitive) != nil {
            return false
        } else {
            return true
        }
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        // nitin 
        let  searchText = searchText.getSearchFormatedString()
        
        //if searchText.con
        
        self.seeMoreState = false

        if searchText.characters.count >= 2 {
            self.currentState = .Search
            self.searchChannel(text: searchText)
        } else {
            if self.searchArray.count == 0 && searchText.characters.count == 0 {
                self.currentState = .Normal
                print_debug(object: "Data search...")
                self.searchArray.removeAll(keepingCapacity: false)
                self.tblView.reloadData()
            } else if self.searchArray.count != 0 {
                self.currentState = .Normal
                self.searchArray.removeAll(keepingCapacity: false)
                self.tblView.reloadData()
            }
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if (searchBar.text?.characters.count)! >= 2 {
            self.currentState = .Search
        } else  {
            self.currentState = .Normal
            print_debug(object: "Data search...")
            
        }
        self.tblView.reloadData()
        searchBar.setShowsCancelButton(true, animated: true)
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
        //searchBar.text = ""
        searchBar.setShowsCancelButton(false, animated: true)
//        self.dismiss(animated: true) { 
//            APP_DELEGATE.statusBarStyle = UIStatusBarStyle.lightContent
//        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    
    
}

//MARK:- Webservice
//MARK:-
extension SearchChannelVC {
    
     func searchChannel(text: String) {
        
        let url = WS_SearchChannel + "?text=\(text)"
        
        WebServiceController.searchChannelsService(url: url) { (success, data) in
            
            guard success else {
                return
            }
            
            if let searchData = data {
                
                if searchData.count > 0 {
                    
                    self.searchArray = searchData
                    self.tblView.reloadData()
                } else {
                    
                    //var dic =  [AnyObject]()
                    
                    /*let dic = [ ["image" : UIImage(named: "sad")!, "text": "No such channel found"],
                     ["image" : UIImage(named: "request_channel")!, "text": "Request channel: \(text)"] ] */
                    let dic = [ ["image" : UIImage(named: "sad")!, "text": "No such channel found"]]
                    
                    //dic.append(dic1)
                    //dic.append(dic2)
                    self.searchArray.removeAll(keepingCapacity: false)
                    self.searchArray = dic as [AnyObject]
                }
                self.tblView.reloadData()
            }
            
        }
    }
    
    
     func getFeatureChannelList() {
        
        CommonFunctions.showLoader()
        let params = ["from" : 0, "size" : 100 ]
        WebServiceController.getFeatureChannelList(parameters: params as [String : AnyObject]) { (success, errorMessage, data) in
            
            if success {
                
                if let channels = data {
                    self.featureChannel = channels
                    
                    print_debug(object: self.featureChannel)
                    print_debug(object: self.featureChannel.count)
                    
                    self.tblView.reloadData()
                } else {
                    print_debug(object: errorMessage)
                }
                
            } else {
                print_debug(object: errorMessage)
            }
            CommonFunctions.hideLoader()
        }
        
    }
}



//MARK:- Mail Delegate
//MARK:-
extension SearchChannelVC: MFMailComposeViewControllerDelegate {
    
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

