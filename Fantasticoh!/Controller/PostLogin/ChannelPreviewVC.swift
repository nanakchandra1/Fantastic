//
//  ChannelPreviewVC.swift
//  Fantasticoh!
//
//  Created by MAC on 4/20/17.
//  Copyright © 2017 AppInventiv. All rights reserved.
//
import UIKit

protocol ChannelPreviewVCDelegate {
    func showChannelDetail(index : IndexPath)
}

class ChannelPreviewVC: UIViewController {
    
    //MARK:- @IBOutlet & Propertie's
    //MARK:-
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var lbl: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    
    
    weak var delegate: TabBarDelegate!
    weak var allTagVCDelegate: AllTagVCDelegate!
    var channelViewFanVCState = ChannelViewFanVCState.None
    var channelId = ""
    var msg = ""
    var isFriend = false
    var channelName = ""
    var channelImgUrl = ""
    var channelDesc = ""
    var indexPath = IndexPath(row: 0, section: 0)
    
    var ChannelPreviewVCDelegate: ChannelPreviewVCDelegate!
    
    //MARK:- View Life Cycle
    //MARK:-
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imageView.layer.cornerRadius = self.imageView.frame.height/2
        self.imageView.clipsToBounds = true
        self.imageView.contentMode = .scaleToFill
        self.lbl.text = channelName
        self.descriptionLabel.text = channelDesc
        if channelImgUrl.isEmpty {
            self.imageView.image = CHANNELLOGOPLACEHOLDER
        } else {
            self.imageView.sd_setImage(with: URL(string: channelImgUrl), placeholderImage: CHANNELLOGOPLACEHOLDER)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @available(iOS 9.0, *)
    override var previewActionItems: [UIPreviewActionItem] {
        
        let action1 = UIPreviewAction(title: self.msg, style: .default, handler: { previewAction, viewController in
            print_debug(object: "Action One Selected")
            self.followChannel(channelId: self.channelId, follow: !self.isFriend)
        })
        
        let action2 = UIPreviewAction(title: CommonTexts.GoToChannel, style: .default, handler: { previewAction, viewController in
            print_debug(object: "GoToChannel")
            if let dele = self.ChannelPreviewVCDelegate {
                dele.showChannelDetail(index: self.indexPath)
            }
        })
        
        let action3 = UIPreviewAction(title: "Cancel", style: .default, handler: { previewAction, viewController in
            
        })
        
        
        return [action1, action2,action3]
    }
    
}


//MARK:- WebService
//MARK:-
extension ChannelPreviewVC {


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
}
