//
//  ExploreContentSearchVC.swift
//  Fantasticoh!
//
//  Created by Appinventiv on 19/09/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import UIKit

protocol ExploreContentSearchDelegate {
    func resetSetSearhBarText(text: String)
    func setChannelText(text: String)
}

protocol EndEditingDelegate {
    func searchBarEditing(bool: Bool)
}

enum ExploreContentSearchState {
    case Channels, Content, None
}

enum SetContentSearchState {
    case Channels, Content, None
}

class ExploreContentSearchVC: UIViewController {

    //MARK:- IBOutlet & Propertie's
    //MARK:-
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var channelsBtn: UIButton!
    @IBOutlet weak var contentBtn: UIButton!
    @IBOutlet weak var movableView: UIView!
    
    @IBOutlet weak var movableSepratorLeadingCons: NSLayoutConstraint!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    weak var delegate: TabBarDelegate!
    var exploreChannelsVC: ExploreChannelsVC!
    var exploreContentVC: ExploreContentVC!
    var exploreContentSearchState = ExploreContentSearchState.None
    var textFieldInsideSearchBar: UITextField!
    var setContentSearchState = SetContentSearchState.None
    
    var channelSearchText = ""
    var contentSearchText = ""
    var moveKeyboard = true
    
    //MARK:- ViewLife cycle
    //MARK:-
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initSetup()
        Globals.setScreenName(screenName: "Search", screenClass: "Search")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        APP_DELEGATE.statusBarStyle = UIStatusBarStyle.default
        
        if !self.contentSearchText.isEmpty {
            if let obj = self.exploreContentVC {
                obj.searchContentText(text: contentSearchText)
            }
            
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        APP_DELEGATE.statusBarStyle = UIStatusBarStyle.lightContent
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        exploreChannelsVC.view.frame = CGRect(x:0,y: 0,width: SCREEN_WIDTH,height: self.scrollView.frame.size.height)
        exploreContentVC.view.frame = CGRect(x:SCREEN_WIDTH,y: 0,width: SCREEN_WIDTH,height: self.scrollView.frame.size.height)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        //self.searchBar.endEditing(true)
    }
    
    //MARK:- IBOutlet & Propertie's
    //MARK:-
    
    func keyboardWillShow(notification: NSNotification) {
        
        if self.moveKeyboard {
            if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                print_debug(object: keyboardSize)
                APP_DELEGATE.windows.first?.frame.origin.y = 500//-(keyboardSize.height)
            }
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        
        if self.moveKeyboard {
            
            if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                print_debug(object: keyboardSize)
                APP_DELEGATE.windows.first?.frame.origin.y = 0
            }
            
        }
        
    }
    
     func initSetup() {
        
        self.searchBar.delegate = self
        self.searchBar.enablesReturnKeyAutomatically = true
        self.searchBar.returnKeyType = UIReturnKeyType.search
        
        
        textFieldInsideSearchBar = self.searchBar.value(forKey: "searchField") as? UITextField
        self.scrollViewSetup()
        
        self.stateSetup()
        //self.activityIndicator.color = CommonColors.globalRedColor()
    }
    
     func stateSetup() {
        if self.setContentSearchState == SetContentSearchState.Channels {
            self.channelsBtnTap(sender: self.channelsBtn)
            self.searchBar.becomeFirstResponder()
        } else if self.setContentSearchState == SetContentSearchState.Content {
            self.contentBtnTap(sender: self.contentBtn)
            //self.searchBar.becomeFirstResponder()
            self.searchBar.delegate?.searchBar!(self.searchBar, textDidChange: self.contentSearchText)
        } else if self.setContentSearchState == SetContentSearchState.None {
            self.channelsBtnTap(sender: self.channelsBtn)
        }
        
        /*
        if self.setContentSearchState == SetContentSearchState.Content {
            self.contentBtnTap(self.contentBtn)
            self.searchBar.delegate?.searchBar!(self.searchBar, textDidChange: self.contentSearchText)
        } else  {
            self.channelsBtnTap(self.channelsBtn)
        }*/
    }
    
     func scrollViewSetup() {
        
        self.scrollView.delegate = self
        
        exploreChannelsVC = self.storyboard!.instantiateViewController(withIdentifier:"ExploreChannelsVC") as! ExploreChannelsVC
        exploreChannelsVC.exploreContentSearchDelegate = self
        //exploreChannelsVC.endEditingDelegate = self
        self.addChildViewController(exploreChannelsVC)
        self.scrollView.addSubview(exploreChannelsVC.view)
        exploreChannelsVC.didMove(toParentViewController: self)
        exploreChannelsVC.view.frame = CGRect(x:0,y: 0,width: SCREEN_WIDTH,height: self.scrollView.frame.size.height)
        
        exploreContentVC = self.storyboard!.instantiateViewController(withIdentifier:"ExploreContentVC") as! ExploreContentVC
        //exploreContentVC.endEditingDelegate = self
        exploreContentVC.exploreContentSearchDelegate = self
        self.addChildViewController(exploreContentVC)
        self.scrollView.addSubview(exploreContentVC.view)
        exploreContentVC.didMove(toParentViewController: self)
        
        self.scrollView.contentSize = CGSize(width: SCREEN_WIDTH * 2,height: 0)
        
        CommonFunctions.delay(delay: 0.4) {
            self.exploreChannelsVC.activityIndiacator.isHidden = false
            self.exploreChannelsVC.searchChannel(text: self.channelSearchText)
            var param: [String: AnyObject] = [String: AnyObject]()
            param["query"]              = self.channelSearchText as AnyObject
            param["from"]               = 0 as AnyObject
            param["size"]               = 10 as AnyObject
            //self.exploreContentVC.getDashBoardData(param: param)
        }
    }
    
    @IBAction func channelsBtnTap(sender: UIButton) {
        exploreContentSearchState = .Channels
        self.chagneStateScreenSet()
        self.scrollView.setContentOffset(CGPoint(x:0,y: 0), animated: true)
        self.movableSepratorLeadingCons.constant = 0
        
    }
    
    @IBAction func contentBtnTap(sender: UIButton) {
        exploreContentSearchState = .Content
        self.chagneStateScreenSet()
        self.scrollView.setContentOffset(CGPoint(x:(SCREEN_WIDTH),y: 0), animated: true)
        self.movableSepratorLeadingCons.constant = SCREEN_WIDTH/2
        
    }
}


