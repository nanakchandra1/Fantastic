//
//  UserChatVC.swift
//  Fantasticoh!
//
//  Created by MAC on 3/20/17.
//  Copyright © 2017 AppInventiv. All rights reserved.
//

import UIKit
import Accelerate
import Photos

enum OpenFromChat {
    
    case Channel
    case ChatList
}
// nitin
class UserChatVC: UIViewController {
    
    //MARK:- @IBOutlet & Propertie's
    //MARK:-
    @IBOutlet weak var chatTblView: UITableView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var chatTextView: UITextView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var cameraBtn: UIButton!
    @IBOutlet weak var bottomCons: NSLayoutConstraint!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var noChatLbl: UILabel!
    
    var openFromChat = OpenFromChat.Channel
    
    var picker : UIImagePickerController = UIImagePickerController()
    var toUserDetail  = [String : AnyObject]()
    var chatArrayList = [AnyObject]()
    var cameraBtnState = CameraBtnState.None
    var from = 0
    var size = 80
    var timer: Timer!
    var refreshControl: UIRefreshControl!
    
    //MARK:- ViewLife cycle
    //MARK:-
    override func viewDidLoad() {
        super.viewDidLoad()
        self.chatTblView.delegate = self
        self.chatTblView.dataSource = self
        self.chatTextView.delegate = self
        //self.chatTextView.autocorrectionType = .yes
        self.chatTblView.allowsSelection = true
        self.initSetup()
        
        self.chatTextView.enablesReturnKeyAutomatically = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardShow(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        self.timer = Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
    }
    
    func update() {
        
        //self.chatTblView.reloadData()
        
        guard let userDetail = self.toUserDetail["user"] as? [String: AnyObject] else {
            print_debug(object: "$$ user detail  not found...")
            return
        }
        
        guard let id = userDetail["id"] as? String else {
            
            print_debug(object: "$$ ID not found...")
            return }
        
        guard let uData = self.chatArrayList.first  as? [String: AnyObject] else {
            print_debug(object: "$$ uData not found.")
            self.getChatList(toUserId: id, postTime: "", isBottomScroll: true, from: self.from, isLatest: false)
            return
            //self.getLatestChat(id, postTime: "", from: 0)
            /*
             if let uData = self.chatArrayList.first as? NSArray {
             print_debug(object: "nsarrayget")
             if let postTime = uData.firstObject?["postTime"] as? String {
             print_debug(object: postTime)
             //self.getLatestChat(id, postTime: postTime, from: 0)
             self.getChatList(id, postTime: "", isBottomScroll: false, from: 0, isLatest: true)
             }
             } */
        }
        
        print_debug(object: uData)
        
        guard let postTime = uData["postTime"] as? String else {
            print_debug(object: "$$ postTime not parse..")
            
            guard uData["postTime"] != nil else {
                print_debug(object: "$$ innser postTime not parse..")
                return
            }
            return }
        
        //self.getLatestChat(id, postTime: postTime, from: 0)
        self.getChatList(toUserId: id, postTime: postTime, isBottomScroll: false, from: 0, isLatest: true)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(NSNotification.Name.UIKeyboardWillChangeFrame)
        NotificationCenter.default.removeObserver(NSNotification.Name.UIKeyboardWillHide)
        self.timer.invalidate()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- @IBAction, Selector & Private method's
    //MARK:-
    
    private func initSetup( ) {
        
        self.chatTblView.isHidden = true
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
        self.noChatLbl.isHidden = true
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.tintColor = CommonColors.globalRedColor()
        self.refreshControl.addTarget(self, action: #selector(self.refresh(sender:)), for: UIControlEvents.valueChanged)
        self.chatTblView.addSubview(refreshControl)
        
        self.chatTblView.isHidden = true
        
        self.chatTblView.estimatedRowHeight = 100
        
        self.cameraBtnState = CameraBtnState.Send
        self.cameraBtn.setImage(UIImage(), for: .normal)
        self.cameraBtn.setTitle("SEND", for: .normal)
        
        self.chatTextView.layer.cornerRadius = 5.0
        self.chatTextView.layer.masksToBounds = true
        
        self.chatTextView.layer.borderWidth = 0.5
        self.chatTextView.layer.borderColor = CommonColors.lightGrayColor().cgColor
        
        guard let userDetail = self.toUserDetail["user"] as? [String: AnyObject] else {
            self.titleLbl.text = ""
            return
        }
        
        if let id = userDetail["id"] as? String {
            ///self.getChatList(id, postTime: "", isBottomScroll: true)
            self.getChatList(toUserId: id, postTime: "", isBottomScroll: true, from: self.from, isLatest: false)
            
        }
        
        if let name = userDetail["name"] as? String {
            self.titleLbl.text = name
        } else {
            self.titleLbl.text = ""
        }
        
        self.chatTblView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 40, right: 0)
        
        // nitin
        self.noChatLbl.text = CommonTexts.StartNewChatConversationWithOtherFans
    }
    
    func refresh(sender: AnyObject) {
        
        self.refreshControl?.endRefreshing()
        
        guard let userDetail = self.toUserDetail["user"] as? [String: AnyObject] else {
            return
        }
        
        guard let id = userDetail["id"] as? String else { return }
        
        print_debug(object: self.from)
        print_debug(object: self.size)
        
        self.from = self.getNumberOfSection()
        
        //self.getChatList(id, postTime: "", isBottomScroll: false)
        self.getChatList(toUserId: id, postTime: "", isBottomScroll: false, from: self.from, isLatest: false)
        
    }
    
    func keyboardShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            
            DispatchQueue.main.async(execute: {
                
                var yOffset:CGFloat = 0
                if (self.chatTblView.contentSize.height > self.chatTblView.bounds.size.height) {
                    yOffset = self.chatTblView.contentSize.height - self.chatTblView.bounds.size.height;
                }
                self.chatTblView.setContentOffset(CGPoint(x: 0.0, y: yOffset), animated: false)
            })
            
            
            
            self.bottomCons.constant = keyboardSize.height
            self.view.layoutIfNeeded()
        }
    }
    
