//
//  SuggestionSearchVC.swift
//  Fantasticoh!
//
//  Created by MAC on 6/5/17.
//  Copyright © 2017 AppInventiv. All rights reserved.
//

import UIKit

class SuggestionSearchVC: UIViewController {
    
    //MARK:- IBOutlet & Propertie's
    //MARK:-
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var noDataFoundLbl: UILabel!
    
    var exploreContentSearchDelegate: ExploreContentSearchDelegate!
    var suggestionData  =   [AnyObject]()
    
    //MARK:- ViewLife cycle
    //MARK:-
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tblView.delegate = self
        self.tblView.dataSource = self
        self.searchBar.delegate = self
        self.activityIndicator.tintColor = CommonColors.globalRedColor()
        
        self.searchBar.becomeFirstResponder()
        self.searchBar.setShowsCancelButton(true, animated: true)
        self.noDataFoundLbl.isHidden = true
        self.activityIndicator.stopAnimating()
        self.activityIndicator.isHidden = true
        self.tblView.isHidden = true
        self.tblView.estimatedRowHeight = 50
        self.tblView.rowHeight = UITableViewAutomaticDimension
        //self.searchBar.enablesReturnKeyAutomatically = false
        self.activityIndicator.color = CommonColors.globalRedColor()
        
        // nitin
        self.noDataFoundLbl.text = CommonTexts.NoContentAvailable
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        APP_DELEGATE.statusBarStyle = UIStatusBarStyle.default
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.view.endEditing(true)
    }
    
}


//MARK:- UITableView delegate & datasource
//MARK:-
extension SuggestionSearchVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print_debug(object: self.suggestionData.count)
        return self.suggestionData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        //print_debug(object: self.suggestionData[indexPath.row])
        //crash//
        // nitin
        if indexPath.row >= self.suggestionData.count {
            cell.textLabel?.text = ""
        } else {
            cell.textLabel?.text = self.suggestionData[indexPath.row]["name"] as? String ?? ""
        }
        cell.textLabel?.font = CommonFonts.SFUIDisplay_Medium(setsize: 13.5)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print_debug(object: indexPath.row)
        
        self.navigationController?.popViewController(animated: false)
        let searchText = self.suggestionData[indexPath.row]["name"] as? String ?? ""
        self.exploreContentSearchDelegate.setChannelText(text: searchText)
        
        //self.searchBar.text = searchText.removeWhitespace()
        //self.exploreContentVC.searchContentText(searchText.removeWhitespace())
        //self.contentSearchText = searchText.removeWhitespace()
        
    }
    
}



//MARK:- UISearchBarDelegate Extension
//MARK:-
extension SuggestionSearchVC : UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        // nitin
        if searchBar.text?.characters.count == 0 && text == " " {
            return false
        }
        // nitin
        let characterset = NSCharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.- \n")

        if text.rangeOfCharacter(from: characterset.inverted) != nil {
            return false
        } else {
            return true
        }
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // nitin
        let searchText = searchText.removeExcessiveSpaces.getSearchFormatedString()
        
        if searchText.isEmpty {
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
            self.noDataFoundLbl.isHidden = true
            self.tblView.isHidden = true
            return
        }
        
        self.activityIndicator.startAnimating()
        self.activityIndicator.isHidden = false
        self.noDataFoundLbl.isHidden = true
        self.tblView.isHidden = true
        self.suggestionData = [AnyObject]()
        self.searchKeyword(text: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
        
        // nitin
        self.navigationController?.popViewController(animated: false)
        let searchText = searchBar.text?.removeExcessiveSpaces
        self.exploreContentSearchDelegate.setChannelText(text: searchText!)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
        self.exploreContentSearchDelegate.setChannelText(text: self.searchBar.text ?? "")
        self.navigationController?.popViewController(animated: false)
        //searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        
        //searchBar.resignFirstResponder()
        //searchBar.showsCancelButton = true
        //searchBar.setShowsCancelButton(true, animated: false)
        //self.enableCancleButton(searchBar)
    }
    
    func searchBarResultsListButtonClicked(_ searchBar: UISearchBar) {
        
        
    }
    
    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        
    }
    
}



//MARK:- WebService's
//MARK:-
extension SuggestionSearchVC {
    
    func searchKeyword(text: String ) {
        
        let url = WS_Dashboard_Sudession //+ "?query=\(text)"
        var param = [String : AnyObject]()
        param["query"]      = text as AnyObject
        
        WebServiceController.beepsKeywordSugession(url: url, parameters: param) { (sucess, errorMessage, data) in
            
            
            if data == nil && !sucess {
                self.noDataFoundLbl.isHidden = false
                self.activityIndicator.isHidden = true
                self.tblView.isHidden = true
                print_debug(object: errorMessage); return
            }
            
            guard let getData = data,  !getData.isEmpty else {
                self.tblView.isHidden    = true
                self.activityIndicator.isHidden    = true
                self.noDataFoundLbl.isHidden      = false
                return }
            self.suggestionData = getData
            self.tblView.reloadData()
            self.noDataFoundLbl.isHidden = true
            self.activityIndicator.isHidden = true
            self.tblView.isHidden = false
        }
        
    }
    
    func hideContent() {
        self.activityIndicator.startAnimating()
        self.activityIndicator.isHidden = true
    }
    
}