//MARK:- UIScrollViewDelegate
//MARK:-
extension ExploreContentSearchVC: UIScrollViewDelegate {
    
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
            exploreContentSearchState = .Channels
            self.chagneStateScreenSet()
        } else {
            exploreContentSearchState = .Content
            self.chagneStateScreenSet()
        }
    }
    
     func chagneStateScreenSet() {
        self.searchBar.endEditing(true)
        if self.exploreContentSearchState == .Channels {
            self.textFieldInsideSearchBar?.textColor = CommonColors.lightGrayColor()
            self.searchBar.placeholder = "Search Channels"
            self.channelsBtn.setTitleColor(CommonColors.globalRedColor(), for:  .normal)
            self.contentBtn.setTitleColor(CommonColors.tabBarLblGrayColor(), for:  .normal)
            if !self.channelSearchText.isEmpty {
                self.searchBar.text = self.channelSearchText
            } else {
                self.searchBar.text = ""
            }
        } else  {
            self.textFieldInsideSearchBar?.textColor = CommonColors.lightGrayColor()//CommonColors.globalRedColor()
            self.searchBar.placeholder = "Search Everything"
            self.contentBtn.setTitleColor(CommonColors.globalRedColor(), for:  .normal)
            self.channelsBtn.setTitleColor(CommonColors.tabBarLblGrayColor(), for:  .normal)
            if !self.contentSearchText.isEmpty {
                self.searchBar.text = self.contentSearchText
            } else {
                self.searchBar.text = ""
            }
        }
        
    }
    
}