    func keyboardHide(notification: NSNotification) {
        
        DispatchQueue.main.async(execute: {
            
            var yOffset:CGFloat = 0
            if (self.chatTblView.contentSize.height > self.chatTblView.bounds.size.height) {
                yOffset = self.chatTblView.contentSize.height - self.chatTblView.bounds.size.height;
            }
            self.chatTblView.setContentOffset(CGPoint(x: 0.0, y: yOffset), animated: false)
        })
        
        self.bottomCons.constant = 0
    }
    
    
    @IBAction func backBtnTap(sender: UIButton) {
        self.view.endEditing(true)
        
        if self.openFromChat == OpenFromChat.ChatList {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
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
    
    @IBAction func galleryBtnTap(sender: UIButton) {
        self.view.endEditing(true)
        picker  = UIImagePickerController()
        self.picker.view.backgroundColor = UIColor.white
        let alert = UIAlertController(title: nil, message: "Choose Option:", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let galleryAction = UIAlertAction(title: "Gallery", style: UIAlertActionStyle.default, handler: { (action) in
            
            self.checkAndOpenLibrary(forTypes: ["\(kUTTypeImage)"])
            
        })
        
        let cameraAction = UIAlertAction(title: "Camera", style: UIAlertActionStyle.default, handler: { (action) in
            
            self.checkAndOpenCamera(forTypes: ["\(kUTTypeImage)"])
            
            
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (action) in
            
            self.dismiss(animated: true, completion: nil)
            
        }
        
        alert.addAction(galleryAction)
        alert.addAction(cameraAction)
        
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func cameraBtnTap(sender: UIButton) {
        self.view.endEditing(true)
        //        if self.cameraBtnState == CameraBtnState.Camera {
        //            self.checkAndOpenCamera(forTypes: ["\(kUTTypeImage)"])
        //        } else  {
        
        let myString = self.chatTextView.text
        let trimmedString = myString?.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines) ?? ""
        if !(trimmedString.isEmpty) {
        self.sendTextMsg(text: trimmedString)
        }
        self.chatTextView.text = ""
        // self.cameraBtnState = .Camera
        // self.cameraBtn.setTitle("", for:  .normal)
        // self.cameraBtn.setImage(UIImage(named: "comment_capture"), for:  .normal)
        //self.chatTblView.reloadData()
        
        //        }
    }
    
    private func sendTextMsg(text: String) {
        
        var fromUser = [String: AnyObject]()
        fromUser["id"]        = CurrentUser.userId as AnyObject
        fromUser["name"]      = CurrentUser.name as AnyObject
        fromUser["avatarID"]  = CurrentUser.avatarID as AnyObject
        fromUser["tagLine"]   = CurrentUser.tagLine as AnyObject
        fromUser["country"]   = CurrentUser.country as AnyObject
        fromUser["admin"]     = CurrentUser.isAdmin as AnyObject
        fromUser["avatarURL"] = CurrentUser.avatarExtURL as AnyObject
        
        var toUser = [String: AnyObject]()
        if let userDetail = self.toUserDetail["user"] as? [String: AnyObject] {
            
            if let id = userDetail["id"] {
                toUser["id"]    = id
            }
            
            if let name = userDetail["name"] as? String {
                toUser["name"]  = name as AnyObject
            }
            
            if let avatarID = userDetail["avatarID"] {
                toUser["avatarID"]  = avatarID as AnyObject
            }
            
            if let tagLine = userDetail["tagLine"] {
                toUser["tagLine"]  = tagLine as AnyObject
            }
            
            if let country = userDetail["country"] as? String {
                toUser["country"]   = country as AnyObject
            }
            
            if let admin = userDetail["admin"] as? Bool {
                toUser["admin"]   = admin as AnyObject
            }
        }
        
        if let meta = self.toUserDetail["meta"] as? [String: AnyObject] {
            
            if let url = meta["avatarURL"] as? String {
                
                toUser["avatarURL"] = url as AnyObject
                
            }
        }
        
        let postTime = NSDate()
        let dateFormat = DateFormatter()
        dateFormat.timeZone = TimeZone(identifier: "UTC")
        dateFormat.dateFormat =  "yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"
        
        let chatId = Globals.getUniqueIdentifier() + "_TempId"
        
        var chatParam = [String: AnyObject]()
        chatParam["content"]    = "\(text)" as AnyObject
        chatParam["imageIDs"]     = [] as AnyObject
        chatParam["fromUser"]   = fromUser as AnyObject
        chatParam["toUser"]     = toUser as AnyObject
        chatParam["postTime"]   = dateFormat.string(from: postTime as Date) as AnyObject
        chatParam["id"]         = chatId as AnyObject
        
        print_debug(object: chatParam)
        
        self.chatArrayList.insert(chatParam as AnyObject, at: 0)
        
        if self.getNumberOfSection() == 0 {
            self.chatTblView.isHidden = true
            self.activityIndicator.isHidden = true
            self.noChatLbl.isHidden = false
        } else {
            self.chatTblView.isHidden = false
            self.activityIndicator.isHidden = true
            self.noChatLbl.isHidden = true
        }
        /*
         self.chatTblView.beginUpdates()
         self.chatTblView.insertSections(NSIndexSet(index: self.getNumberOfSection()-1), with: .None)
         self.chatTblView.insertRowsAtIndexPaths([IndexPath(row: 0, inSection: self.getNumberOfSection()-1)], with: .None)
         self.chatTblView.endUpdates()*/
        self.chatTblView.reloadData()
        self.moveChatToBottom()
        self.sendChatMsg(param: chatParam, chatId: chatId)
        
        
    }
    
    func chatImageViewTapped(img: UIGestureRecognizer) {
        
        guard let indexPath = img.view!.tableViewIndexPath(tableView: self.chatTblView) else {
            return
        }
        guard let val = self.chatArrayList[(self.getNumberOfSection()-1)-indexPath.section] as? [String: AnyObject] else { return  }
        
        guard let content = val["content"] as? String else {
            print_debug(object: "Content not found in cellforRowAtIndex.")
            return
        }
        
        
        guard let toUser = val["toUser"] as? [String:AnyObject] else {
            print_debug(object: "toUser not found in cellforRowAtIndex.")
            return
        }
        
        guard let _ = toUser["id"] as? String else {
            print_debug(object: "toUser id not found in cellforRowAtIndex.")
            return
        }
        
        guard let images = val["images"] as? [AnyObject], images.count > 0 else {
            print_debug(object: "images not found in FromUserImgCell.")
            return
        }
        
        guard let url = images[indexPath.row]["url"] as? String else {
            print_debug(object: "url not found in FromUserImgCell.")
            return
        }
        
        
        
        if content.isEmpty {
            //Return FromImageCell
            
            
            if url.isEmpty {
                guard let tempImg = images[indexPath.row]["tempImg"] as? UIImage else {
                    print_debug(object: "tempImg not found...")
                    
                    return
                }
                print_debug(object: "url is empty in FromUserImgCell.")
                let photo = SKPhoto.photoWithImage(tempImg)
                //photo.shouldCachePhotoURLImage = true
                photo.photoURL = ""
                let browser = SKPhotoBrowser(photos: [photo])
                browser.delegate = self
                self.present(browser, animated: true, completion: {
                    
                    APP_DELEGATE.setStatusBarHidden(true, with: .slide)
                })
            } else {
                
                let photo = SKPhoto.photoWithImageURL(url)
                photo.shouldCachePhotoURLImage = true
                
                let browser = SKPhotoBrowser(photos: [photo])
                browser.delegate = self
                let vc = UINavigationController()
                vc.navigationBar.isHidden = true
                self.present(browser, animated: true, completion: {
                    
                    APP_DELEGATE.setStatusBarHidden(true, with: .slide)
                })
            }
        }
    }
    
    
    @IBAction func reportBtnTap(_ sender: Any) {
        
        guard let userDetail = self.toUserDetail["user"] as? [String: AnyObject] else {
            return
        }
        
        guard let id = userDetail["id"] as? String else { return }
        
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
                
                self.blockUser(userId: id, block: true)

                
//                let optionMenu = UIAlertController(title: CommonTexts.blockThisUserSure, message: nil, preferredStyle: .alert)
//
//                let yesAction = UIAlertAction(title: "Yes", style: .default, handler: {
//
//                    (alert: UIAlertAction!) -> Void in
//
//                    self.blockUser(userId: id, block: true)
//
//
//                    //self.reportUser(userId: uID)
//                })
                
//                let noAction = UIAlertAction(title: "No", style: .destructive, handler: {
//                    
//                    (alert: UIAlertAction!) -> Void in
//                    
//                    
//                })
//                optionMenu.addAction(yesAction)
//                optionMenu.addAction(noAction)
//                
//                self.present(optionMenu, animated: true, completion: nil)
                
                
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
extension UserChatVC : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        print_debug(object: self.getNumberOfSection())
        return self.getNumberOfSection()
        //return self.chatArrayList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let val = self.chatArrayList[(self.getNumberOfSection()-1)-section] as? [String: AnyObject] else {
            print_debug(object: "val not parse in section")
            return 0}
        
        print_debug(object: val)
        return self.getNumberOfRowInSection(val: val)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        guard let val = self.chatArrayList[(self.getNumberOfSection()-1)-indexPath.section] as? [String: AnyObject] else { return UITableViewCell() }
        
        guard let content = val["content"] as? String else {
            print_debug(object: "Content not found in cellforRowAtIndex.")
            return UITableViewCell()
        }
        
        guard let fromUser = val["fromUser"] as? [String:AnyObject] else {
            print_debug(object: "fromUser not found in cellforRowAtIndex.")
            return UITableViewCell()
        }
        
        guard let fromUserID = fromUser["id"] as? String else {
            print_debug(object: "fromUser id not found in cellforRowAtIndex.")
            return UITableViewCell()
        }
        
        guard let toUser = val["toUser"] as? [String:AnyObject] else {
            print_debug(object: "toUser not found in cellforRowAtIndex.")
            return UITableViewCell()
        }
        
        guard let _ = toUser["id"] as? String else {
            print_debug(object: "toUser id not found in cellforRowAtIndex.")
            return UITableViewCell()
        }
        
        
        
        if fromUserID == CurrentUser.userId {
            
            if !content.isEmpty {
                //Return FromTextCell
                return self.fromUserTextCellSetup(tableView: tableView, indexPath: indexPath, val: val)
            } else {
                //Return FromImageCell
                return self.fromUserImgCellSetup(tableView: tableView, indexPath: indexPath, val: val)
            }
            
        } else {
            
            if !content.isEmpty {
                //Return ToTextCell
                return self.toUserTextCellSetup(tableView: tableView, indexPath: indexPath, val: val)
            } else {
                //Return ToImageCell
                return self.toUserImgCellSetup(tableView: tableView, indexPath: indexPath, val: val)
            }
            
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.view.endEditing(true)
    }
    
    
    private func fromUserTextCellSetup(tableView: UITableView, indexPath: IndexPath, val: [String : AnyObject])-> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FromUserTextCell", for:  indexPath) as! FromUserTextCell
        
        guard let _ = val["toUser"] as? [String:AnyObject] else {
            print_debug(object: "toUser not found in cellforRowAtIndex.")
            return UITableViewCell()
        }
        
        guard let content = val["content"] as? String else {
            print_debug(object: "Content not found in cellforRowAtIndex.")
            return UITableViewCell()
        }
        
        guard let postTime = val["postTime"] as? String else {
            print_debug(object: "postTime not found in cellforRowAtIndex.")
            return UITableViewCell()
        }
        
        cell.msgTextLbl.text = content
        if postTime.isEmpty {
            cell.timeLbl.text = "just now"
        } else {
            cell.timeLbl.text = self.getCalculatedTime(postTime: postTime)
        }
        
        
        //let edgeInset = UIEdgeInsets(top: 55, left: 28, bottom: 28, right: 55)
        //        let edgeInset = UIEdgeInsets(top: 20, left: 15, bottom: 20, right: 20)
        //        cell.bgImageView.image = UIImage(named: "chat_bubble_2")?.resizableImageWithCapInsets(edgeInset)
        return cell
    }
    
    private func fromUserImgCellSetup(tableView: UITableView, indexPath: IndexPath, val: [String : AnyObject])-> UITableViewCell {
        
        
        print_debug(object: val)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FromUserImgCell", for:  indexPath) as! FromUserImgCell
        
        // nitin
        //let edgeInset = UIEdgeInsets(top: 30, left: 30, bottom: 30, right: 30)
        cell.bgImageView.image = UIImage(named: "chat_bubble_2")
        cell.bgImageView.image = nil
        
        if let id = val["id"] as? String, id == "-1" || id == "" {
            cell.spinner.startAnimating()
            cell.spinner.isHidden = false
        } else {
            cell.spinner.stopAnimating()
            cell.spinner.isHidden = true
        }
        
        print_debug(object: "From user image...")
        
        print_debug(object: val)
        
        guard let images = val["images"] as? [AnyObject] else {
            print_debug(object: "images not found in FromUserImgCell.")
            return UITableViewCell()
        }
        
        guard let postTime = val["postTime"] as? String else {
            print_debug(object: "postTime not found in FromUserImgCell.")
            return UITableViewCell()
        }
        
        if postTime.isEmpty {
            cell.timeLbl.text = "just now"
        } else {
            cell.timeLbl.text = self.getCalculatedTime(postTime: postTime)
        }
        
        let chatImageTap = UITapGestureRecognizer(target:self, action:#selector(self.chatImageViewTapped(img:)))
        cell.postImageView.isUserInteractionEnabled = true
        cell.postImageView.addGestureRecognizer(chatImageTap)
        
        guard let url = images[indexPath.row]["url"] as? String else {
            print_debug(object: "url not found in FromUserImgCell.")
            return UITableViewCell()
        }
        
        cell.postImageView.image = CONTAINERPLACEHOLDER
        cell.postImageView.contentMode = .center
        
        if url.isEmpty {
            guard let tempImg = images[indexPath.row]["tempImg"] as? UIImage else {
                print_debug(object: "tempImg not found...")
                cell.postImageView.image = AppIconPLACEHOLDER
                cell.postImageView.image = CONTAINERPLACEHOLDER
                cell.postImageView.contentMode = .center
                return cell
            }
            print_debug(object: "url is empty in FromUserImgCell.")
            cell.postImageView.image = tempImg
            cell.postImageView.contentMode = .scaleToFill
        } else {
            
           // cell.postImageView.sd_setImage(with: URL(string: url), placeholderImage: AppIconPLACEHOLDER)
            SDWebImageManager.shared().imageDownloader?.downloadImage(with: URL(string: url), options: [], progress: nil, completed: { (image, data, error, succes) in
                
                
                    //On Main Thread
                    //DispatchQueue.main.async(){
                        if let newimage = image {
                            cell.postImageView.image = newimage
                            cell.postImageView.contentMode = .scaleToFill
                        } else {
                            cell.postImageView.image = CONTAINERPLACEHOLDER
                            cell.postImageView.contentMode = .center
                        }
                    //}
            })
        }
        
        print_debug(object: "url Found : \(url)")
        return cell
    }
    
    private func toUserTextCellSetup(tableView: UITableView, indexPath: IndexPath, val: [String : AnyObject])-> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToUserTextCell", for:  indexPath) as! ToUserTextCell
        
        //let edgeInset = UIEdgeInsets(top: 55, left: 55, bottom: 28, right: 28)
        //        let edgeInset = UIEdgeInsets(top: 15, left: 25, bottom: 20, right: 15)
        cell.bgImageView.image = UIImage(named: "chat_bubble_1") // nitin
        
        guard let content = val["content"] as? String else {
            print_debug(object: "Content not found in cellforRowAtIndex.")
            return UITableViewCell()
        }
        
        guard let postTime = val["postTime"] as? String else {
            print_debug(object: "postTime not found in cellforRowAtIndex.")
            return UITableViewCell()
        }
        
        guard let userDetail = self.toUserDetail["user"] as? [String: AnyObject] else {
            print_debug(object: "self.toUserDetail[\"user\"] Not found.")
            return UITableViewCell()
        }
        
        var tempAvatarExtURL = ""
        if let avatarExtURL = userDetail["avatarExtURL"] as? String {
            tempAvatarExtURL = avatarExtURL
        } else {
            if let avatarURLLarge = userDetail["avatarURLLarge"] as? String {
                tempAvatarExtURL = avatarURLLarge
            }
        }
        
        if let url = URL(string: tempAvatarExtURL) {
            cell.userImageView.sd_setImage(with: url, placeholderImage: PROFILEPLACEHOLDER)
        } else {
            cell.userImageView.image = PROFILEPLACEHOLDER
        }
        
        cell.msgTextLbl.text = content
        
        if postTime.isEmpty {
            cell.timeLbl.text = "just now"
        } else {
            cell.timeLbl.text = self.getCalculatedTime(postTime: postTime)
        }
        
        return cell
    }
    
    private func toUserImgCellSetup(tableView: UITableView, indexPath: IndexPath, val: [String : AnyObject])-> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToUserImgCell", for:  indexPath) as! ToUserImgCell
        
        cell.bgImageView.image = nil
        guard let images = val["images"] as? [AnyObject] else {
            print_debug(object: "Content not found in cellforRowAtIndex.")
            return UITableViewCell()
        }
        
        guard let url = images[indexPath.row]["url"] as? String else {
            print_debug(object: "Content not found in cellforRowAtIndex.")
            return UITableViewCell()
        }
        
        guard let userDetail = self.toUserDetail["user"] as? [String: AnyObject] else {
            print_debug(object: "self.toUserDetail[\"user\"] Not found.")
            return UITableViewCell()
        }
        
        //        guard let avatarExtURL = userDetail["avatarExtURL"] as? String else {
        //            print_debug(object: "avatarExtURL Not found.")
        //            return UITableViewCell() }
        
        var tempAvatarExtURL = ""
        if let avatarExtURL = userDetail["avatarExtURL"] as? String {
            tempAvatarExtURL = avatarExtURL
        } else {
            if let avatarURLLarge = userDetail["avatarURLLarge"] as? String {
                tempAvatarExtURL = avatarURLLarge
            }
        }
        
        if let url = URL(string: tempAvatarExtURL) {
            cell.userImageView.sd_setImage(with: url, placeholderImage: PROFILEPLACEHOLDER)
        } else {
            cell.userImageView.image = PROFILEPLACEHOLDER
        }
        
        let chatImageTap = UITapGestureRecognizer(target:self, action:#selector(self.chatImageViewTapped(img:)))
        cell.postImageView.isUserInteractionEnabled = true
        cell.postImageView.addGestureRecognizer(chatImageTap)
        cell
            .postImageView.image = CONTAINERPLACEHOLDER
        cell.postImageView.contentMode = .center
        if url.isEmpty {
            cell
                .postImageView.image = CONTAINERPLACEHOLDER
            cell.postImageView.contentMode = .center
        } else {
            
            //cell.postImageView.sd_setImage(with: URL(string: url), placeholderImage: AppIconPLACEHOLDER)
            
            SDWebImageManager.shared().imageDownloader?.downloadImage(with: URL(string: url), options: [], progress: nil, completed: { (image, data, error, succes) in
                
                
                    //On Main Thread
                    //DispatchQueue.main.async(){
                        if let newimage = image {
                            cell.postImageView.image = newimage
                            cell.postImageView.contentMode = .scaleToFill
                        } else {
                            cell.postImageView.image = CONTAINERPLACEHOLDER
                            cell.postImageView.contentMode = .center
                        }
                    //}
                
            })

        }
        //print_debug(object: "url Found : \(url)")
        
        guard let postTime = val["postTime"] as? String else {
            print_debug(object: "postTime not found in cellforRowAtIndex.")
            return UITableViewCell()
        }
        
        if postTime.isEmpty {
            cell.timeLbl.text = "just now"
        } else {
            cell.timeLbl.text = self.getCalculatedTime(postTime: postTime)
        }
        
        return cell
    }
    
    func getNumberOfSection()-> Int {
        
        var count = 0
        for temp in self.chatArrayList {
            
            if let val = temp as? [String: AnyObject] {
                
                
                if let content = val["content"] as? String {
                    
                    print_debug(object: content)
                    
                    if !content.isEmpty {
                        
                        count = count + 1
                    }
                }
                
                if let imgArr =  val["images"] as? [AnyObject] {
                    
                    for tem in imgArr {
                        if let url = tem["url"] as? String {
                            if !url.isEmpty {
                                count = count + 1
                            } else {
                                count = count + 1
                            }
                        }
                    }
                }
            }
            
        }
        return count
        
    }
    
    func getNumberOfRowInSection(val: [String: AnyObject])-> Int {
        
        var count = 0
        
        if let content = val["content"] as? String {
            
            if !content.isEmpty {
                count = count + 1
            }
            
        } else { print_debug(object: "content not parse in section") }
        
        
        if let imgArr =  val["images"] as? [AnyObject] {
            
            if imgArr.count != 0 {
                for tem in imgArr {
                    guard let url = tem["url"] as? String else {
                        print_debug(object: "url not parse in section")
                        return 0 }
                    if !url.isEmpty {
                        count = count + 1
                    } else {
                        count = count + 1
                    }
                }
            }
            
        } else { print_debug(object: "image not parse in section") }
        
        print_debug(object: count)
        return count
        
    }
    
    private func getCalculatedTime(postTime: String)-> String {
        
        let dateFormat = DateFormatter()
        dateFormat.timeZone = TimeZone(identifier: "UTC")
        dateFormat.dateFormat =  "yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"
        
        let preConvertedDate = dateFormat.date(from: postTime)
        dateFormat.dateFormat = "dd/MM/yyyy hh:mm a"
        dateFormat.timeZone = TimeZone.current
        dateFormat.locale = NSLocale.current
        let convertedDateString = dateFormat.string(from: preConvertedDate!)
        let convertedDate = dateFormat.date(from: convertedDateString)
        let days = CommonFunctions.calculateDateTime(dateToCompare: convertedDate! as NSDate)
        
        if days.contains("s") {
            return "just now"
        } else {
            return days + " ago"
        }
    }
    
}

extension UITableView {
    func scrollToBottom(animated: Bool = true) {
        let sections = self.numberOfSections
        if sections > 0 {
            let rows = self.numberOfRows(inSection: sections - 1)
            if rows > 0{
                self.scrollToRow(at: IndexPath(row: rows - 1, section: sections - 1), at: .bottom, animated: true)
            }
        }
    }
}


//MARK:- UITextViewDelegate
//MARK:-
extension UserChatVC: UITextViewDelegate {
    
    //MARK:- UITextView Delgate
    //MARK:-
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.moveChatToBottom()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        let myString = textView.text
        let trimmedString = myString?.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        
        print_debug(object: trimmedString)
        //        if !(trimmedString?.isEmpty)! {
        self.cameraBtnState = .Send
        self.cameraBtn.setImage(UIImage(), for: .normal)
        self.cameraBtn.setTitle("SEND", for: .normal)
        //        } else {
        //            self.cameraBtnState = .Camera
        //            self.cameraBtn.setTitle("", for: .normal)
        //            self.cameraBtn.setImage(UIImage(named: "comment_capture"), for: .normal)
        //        }
        
        
        
    }
    
    func moveChatToBottom() {
        if self.getNumberOfSection() > 0 {
            let ind = IndexPath(row: 0, section: self.getNumberOfSection()-1)
            self.chatTblView.scrollToRow(at: ind, at: .bottom, animated: true)
        }
    }
    
}

//MARK:- WebService
//MARK:-
extension UserChatVC {
    
    
    func getChatList(toUserId: String, postTime: String, isBottomScroll: Bool, from: Int, isLatest: Bool) {
        
        var param = [String:AnyObject]()
        param["postTime"]   = postTime as AnyObject
        param["previous"]   = false as AnyObject
        param["users"]      =  "\(CurrentUser.userId ?? ""), \(toUserId)" as AnyObject //"79775e3f37e545f0, 56025c1d58fe473f"
        param["from"]       = from as AnyObject
        
        if isLatest {
            param["size"]       = 10 as AnyObject
        } else {
            param["size"]       = self.size as AnyObject
        }
        
        print_debug(object: param)
        
        WebServiceController.getUserChat(url: WS_UserChatMsg, parameters: param) { (sucess, errorMessage, data) in
            
            if sucess {
                print(data ?? "")
                guard let chatData = data else {
                    return
                }
                
                if chatData.count != 0 {
                    
                    if !isLatest {
                        self.from = self.getNumberOfSection() + 1
                        self.chatTblView.isHidden = false
                        for obj in chatData {
                            var newChatExist = false
                            for oldChat in self.chatArrayList {
                                if let oldChatId = oldChat["id"] as? String, let newChatId = obj["id"] as? String, oldChatId ==  newChatId {
                                    newChatExist = true
                                    break
                                }
                                
                            }
                            if newChatExist ==  false {
                                self.chatArrayList.append(contentsOf: [obj])
                            }
                        }
                        //self.chatArrayList.append(contentsOf: chatData)
                        self.chatTblView.reloadData()
                        if isBottomScroll {
                            self.moveChatToBottom()
                        }
                    } else {
                        
                        print_debug(object: chatData)
                        
                        for temp in chatData {
                            
                            guard let fromUser = temp["fromUser"] as? [String:AnyObject] else {
                                return
                            }
                            
                            guard let fromUserID = fromUser["id"] as? String else {
                                return
                            }
                            
                            if fromUserID != CurrentUser.userId {
                                self.chatArrayList.insert(temp, at: 0)
                            }
                            
                        }
                        //self.moveChatToBottom()
                        
                        if self.chatTblView.numberOfSections-1 ==  self.chatTblView.indexPathsForVisibleRows?.last?.section {
                            DispatchQueue.main.async(execute: {
                                self.chatTblView.scrollToBottom(animated: true)
                            })
                        }
                        self.chatTblView.reloadData()
                        
                    }
                    
                } else {
                    
                    
                    if self.getNumberOfSection() == 0 {
                        self.chatTblView.isHidden = true
                        self.activityIndicator.isHidden = true
                        self.noChatLbl.isHidden = false
                    } else {
//                        self.chatTblView.reloadData()
                        self.chatTblView.isHidden = false
                        self.activityIndicator.isHidden = true
                        self.noChatLbl.isHidden = true
                    }
                    
                }
                
                
                
            } else {
                //CommonFunctions.showAlertWarning("Data not found.")
            }
        }
    }
    
    func sendChatMsg(param: [String: AnyObject], chatId : String) {
        
        print_debug(object: param)
        
        WebServiceController.sendPersonalMsg(parameters: param) { (sucess, DataHeaderResponse, DataResultResponse) in
            print("header response")
            print(DataHeaderResponse)
            print("result response")
            print(DataResultResponse)

            if sucess {
                
                guard let heaerResponse = DataHeaderResponse else { return }
                guard let dateString = heaerResponse["Date"] as? String else { return }
                
                guard let dataResponse = DataResultResponse else { return }
                guard let chatID = dataResponse["id"] as? String else { return }
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz"
                let date = dateFormatter.date(from: dateString) ////Optional(2017-06-06 08:37:14 +0000)
                
                dateFormatter.timeZone = TimeZone(identifier: "UTC")
                dateFormatter.dateFormat =  "yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"
                let sendData    =  dateFormatter.string(from: date!) //2017-06-06T08:38:54Z
                
                var tempParam = [String: AnyObject]()
                for (index, element) in self.chatArrayList.enumerated().reversed() {
                    
                    print_debug(object: element)
                    if let temp = element as? [String: AnyObject] {
                        
                        if (temp["id"] as? String ?? "") == chatId {
                            
                            tempParam = (temp as AnyObject) as! [String : AnyObject]
                            tempParam["postTime"]   = sendData as AnyObject
                            tempParam["id"]         = chatID as AnyObject
                            
                            self.chatArrayList[index] = tempParam as AnyObject
                            break
                        }
                        
                    }
                    
                }
                
                // self.moveChatToBottom()
            } else {
                
                var oldChatIndex = 0
                for oldChat in self.chatArrayList {
                    if let oldChatId = oldChat["id"] as? String, oldChatId ==  chatId {
                        self.chatArrayList.remove(at: oldChatIndex)
                        break
                    }
                    oldChatIndex += 1
                    
                }
                self.chatTblView.reloadData()
            }
            
        }
    }
    
    
    
    
    /* func getLatestChat(toUserId: String, postTime: String, from: Int) {
     
     var param = [String:AnyObject]()
     param["postTime"]   = postTime
     param["previous"]   = false
     param["users"]      =  "\(CurrentUser.userId ?? ""), \(toUserId)" //"79775e3f37e545f0, 56025c1d58fe473f"
     param["from"]       = from
     param["size"]       = 1
     
     
     print_debug(object: param)
     
     WebServiceController.getUserChat(WS_UserChatMsg, parameters: param) { (sucess, errorMessage, data) in
     
     if sucess {
     print(data)
     guard let chatData = data else {
     return
     }
     
     print_debug(object: chatData)
     print_debug(object: self.chatArrayList.count)
     print_debug(object: self.chatArrayList)
     
     if chatData.count != 0 {
     
     self.chatTblView.isHidden = false
     
     
     for temp in chatData {
     
     if let chatId = temp["id"] as? String {
     
     if self.chatArrayList.isEmpty {
     self.chatArrayList.insert(temp ?? "", atIndex: 0)
     } else {
     if let currentChatId = self.chatArrayList.first?["id"] as? String {
     print_debug(object: chatId)
     print_debug(object: currentChatId)
     if chatId != currentChatId {
     self.chatArrayList.insert(temp ?? "", atIndex: 0)
     }
     }
     }
     }
     
     }
     
     self.chatTblView.reloadData()
     }
     } else {
     //CommonFunctions.showAlertWarning("Data not found.")
     }
     }
     } */
    
    
    func uploadChatPic(tempImg: UIImage, fromUser: [String: AnyObject], toUser: [String: AnyObject], postTime: String, chatId : String) {
        
        guard CurrentUser.userId != nil else { return }
        
        let url = WS_UploadImage + "?userAvatar=false&seedImgID=&channelChat=false&userChat=true"
        
        var image = tempImg
        if let data = UIImageJPEGRepresentation(tempImg, 0.6) {
            image = UIImage(data: data)!
        }
        
        WebServiceController.uploadUserImage(url: url, parameters: [String : AnyObject](), img: image) { (sucess, DataHeaderResponse, DataResultResponse) in
            
            if let jsonDict = DataHeaderResponse {
                if let statusCode = jsonDict["status"]?.int64Value {
                    if statusCode == 403 {
                        CommonFunctions.showAlertWarning(msg: CommonTexts.ImageUploadFail)
                    }
                }
            }
            
            if sucess {
                guard let responseDic = DataResultResponse else { return }
                
                
                
                print_debug(object: responseDic)
                
                guard let id = responseDic["id"] as? String else { return }
                
                print_debug(object: responseDic)
                print_debug(object: id)
                let array : [String] = [id]
                if !id.isEmpty {
                    
                    var chatParam = [String: AnyObject]()
                    chatParam["content"]    = "" as AnyObject
                    chatParam["imageIDs"]   = array as AnyObject
                    chatParam["fromUser"]   = fromUser as AnyObject
                    chatParam["toUser"]     = toUser as AnyObject
                    chatParam["postTime"]   = postTime as AnyObject //dateFormat.string(from: postTime)
                    chatParam["id"]         = chatId as AnyObject
                    
                    print_debug(object: chatParam)
                    
                    self.sendChatMsg(param: chatParam, chatId: chatId)
                } else {
                    var oldChatIndex = 0
                    for oldChat in self.chatArrayList {
                        if let oldChatId = oldChat["id"] as? String, oldChatId ==  chatId {
                            self.chatArrayList.remove(at: oldChatIndex)
                            break
                        }
                        oldChatIndex += 1
                        
                    }
                    self.chatTblView.reloadData()
                }
                
                
            } else {
                var oldChatIndex = 0
                for oldChat in self.chatArrayList {
                    if let oldChatId = oldChat["id"] as? String, oldChatId ==  chatId {
                        self.chatArrayList.remove(at: oldChatIndex)
                        break
                    }
                    oldChatIndex += 1
                    
                }
                self.chatTblView.reloadData()
            }
            
            
        }
        
    }
    
    func sendTemImgMsg(sendImg: UIImage) {
        
        var fromUser = [String: AnyObject]()
        fromUser["id"]        = CurrentUser.userId as AnyObject
        fromUser["name"]      = CurrentUser.name as AnyObject
        fromUser["avatarID"]  = CurrentUser.avatarID as AnyObject
        fromUser["tagLine"]   = CurrentUser.tagLine as AnyObject
        fromUser["country"]   = CurrentUser.country as AnyObject
        fromUser["admin"]     = CurrentUser.isAdmin as AnyObject
        fromUser["avatarURL"] = CurrentUser.avatarExtURL as AnyObject
        var toUser = [String: AnyObject]()
        
        if let userDetail = self.toUserDetail["user"] as? [String: AnyObject] {
            
            if let id = userDetail["id"] {
                toUser["id"]    = id as AnyObject
            }
            
            if let name = userDetail["name"] as? String {
                toUser["name"]  = name as AnyObject
            }
            
            if let avatarID = userDetail["avatarID"] {
                toUser["avatarID"]  = avatarID as AnyObject
            }
            
            if let tagLine = userDetail["tagLine"] {
                toUser["tagLine"]  = tagLine as AnyObject
            }
            
            if let country = userDetail["country"] as? String {
                toUser["country"]   = country as AnyObject
            }
            
            if let admin = userDetail["admin"] as? Bool {
                toUser["admin"]   = admin as AnyObject
            }
        }
        
        if let meta = self.toUserDetail["meta"] as? [String: AnyObject] {
            
            if let url = meta["avatarURL"] as? String {
                
                toUser["avatarURL"] = url as AnyObject
                
            }
        }
        
        var tempimgObject           = [String: AnyObject]()
        tempimgObject["id"]         = "" as AnyObject
        tempimgObject["url"]        = "" as AnyObject
        tempimgObject["thumbURL"]   = "" as AnyObject
        tempimgObject["tempImg"]    = sendImg as AnyObject
        
        let postTime = NSDate()
        let dateFormat = DateFormatter()
        dateFormat.timeZone = TimeZone(identifier: "UTC")
        dateFormat.dateFormat =  "yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"
        
        let chatId = Globals.getUniqueIdentifier() + "_TempId"
        
        var chatParam = [String: AnyObject]()
        chatParam["content"]    = "" as AnyObject
        chatParam["images"]     = [tempimgObject] as AnyObject
        chatParam["fromUser"]   = fromUser as AnyObject
        chatParam["toUser"]     = toUser as AnyObject
        chatParam["postTime"]   = dateFormat.string(from: postTime as Date) as AnyObject
        chatParam["id"]         = chatId as AnyObject
        
        
        print_debug(object: chatParam)
        
        self.chatArrayList.insert(chatParam as AnyObject, at: 0)
        
        self.chatTblView.beginUpdates()
        self.chatTblView.insertSections(NSIndexSet(index: self.getNumberOfSection()-1) as IndexSet, with: .none)
        self.chatTblView.insertRows(at: [IndexPath(row: 0, section: self.getNumberOfSection()-1)], with: .none)
        self.chatTblView.endUpdates()
        self.moveChatToBottom()
        if self.getNumberOfSection() == 0 {
            self.chatTblView.isHidden = true
            self.activityIndicator.isHidden = true
            self.noChatLbl.isHidden = false
        } else {
            self.chatTblView.reloadData()
            self.chatTblView.isHidden = false
            self.activityIndicator.isHidden = true
            self.noChatLbl.isHidden = true
        }
        print_debug(object: chatParam)
        
        self.uploadChatPic(tempImg: sendImg, fromUser: fromUser, toUser: toUser, postTime: dateFormat.string(from: postTime as Date), chatId: chatId)
        
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
                self.chatArrayList.removeAll()
                self.from = 0
                self.size = 80 // nitin
                self.chatTblView.reloadData()
                guard let userDetail = self.toUserDetail["user"] as? [String: AnyObject] else {
                    return
                }
                
                if let id = userDetail["id"] as? String {
                    ///self.getChatList(id, postTime: "", isBottomScroll: true)
                    self.getChatList(toUserId: id, postTime: "", isBottomScroll: true, from: self.from, isLatest: false)
                    
                }
            } else {
                //CommonFunctions.showAlertWarning(msg: "Detail is not update.")
            }
            
        }
        
    }
    
}

