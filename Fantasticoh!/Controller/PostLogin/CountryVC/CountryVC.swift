//
//  SelectDenVC.swift
//  Fantasticoh!
//
//  Created by Appinventiv on 09/08/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import UIKit

protocol SendDataDelegate : class {
    func sendData(text:Int)
}

class CountryVC: UIViewController {
    
    //MARK:- IBOutlet & Propertie's
    //MARK:-
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var notFoundLbl: UILabel!
    @IBOutlet weak var navigationLabel: UILabel!
    
    var sectionVal       = [String]()
    var rowVal           = [[[String: String]]]()
    var filterSectionVal = [String]()
    var filterRowVal     = [[[String: String]]]()
    var lastSelectedIndexPath: IndexPath?
    var lastSelectedCountry = [String: String]()
    var birthYear        = Int()
    let sections = ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"]

    //MARK:- View Life Cycle
    //MARK:-
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.searchBar.delegate = self
        
        self.tableView.sectionIndexColor = CommonColors.globalRedColor()
        self.searchBar.enablesReturnKeyAutomatically = false
        self.searchBar.returnKeyType = UIReturnKeyType.default
        self.getCountryList()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        searchBar.setShowsCancelButton(false, animated: true)
        self.searchBar.endEditing( true )
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    //MARK:- IBAction, Selector & Private method's
    //MARK:-
    @IBAction func cancelBtnTap(sender: UIButton) {
        searchBar.setShowsCancelButton(false, animated: true)
        self.searchBar.endEditing( true )
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func doneBtnTap(sender: UIButton) {
        
        self.searchBar.endEditing( true )
        
        if let selected = lastSelectedIndexPath {
            CommonFunctions.showLoader()
            let countryCode = self.filterRowVal[selected.section][selected.row]["code"] ?? ""
            var param   =  [String : AnyObject]()
            
            param["country"]            =  countryCode as AnyObject
            param["birthYear"]          =  self.birthYear as AnyObject
            
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
            param["gender"]             =  0 as AnyObject
            param["notificationsEnabled"]  = CurrentUser.notificationsEnabled as AnyObject
            param["notificationChannels"]  = CurrentUser.notificationsChannels as AnyObject
            //param["location"]           =  CurrentUser.location
            //param["pushTokens"]            =  (CurrentUser.pushTokens ?? []) as AnyObject
            param["countFollowing"]        =  CurrentUser.countFollowing as AnyObject
            param["countFlags"]            =  CurrentUser.countFlags as AnyObject
            
            print_debug(object: param)
            self.loginUser(param: param)
            
        } else  {
            let alert = CommonFunctions.showAlert(title: CommonTexts.COUNTRY_ALERT_MESSAGE_TITLE, message: CommonTexts.COUNTRY_ALERT_MESSAGE_TEXT, btnLbl: "OK")
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
     func setPopup() {
        
        let alertPopup = self.storyboard?.instantiateViewController(withIdentifier:"BirthYearSelectVC") as! BirthYearSelectVC
        alertPopup.delegate = self
        let formSheet = MZFormSheetController(size: CGSize(width: SCREEN_WIDTH - ((SCREEN_WIDTH*100)/600),height: SCREEN_HEIGHT - ((SCREEN_HEIGHT*300)/600)), viewController: alertPopup)
        formSheet.shouldCenterVertically = true
        formSheet.transitionStyle = MZFormSheetTransitionStyle.dropDown
        formSheet.shouldDismissOnBackgroundViewTap = false
        formSheet.present(animated: true, completionHandler: nil)
    }
}

//MARK:- UITableView Delegate & DataSource
//MARK:-
extension CountryVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.filterSectionVal.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filterRowVal[section].count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if self.filterSectionVal[section] == "" {
            return 0.0
        } else {
            return 25.0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return  self.filterSectionVal
    }
    
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        
        let temp = self.filterSectionVal as NSArray
        return temp.index(of: title)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let header = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 20.0))
        header.backgroundColor = UIColor.white
        let lbl = UILabel(frame: CGRect(x: 15, y: header.bounds.height/2, width: 20, height: 16))
        lbl.textColor = CommonColors.globalRedColor()
        lbl.font = CommonFonts.SFUIText_Medium(setsize: 18.0)
        lbl.text = self.filterSectionVal[section]
        header.addSubview(lbl)
        return header
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CountryCell", for:  indexPath) as! CountryCell
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.nameLbl.text = self.filterRowVal[indexPath.section][indexPath.row]["name"] ?? ""
        cell.accessoryType = .none
        cell.accessoryType = (self.filterRowVal[indexPath.section][indexPath.row] == self.lastSelectedCountry) ? .checkmark : .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.cellForRow(at: indexPath)!.accessoryType = .checkmark
        self.lastSelectedIndexPath = indexPath
        
        self.lastSelectedCountry = self.filterRowVal[indexPath.section][indexPath.row] //?? [String: String]()
        