//MARK:- UISearchBarDelegate Extension
//MARK:-
extension ExploreContentSearchVC : UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        // nitin
        if searchBar.text?.characters.count == 0 && text == " " {
            return false
        }
        
        let characterset = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.- ")
        if text.rangeOfCharacter(from: characterset.inverted, options: String.CompareOptions.caseInsensitive, range: nil) != nil{
            return false
        } else {
            return true
        }
        
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        // nitin
        let  searchString = searchText.removeExcessiveSpaces
        
        
        if exploreContentSearchState == .Channels {
            exploreChannelsVC.notFoundLbl.isHidden = true
            if searchBar.text?.characters.count == 0 ||  searchBar.text?.characters.count == 1 {
                self.exploreChannelsVC.activityIndiacator.isHidden = true
            } else {
                self.exploreChannelsVC.activityIndiacator.isHidden = false
                self.exploreChannelsVC.activityIndiacator.startAnimating()
            }
            
            self.exploreChannelsVC.searchChannelText(text: searchString.removeExcessiveSpaces)
            self.channelSearchText = searchText.removeExcessiveSpaces
            
            // nitin
            
            self.exploreContentVC.descriptionText = [String]()
            self.exploreContentVC.finalHeight = [CGFloat]()
            self.exploreContentVC.tags = [[String]]()
            self.exploreContentVC.beepData = [AnyObject]()
            self.exploreContentVC.searchTags = ""
            self.exploreContentVC.from = 0
            self.exploreContentVC.nextCount  = 1
            self.exploreContentVC.tblView.reloadData()
            self.contentSearchText = searchText.removeExcessiveSpaces
            self.exploreContentVC.noDataLbl.isHidden = true
            self.exploreContentVC.activityIndicator.isHidden = false
            self.exploreContentVC.activityIndicator.startAnimating()
            self.exploreContentVC.searchContentText(text: searchString.getSearchFormatedString())
            
        } else if exploreContentSearchState == .Content {
            
            //let vc = self.storyboard?.instantiateViewController(withIdentifier:"SuggestionSearchVC") as! SuggestionSearchVC
            //self.navigationController?.pushViewController(vc, animated: false)
            
            /*
            self.sugessionTableViewContainer.isHidden = false
            self.sugessionTblView.isHidden = false
            if searchBar.text?.characters.count == 0 ||  searchBar.text?.characters.count == 1 {
                self.sugessionTableViewContainer.isHidden = true
                self.activityIndicator.isHidden = true
            } else {
                self.sugessionTableViewContainer.isHidden = false
                self.activityIndicator.startAnimating()
                self.activityIndicator.tintColor = CommonColors.globalRedColor()
                self.activityIndicator.isHidden = false
                self.sugessionTblView.isHidden = true
                self.suggestionData = [AnyObject]()
                self.searchKeyword(searchText.removeWhitespace())
            }*/
            
            /*
            self.exploreContentVC.noDataLbl.isHidden = true
            if searchBar.text?.characters.count == 0 ||  searchBar.text?.characters.count == 1 {
                self.exploreContentVC.activityIndicator.isHidden = true
            } else {
                self.exploreContentVC.activityIndicator.isHidden = false
                self.exploreContentVC.activityIndicator.startAnimating()
            }
            self.exploreContentVC.searchContentText(searchText.removeWhitespace()) 
            self.contentSearchText = searchText.removeWhitespace()*/
        }
        
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        if exploreContentSearchState == .Content {
            let vc = self.storyboard?.instantiateViewController(withIdentifier:"SuggestionSearchVC") as! SuggestionSearchVC
            vc.exploreContentSearchDelegate = self
            self.navigationController?.pushViewController(vc, animated: false)
            
            // nitin
            if !self.contentSearchText.isEmpty {
            CommonFunctions.delay(delay: 0.1, closure: {
                
                    vc.searchBar.text = self.contentSearchText
                vc.searchKeyword(text: self.contentSearchText.getSearchFormatedString())
                
            })
            }
        }
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
        self.view.endEditing(true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        /*
        if self.setContentSearchState == SetContentSearchState.Channels {
            
            self.searchBar.text = self.searchBarText
            self.searchBar.endEditing(true)
            self.exploreChannelsVC.searchChannelText(self.searchBar.text!)
            //self.setContentSearchState = SetContentSearchState.None
            self.searchBar.text = ""
            
        } else if setContentSearchState == SetContentSearchState.Content {
            
            self.searchBar.text = self.searchBarText
            self.searchBar.endEditing(true)
            self.exploreContentVC.searchContentText(self.searchBar.text!)
            self.setContentSearchState = SetContentSearchState.None
            
        } else if setContentSearchState == SetContentSearchState.None {
            print_debug(object: "None")
        }
        self.setContentSearchState = SetContentSearchState.None */
        return true
    }
    
    
}

//MARK:- ExploreContentSearchDelegate
//MARK:-
extension ExploreContentSearchVC: ExploreContentSearchDelegate {

    func resetSetSearhBarText(text: String) {
        self.searchBar.delegate?.searchBar!(self.searchBar, textDidChange: text)
        //let tempText = self.searchBar.text ?? ""
        //let currentText = "#" + tempText + " " + text
        self.searchBar.text = text.removeExcessiveSpaces
        //self.setContentSearchState = SetContentSearchState.Content
        //self.searchBar.becomeFirstResponder()
        
    }

    func setChannelText(text: String) {
        self.searchBar.resignFirstResponder()
        self.searchBar.endEditing(true)
        self.searchBar.text = text.removeExcessiveSpaces
        self.contentSearchText = text.removeExcessiveSpaces
        
        self.exploreContentVC.noDataLbl.isHidden = true
        self.exploreContentVC.activityIndicator.isHidden = false
        self.exploreContentVC.activityIndicator.startAnimating()
        self.exploreContentVC.searchContentText(text: text)
        
        // nitin
        if text.characters.count == 0 ||  text.characters.count == 1 {
            self.exploreChannelsVC.activityIndiacator.isHidden = true
        } else {
            self.exploreChannelsVC.activityIndiacator.isHidden = false
            self.exploreChannelsVC.activityIndiacator.startAnimating()
        }
        self.exploreChannelsVC.searchArray.removeAll()
        self.exploreChannelsVC.tblView.reloadData()
        self.exploreChannelsVC.from = 0
        self.exploreChannelsVC.size = 1000
        self.exploreChannelsVC.searchChannelText(text: text)
        self.channelSearchText = text.removeExcessiveSpaces
        
    }

}

//MARK:- EndEditingDelegate
//MARK:-
extension ExploreContentSearchVC: EndEditingDelegate {
    
    func searchBarEditing(bool: Bool) {
        self.searchBar.text = ""
    }
}