//MARK:- UIImagePickerController & UINavigationController Delegate
//MARK:-
extension UserChatVC :  UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    func checkAndOpenLibrary(forTypes: [String]) {
        
        self.picker.delegate = self
        
        //self.picker.mediaTypes = forTypes
        
        
        let status: PHAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        
        if (status == .notDetermined) {
            
            let sourceType: UIImagePickerControllerSourceType = UIImagePickerControllerSourceType.photoLibrary
            
            self.picker.sourceType = sourceType
            self.picker.allowsEditing = true
            navigationController!.present(self.picker, animated: true, completion: nil)
            
        }
            
        else {
            if status == .restricted {
                let alert = UIAlertController(title: "Error", message: CommonTexts.LIBRARY_RESTRICTED_ALERT_TEXT, preferredStyle: UIAlertControllerStyle.alert)
                let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (action) in
                    self.dismiss(animated: true, completion: nil)
                }
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
            }
            else {
                
                if status == .denied {
                    
                    
                    
                    let alert = UIAlertController(title: "Error", message: CommonTexts.LIBRARY_ALLOW_ALERT_TEXT, preferredStyle: UIAlertControllerStyle.alert)
                    
                    let settingsAction = UIAlertAction(title: "Settings", style: UIAlertActionStyle.default, handler: { (action) in
                        
                        UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
                        
                    })
                    
                    let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (action) in
                        
                        self.dismiss(animated: true, completion: nil)
                        
                    }
                    
                    
                    
                    alert.addAction(settingsAction)
                    
                    alert.addAction(cancelAction)
                    
                    self.present(alert, animated: true, completion: nil)
                    
                }
                    
