//
//  BeepCommentLikesVC.swift
//  Fantasticoh!
//
//  Created by Appinventiv on 14/10/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import UIKit

class BeepCommentLikesVC: UIViewController {

    //MARK:- IBOutlet & Propertie's
    //MARK:-
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var headingTextLbl: UILabel!
    var usersArray = [AnyObject]()
    var beepId = ""
    
    //MARK:- View Life cycle
    //MARK:-
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tblView.delegate = self
        self.tblView.dataSource = self
        
        self.bgView.layer.cornerRadius = 12.0
        self.bgView.layer.masksToBounds = true
        self.bgView.clipsToBounds = true
        self.headingTextLbl.text = "People who liked"
        
        let searchChannelUserXIB = UINib(nibName: "SearchChannelUserXIB", bundle: nil)
        self.tblView.register(searchChannelUserXIB, forCellReuseIdentifier: "SearchChannelUserXIB")
        
        self.getLikeUsers()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- IBAction, Selector & Private Method
    //MARK:-
    @IBAction func backBtnTap(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

//MARK:- UITableView Delegate & DataSource
//MARK:-

extension BeepCommentLikesVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.usersArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchChannelUserXIB", for:  indexPath) as!
        SearchChannelUserXIB
        cell.isUserInteractionEnabled = true
        cell.selectionStyle = .none
        cell.textLblTopCons.constant = 6
        cell.textLblLeadingCons.constant = 5
        cell.textLblTrailingCons.constant = 70
        cell.bottomView.backgroundColor = CommonColors.sepratorColor()
        cell.imgView.contentMode = .scaleToFill
        cell.imgView.clipsToBounds = true
        cell.textLbl.textColor = UIColor.black
        cell.tagLbl.isHidden = true
        cell.infoBtn.isHidden = true
        cell.arrowImageView.isHidden = true
        
        if let data  = self.usersArray[indexPath.row] as? [String: AnyObject] {
            
            if let meta = data["meta"] as? [String: AnyObject] {
            
                if let tempMeta = meta["userMiniResult"] as? [String: AnyObject] {
                    if let name = tempMeta["name"] as? String {
                        cell.textLbl.text = name
                    } else {
                        cell.textLbl.text = ""
                    }
                    
                    if let pic = tempMeta["avatarURLLarge"] as? String {
                        cell.imgView.sd_setImage(with: URL(string: pic), placeholderImage: PROFILEPLACEHOLDER)
                        
                    } else {
                        cell.imgView.image = PROFILEPLACEHOLDER
                    }
                } else  {
                    cell.textLbl.text = ""
                    cell.imgView.image = PROFILEPLACEHOLDER
                }
            } else  {
                cell.textLbl.text = ""
                cell.imgView.image = PROFILEPLACEHOLDER
            }
        } else {
        
            cell.textLbl.text = ""
            cell.imgView.image = PROFILEPLACEHOLDER
        }
        return cell
    }

}

//MARK:- WebService extension
//MARK:-
extension BeepCommentLikesVC {

     func getLikeUsers() {
    
        //https://api-dot-vsl-espacial.appspot.com/api/v1/bb/beep/f83b3eeaa1fc4556/likes?index=bb-beeps-feed
        CommonFunctions.showLoader()
        var url = WS_beep + "/\(self.beepId)"
        url.append("/likes?index=bb-beeps-feed")
        
        print_debug(object: url)
        WebServiceController.getListOfLikeUser(url: url, param: [String : AnyObject]()) { (sucess, errorMessage, data) in
            
            if sucess {
                
                guard let tempData = data else  { return }
                self.usersArray = tempData
                self.tblView.reloadData()

            } else {
                print_debug(object: errorMessage)
            }
            CommonFunctions.hideLoader()
        }
    }
    
}