        if let cell = self.tableView.cellForRow(at: indexPath) as? CountryCell {
            let ip = self.tableView.indexPathsForVisibleRows
            self.tableView.reloadRows(at: ip!, with: .none)
            cell.accessoryType = (self.filterRowVal[indexPath.section][indexPath.row] == self.lastSelectedCountry) ? .checkmark : .none
        }
 
        print_debug(object: self.lastSelectedIndexPath)
        print_debug(object: self.lastSelectedCountry)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.none
    }
    
}

//MARK:- WebService Method's
//MARK:-
extension CountryVC {
    
     func loginUser(param: [String : AnyObject]) {
        
        let userId = CurrentUser.userId ?? ""
        
        WebServiceController.updateUserService(parameters: param, userId: userId) { (sucess, DataHeaderResponse, DataResultResponse) in
            
            guard sucess else {
                CommonFunctions.hideLoader()
                let presentAlert = CommonFunctions.showAlert(title: CommonTexts.INVALID_LOGIN_TITLE, message: CommonTexts.INVALID_LOGIN, btnLbl: "OK")
                self.present(presentAlert, animated: true, completion: nil)
                return
            }
            
            if param.keys.count > 1 {
                
                UserDefaults.setBoolVal(state: true, forKey: NSUserDefaultKeys.ISNEWUSER)
                CommonFunctions.hideLoader()
                let tabBarVC = self.storyboard?.instantiateViewController(withIdentifier:"TabBarVC") as! TabBarVC
                let vc = UINavigationController(rootViewController: tabBarVC)
                vc.navigationBar.isHidden = true
                vc.willMove(toParentViewController: self)
                SHARED_APP_DELEGATE.window?.rootViewController = vc
            } else {
                
                UserDefaults.clean()
                self.dismiss(animated: true, completion: nil)
            }
            
        }
    }
    
     func getCountryList() {
        
        let param = [String : AnyObject]()
        CommonFunctions.showLoader()
        WebServiceController.getCountryList(parameters: param) { (success, data) in
            
            if success {
                CommonFunctions.hideLoader()
                
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
                    let countryName = country["name"]?.first
                    var arr = countryDict["\(String(describing: countryName!))"] ?? []
                    arr.append(country)
                    countryDict["\(String(describing: countryName!))"] = arr
                    print_debug(object: arr)
                    print_debug(object: countryDict)
                }
                
                let sortedCountryDict = countryDict.sorted{ $0.0 < $1.0 }
                for (key, value) in sortedCountryDict {
                    
                    self.sectionVal.append(key)
                    let sortedValues = value.sorted(by: { $0["name"]! < $1["name"]! })
                    self.rowVal.append(sortedValues)
                }
                
                self.filterSectionVal = self.sectionVal
                self.filterRowVal = self.rowVal
                self.setPopup()
                self.tableView.reloadData()
            } else {
                CommonFunctions.hideLoader()
            }
        }
        
    }
}

//MARK:- UISearchBarDelegate Extension
//MARK:-
extension CountryVC : UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.characters.count > 0
        {
            var allcountriesArr = [[String : String]]()
            //MARK: Future user to understand code.
            _ = self.filterRowVal.filter() {
                
                _ = $0.filter() {
                    
                    if $0["name"]!.lowercased().hasPrefix(searchText.lowercased()) {
                        allcountriesArr.append($0)
                        return true
                    } else {
                        return false
                    }
                }
                return false
            }
            
            var countryDict = [ String: [[String: String]] ]()
            for country in allcountriesArr {
                let countryName = country["name"]?.first
                var arr = countryDict["\(String(describing: countryName!))"] ?? []
                arr.append(country)
                countryDict["\(String(describing: countryName!))"] = arr
                print_debug(object: arr)
                print_debug(object: countryDict)
            }
            
            var tempSectionVal       = [String]()
            var tempRowVal           = [ [ [String: String] ] ]()
            for (key, value) in countryDict {
                tempSectionVal.append(key)
                let sortedValues = value.sorted(by: { $0["name"]! < $1["name"]! })
                tempRowVal.append(sortedValues)
            }
            
            self.filterSectionVal = tempSectionVal
            self.filterRowVal = tempRowVal
            
            if self.filterSectionVal.isEmpty {
                self.tableView.isHidden = true
            } else  {
                self.tableView.isHidden = false
            }
            self.tableView.reloadData()
            
        } else  {
            self.filterRowVal = rowVal
            self.filterSectionVal = sectionVal
            self.tableView.isHidden = false
            self.tableView.reloadData()
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.endEditing(true)
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.setShowsCancelButton(false, animated: true)
        self.searchBar.resignFirstResponder()
        self.filterRowVal = rowVal
        self.filterSectionVal = sectionVal
        self.tableView.reloadData()
        self.tableView.isHidden = false
    }
    
    
}

//MARK:- Birth Date delegate
//MARK:-
extension CountryVC: SendDataDelegate {
    
    func sendData(text: Int) {
        self.birthYear = text
    }
}