                else {
                    
                    if status == .authorized {
                        
                        let sourceType: UIImagePickerControllerSourceType = UIImagePickerControllerSourceType.photoLibrary
                        
                        self.picker.sourceType = sourceType
                        
                        self.picker.allowsEditing = true
                        
                        self.navigationController!.present(self.picker, animated: true, completion: nil)
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
    
    
    func checkAndOpenCamera(forTypes: [String]) {
        
        
        
        self.picker.delegate = self
        
        
        
        let authStatus: AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        
        if authStatus == AVAuthorizationStatus.authorized {
            
            let sourceType: UIImagePickerControllerSourceType = UIImagePickerControllerSourceType.camera
            
            if UIImagePickerController.isSourceTypeAvailable(sourceType) {
                
                self.picker.sourceType = sourceType
                
                self.picker.mediaTypes = forTypes
                
                self.picker.allowsEditing = true
                
                if self.picker.sourceType == UIImagePickerControllerSourceType.camera {
                    
                    self.picker.showsCameraControls = true
                    
                }
                
                self.navigationController!.present(self.picker, animated: true, completion: nil)
                
            }
                
            else {
                
                DispatchQueue.main.async(execute: {
                    
                    //PKCommonClass.showTSMessageForError("Sorry! Camera not supported on this device")
                    
                })
                
            }
            
        }
            
        else {
            
            if authStatus == AVAuthorizationStatus.notDetermined {
                
                AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: {(granted: Bool) in                DispatchQueue.main.async(execute: {
                    
                    if granted {
                        
                        let sourceType: UIImagePickerControllerSourceType = UIImagePickerControllerSourceType.camera
                        
                        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
                            
                            self.picker.sourceType = sourceType
                            self.picker.allowsEditing = true
                            if self.picker.sourceType == UIImagePickerControllerSourceType.camera {
                                
                                self.picker.showsCameraControls = true
                                
                            }
                            
                            self.navigationController!.present(self.picker, animated: true, completion: nil)
                            
                        }
                            
                        else {
                            
                            DispatchQueue.main.async(execute: {
                                
                                //PKCommonClass.showTSMessageForError("Sorry! Camera not supported on this device")
                                
                            })
                            
                        }
                        
                    }
                    
                })
                    
                })
                
            }
                
            else {
                
                if authStatus == AVAuthorizationStatus.restricted {
                    
                    let alert = UIAlertController(title: "Error", message: CommonTexts.CAMERA_RESTRICTED_ALERT_TEXT, preferredStyle: UIAlertControllerStyle.alert)
                    
                    let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (action) in
                        
                        self.dismiss(animated: true, completion: nil)
                        
                    }
                    
                    alert.addAction(cancelAction)
                    
                    self.present(alert, animated: true, completion: nil)
                    
                }
                    
                else {
                    
                    let alert = UIAlertController(title: "Error", message: CommonTexts.CAMERA_ALLOW_ALERT_TEXT, preferredStyle: UIAlertControllerStyle.alert)
                    
                    
                    let settingsAction = UIAlertAction(title: "Settings", style: UIAlertActionStyle.default, handler: { (action) in
                        
                        UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
                        
                    })
                    
                    
                    
                    let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (action) in
                        
                        //self.dismiss(animated: true, completion: nil)
                        
                    }
                    
                    
                    
                    alert.addAction(settingsAction)
                    
                    alert.addAction(cancelAction)
                    
                    
                    
                    self.present(alert, animated: true, completion: nil)
                    
                }
                
            }
            
        }
        
    }
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        
        let mediaType = info[UIImagePickerControllerMediaType] as! NSString
        
        print_debug(object: info)
        
        if mediaType == kUTTypeImage {
            
            self.picker.dismiss(animated: true, completion: {
                
                
                if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
                    
                    self.sendTemImgMsg(sendImg: image)
                    //CommonFunctions.showAlertSucess("Sucess", msg: "Image selected sucessfully")
                }
                
            })
            
        } else {
            
            print_debug(object: "Data not found.")
            _ = CommonFunctions.showAlert(title: "Failed", message: CommonTexts.INVALID_LOGIN, btnLbl: "OK")
            
        }
        
        
    }
    
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        self.picker.dismiss(animated: true, completion: nil)
        
    }
    
    
    
}

// nitin
//MARK:- SKPhotoBrowserDelegate
//MARK:-
extension UserChatVC :  SKPhotoBrowserDelegate {
    
    func didDismissAtPageIndex(_ index: Int) {
        
        APP_DELEGATE.setStatusBarHidden(false, with: .slide)
        
    }
    
    
}
