//
//  ChannelFullPreviewVC.swift
//  Fantasticoh!
//
//  Created by MAC on 6/8/17.
//  Copyright © 2017 AppInventiv. All rights reserved.
//

import UIKit

class ChannelFullPreviewVC: UIViewController {
    
    //MARK:- @IBOutlet & Propertie's
    //MARK:-
    @IBOutlet weak var channelImageView: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var fanCounterLbl: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var noDataAvalible: UILabel!
    
    weak var delegate: TabBarDelegate!
    weak var allTagVCDelegate: AllTagVCDelegate!
    
    var channelId = ""
    var msg = ""
    var isFriend = false
    var imgArrayObj = [AnyObject]()
    var previousNav: UINavigationController!
    
    //MARK:- View Life Cycle
    //MARK:-
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        self.setChannelDetail()
        
        self.noDataAvalible.isHidden = true
        self.hideShowContaint(bool: true)
        
        self.channelImageView.layer.cornerRadius = self.channelImageView.frame.height/2
        self.channelImageView.clipsToBounds = true

        self.activityIndicator.tintColor = CommonColors.globalRedColor()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
     func readMoreAction() {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier:"ChannelViewFanVC") as! ChannelViewFanVC
        vc.channelViewFanVCState = ChannelViewFanVCState.AllTagVCChannelState
        if let dele = self.allTagVCDelegate {
            vc.allTagVCDelegate = dele
        }
        
        if let dele = self.delegate {
            vc.delegate = dele
        }
        vc.channelId = self.channelId
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func hideShowContaint(bool: Bool) {
    
        self.channelImageView.isHidden    = bool
        self.nameLbl.isHidden             = bool
        self.fanCounterLbl.isHidden       = bool
        self.collectionView.isHidden      = bool
        
        self.activityIndicator.isHidden   = !bool
        
    }
    
     func getChannelDetail() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier:"ChannelViewFanVC") as! ChannelViewFanVC
        vc.delegate = TABBARDELEGATE
        vc.channelViewFanVCState = ChannelViewFanVCState.AllTagVCState
        vc.channelId = self.channelId
        if let nav  = self.previousNav {
            nav.pushViewController(vc, animated: true)
        }
        //self.navigationController?
    }
    
    
     @available(iOS 9.0, *)
     override var previewActionItems: [UIPreviewActionItem] {
        
        let action0 = UIPreviewAction(title: "Read More", style: .default, handler: { previewAction, viewController in
            self.getChannelDetail()
        })
        
        let action1 = UIPreviewAction(title: self.msg, style: .default, handler: { previewAction, viewController in
            self.followChannel(channelId: self.channelId, follow: !self.isFriend)
        })
        
        let action2 = UIPreviewAction(title: "Cancel", style: .default, handler: { previewAction, viewController in
            
        })
        
        
        return [action0, action1, action2]
    }
    

}

//MARK:- UICollectionViewDelegate
//MARK:-
extension ChannelFullPreviewVC: UICollectionViewDelegate {
//400
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        return CGSize(width: SCREEN_WIDTH, height: 500-100)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        //set HorizontalDistance
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        //return self.tagVerticalDistance
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
}


//MARK:- UICollectionViewDataSource
//MARK:-
extension ChannelFullPreviewVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.imgArrayObj.count == 0 {
            return 1
        }
        return imgArrayObj.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PreviewVCCollectionViewCell", for:  indexPath) as! PreviewVCCollectionViewCell
        if self.imgArrayObj.isEmpty {
            cell.imgView.image = CONTAINERPLACEHOLDER
        } else {
            guard let imgUrls = self.imgArrayObj[indexPath.row]["imgURLs"] as? [String : AnyObject] else {
                cell.imgView.image = CONTAINERPLACEHOLDER
                return cell
            }
            guard let url = imgUrls["img2x"] as? String else {
                cell.imgView.image = CONTAINERPLACEHOLDER
                return cell
            }
            cell.imgView.sd_setImage(with: URL(string: url), placeholderImage: CONTAINERPLACEHOLDER)
        }
        return cell
    }
    
}


//MARK:- WebService
//MARK:-
extension ChannelFullPreviewVC {
    
    
     func followChannel(channelId: String, follow: Bool) {
        
        let params: [String: AnyObject] = ["channelID" : channelId as AnyObject, "virtualChannel" : false as AnyObject, "follow": follow as AnyObject]
        
        WebServiceController.follwUnfollowChannel(parameters: params) { (sucess, errorMessage, data) in
            
            if sucess {
                if let dele = TABBARDELEGATE {
                    dele.sideMenuUpdate()
                }
                print_debug(object: "You click on follow btn.")
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
    
     func setChannelDetail() {
        
        
        if channelId.isEmpty  {
            self.hideShowContaint(bool: true)
            self.noDataAvalible.isHidden = false
            return }
        
        WebServiceController.getMiniChannelDetail(channelId: self.channelId) { (success, errorMessage, data) in
            if success {
                
                guard let channelData = data else { return }

                if let imgUrl = channelData["avatarURLLarge"] as? String {
                    self.channelImageView.sd_setImage(with: URL(string: imgUrl), placeholderImage: CHANNELLOGOPLACEHOLDER)
                }
                
                if let name = channelData["name"] as? String {
                    self.nameLbl.text = name
                } else { self.nameLbl.text = "" }
                
                if let count = channelData["countFollowers"]?.int64Value {
                    self.fanCounterLbl.text = count > 1 ? "\(count) Fans" : "\(count) Fan"
                } else {
                    self.fanCounterLbl.text = "0 Fan"
                }
                
                if let text  = self.nameLbl.text, text.isEmpty {
                    self.noDataAvalible.isHidden = false
                    self.hideShowContaint(bool: true)
                } else {
                    self.noDataAvalible.isHidden = true
                    self.hideShowContaint(bool: false)
                }
                
                
            } else  {
                self.collectionView.reloadData()
                self.noDataAvalible.isHidden = false
                self.hideShowContaint(bool: true)
                print_debug(object: errorMessage)
            }
            
        }
        
    }

    
    
    
}

//MARK:- UICollectionViewCell class
//MARK:-
class PreviewVCCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imgView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.imgView.contentMode = .center
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.imgView.contentMode = .center
    }
}
