//
//  CommentVC.swift
//  Fantasticoh!
//
//  Created by Appinventiv on 14/09/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import UIKit
import Accelerate
import Photos

enum CameraBtnState {
    case Camera, Send, None
}

protocol CommentVCDelegate {
    func updateReplyCounter(chatId : String, count: Int)
}

class CommentVC: UIViewController {
    
    //MARK:- IBOutlet & Propertie's
    //MARK:-
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var topSepratorView: UIView!
    @IBOutlet weak var bottomSepratorView: UIView!
    @IBOutlet weak var cameraBtn: UIButton!
    @IBOutlet weak var bottomCons: NSLayoutConstraint!
    @IBOutlet weak var bottomContainerView: UIView!
    @IBOutlet weak var noChatLbl: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var picker : UIImagePickerController = UIImagePickerController()
    var commentTextArray = ["Ah, the Facebook photo link http://fantasticoh.com ",
                            "email at demo@appinventiv.com"]
    var chatArray = [[String: AnyObject]]()
    var channelId: String!
    var cameraBtnState = CameraBtnState.None
    var moveKeyboard = true
    var from = 0
    var size = 40 // nitin
    var refreshControl: UIRefreshControl!
    var timer: Timer!
    var updateSize = 0
    
    //MARK:- View Life Cycle
    //MARK:-
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tblView.delegate = self
        self.tblView.dataSource = self
        self.commentTextView.delegate = self
        self.commentTextView.autocorrectionType = .yes
        
        self.noChatLbl.isHidden = true
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
        self.tblView.isHidden = true
        
        self.initSetup()
        self.picker.view.backgroundColor = UIColor.white
        
        // nitin
        self.noChatLbl.text = CommonTexts.StartNewChatConversation
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(CommentVC.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CommentVC.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        self.timer = Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(CommentVC.update), userInfo: nil, repeats: true)
        
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.view.layoutIfNeeded()
    }
    
    func update() {
        self.updateChats()
        /*
         if self.chatArray.count > 0 {
         self.updateChats()
         }*/
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        if let tim = self.timer {
            tim.invalidate()
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK:- IBAction & Selector Method
    //MARK:-
    
    func initSetup() {
        
        self.tblView.estimatedRowHeight = 50.0
        self.tblView.rowHeight = UITableViewAutomaticDimension
        
        self.commentTextView.layer.cornerRadius = 5.0
        self.commentTextView.layer.masksToBounds = true
        
        self.commentTextView.layer.borderWidth = 0.5
        self.commentTextView.layer.borderColor = CommonColors.lightGrayColor().cgColor
        
        self.cameraBtnState = CameraBtnState.Camera
        
        let commentImgCell = UINib(nibName: "CommentImgCell", bundle: nil)
        self.tblView.register(commentImgCell, forCellReuseIdentifier: "CommentImgCell")
        
        let commentTxtCell = UINib(nibName: "CommentTxtCell", bundle: nil)
        self.tblView.register(commentTxtCell, forCellReuseIdentifier: "CommentTxtCell")
        
        self.getChannelChat(channelId: self.channelId, from: self.from, size: self.size)
        
        self.refreshControl = UIRefreshControl()
        self.tblView.addSubview(refreshControl)
        self.refreshControl.tintColor = CommonColors.globalRedColor()
        self.refreshControl.addTarget(self, action: #selector(CommentVC.refresh(sender:)), for: UIControlEvents.valueChanged)
        
        //self.moveChatToBottom()
        self.tblView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 40, right: 0)
        
    }
    func keyboardWillShow(notification: NSNotification) {
        
        // if self.moveKeyboard {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            
            
            print(SHARED_APP_DELEGATE.window?.rootViewController ?? "" )
            
            UIView.animate(withDuration: 0.3, animations: {
                
                print(keyboardSize.height)
                
                if IsShowTap {
                    
                    self.bottomCons.constant = (keyboardSize.height - 40)
                    print("Tap bar Hide")
                    
                } else {
                    self.bottomCons.constant = (keyboardSize.height - 2)
                    print("Tap bar show")
                }
                self.view.layoutIfNeeded()
//                self.bottomCons.constant = (keyboardSize.height-50)
            })
            
            //APP_DELEGATE.windows.first?.frame.origin.y = -(keyboardSize.height)
            //self.bottomCons.constant = (keyboardSize.height-50)
            
        }
        // }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        
        //if self.moveKeyboard {
        
        if let _ = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            
            //APP_DELEGATE.windows.first?.frame.origin.y = 0
            UIView.animate(withDuration: 0.3, animations: {
                self.bottomCons.constant =   0 //40
                self.view.layoutIfNeeded()
            })
            
        }
        
        //}
        
    }
    
    
    @IBAction func galleryBtnTap(sender: UIButton) {
        
        guard CommonFunctions.checkLogin() else {
            CommonFunctions.showLoginAlert(vc: self)
            return
        }
        
        //self.checkAndOpenLibrary(["\(kUTTypeImage)"])
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
        
        
        guard CommonFunctions.checkLogin() else {
            CommonFunctions.showLoginAlert(vc: self)
            return
        }
        
        if self.commentTextView.text != nil {
            /*if self.updateSize == 0 {
             return
             }*/
            
            let trimmedString = self.commentTextView.text?.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
            if trimmedString?.characters.count == 0 {
                self.commentTextView.text = ""
                return
            }
        }
        self.commentTextView.resignFirstResponder()
        let chatId = Globals.getUniqueIdentifier() + "_TempId"
        let jsonData: [String: AnyObject] = [
            "id": chatId as AnyObject,
            "parentID": "" as AnyObject,
            "creator": [
                "id": "\(CurrentUser.userId ?? "" )",
                "name": "\(CurrentUser.name ?? "" )",
                "tagLine": "",
                "country": "\(CurrentUser.country ?? "" )",
                "avatarID": "\(CurrentUser.avatarID ?? "" )",
                "avatarURL": "\(CurrentUser.avatarExtURL ?? "" )",
                "admin": "\(CurrentUser.isAdmin ?? false)"
                ] as AnyObject,
            "postTime": "" as AnyObject,
            "channels": [
                "\(self.channelId ?? "")"
                ] as AnyObject,
            "users": [
                "\(CurrentUser.userId ?? "")"
                ] as AnyObject,
            "content": "\(self.commentTextView.text ?? "")" as AnyObject,
            "images": [] as AnyObject,
            "countReplies": -1 as AnyObject,
            "countFlags": 0 as AnyObject,
            "countLikes": 0 as AnyObject
        ]
        self.chatArray.insert(contentsOf: [jsonData], at: 0)
        if self.chatArray.count == 0 {
            self.noChatLbl.isHidden = false
        } else {
            self.noChatLbl.isHidden = true
        }
        self.tblView.reloadData()
        self.moveChatToBottom()
        
        if let text = self.commentTextView.text {
            
            self.sendChat(msg: text, isImage: false, chatId: chatId)
        }
        
        self.commentTextView.text = ""
        
        /*
         if self.cameraBtnState == CameraBtnState.Camera {
         self.checkAndOpenCamera(["\(kUTTypeImage)"])
         } else  {
         //self.commentTextView.resignFirstResponder()
         
         self.commentTextView.text = ""
         self.cameraBtnState = .Camera
         self.cameraBtn.setTitle("", for:  .normal)
         self.cameraBtn.setImage(UIImage(named: "comment_capture"), for:  .normal)
         self.tblView.reloadData()
         self.moveChatToBottom()
         }*/
        
    }
    
    func moreBtnTap(sender: UIButton) {
        print_debug(object: "moreBtnTap")
    }
    
    func likeBtnTap(sender: UIButton) {
        
        guard CommonFunctions.checkLogin() else {
            CommonFunctions.showLoginAlert(vc: self)
            return
        }
        
        guard let indexPath = sender.tableViewIndexPath(tableView: self.tblView) else { return }
        
        /*
         guard let cell = sender.tableViewCell() as? CommentTxtCell else {
         return
         }*/
        
        let msgDic = self.chatArray[(self.chatArray.count-1)-indexPath.row]
        guard let msgId = msgDic["id"] as? String else { return }
        
        var tempMsgDic = msgDic
        
        
        
        
        guard let countLikes  = msgDic["countLikes"]?.integerValue else { return }
        
        
        if let userLiked  = msgDic["userLiked"] as? Bool, userLiked == true  {
            
            tempMsgDic["countLikes"] = countLikes - 1 as AnyObject
            
            
            tempMsgDic["userLiked"] = false as AnyObject
            self.unLikechat(messageId: msgId)
            
        } else {
            
            tempMsgDic["countLikes"] = countLikes + 1 as AnyObject
            
            tempMsgDic["userLiked"] = true as AnyObject
            self.likechat(messageId: msgId)
        }
        
        /*
         if cell.likeBtn.isSelected {
         //already like
         tempMsgDic["countLikes"] = like - 1
         } else {
         if like == 0 {
         tempMsgDic["countLikes"] = 1
         } else {
         tempMsgDic["countLikes"] = like + 1
         }
         }*/
        
        
        self.chatArray[(self.chatArray.count-1)-indexPath.row] = tempMsgDic
        
        
        self.tblView.reloadRows(at: [indexPath], with: .none)
//        if let cell = self.tblView.cellForRow(at: indexPath) as? CommentTxtCell {
//            if countLikes+1 <= 1 {
//                cell.showLikeLbl.text = "\(countLikes+1) like"
//            } else {
//                cell.showLikeLbl.text = "\(countLikes+1) likes"
//            }
//            cell.grayDotView.isHidden = false
//        } else if let cell = self.tblView.cellForRow(at: indexPath) as? CommentImgCell  {
//            if countLikes+1 <= 1 {
//                cell.showLikeLbl.text = "\(countLikes+1) like"
//            } else {
//                cell.showLikeLbl.text = "\(countLikes+1) likes"
//            }
//            cell.grayDotView.isHidden = false
//        }
        
        
        
        
        //self.tblView.beginUpdates()
        //self.tblView.endUpdates()
        
        
        //        let conOffset = self.tblView.contentOffset
        //        self.tblView.reloadRows(at: [IndexPath(row: indexPath.row, inSection: 0)], with: .None)
        //        self.tblView.beginUpdates()
        //        self.tblView.endUpdates()
        //        self.tblView.layer.removeAllAnimations()
        //
        //        self.tblView.setContentOffset(conOffset, animated: false)
        //self.likechat(messageId: msgId)
    }
    
    func replieBtnTap(sender: UIButton) {
        self.view.endEditing(true)
        guard CommonFunctions.checkLogin() else {
            CommonFunctions.showLoginAlert(vc: self)
            return
        }
        
        guard let indexPath = sender.tableViewIndexPath(tableView: self.tblView) else { return }
        self.replyMsg(row: ((self.chatArray.count-1)-indexPath.row), isEditng: true)
    }
    
    func viewAllBtnTap(sender: UIButton) {
        
        guard let indexPath = sender.tableViewIndexPath(tableView: self.tblView) else { return }
        self.replyMsg(row: ((self.chatArray.count-1)-indexPath.row), isEditng: false)
    }
    
    
    func userImageBtnTap(sender: UIButton) {
        
        guard let indexPath = sender.tableViewIndexPath(tableView: self.tblView) else { return }
        let index = ((self.chatArray.count-1)-indexPath.row)
        guard let creator = self.chatArray[index]["creator"] as? [String : AnyObject] else { return }
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
    
    func replyMsg(row: Int, isEditng: Bool) {
        guard let chat = self.chatArray[row] as? [String: AnyObject] else { return }
        
        print_debug(object: chat)
        
        self.moveKeyboard = false
        //APP_DELEGATE.statusBarHidden = true // nitin
        let vc = self.storyboard!.instantiateViewController(withIdentifier:"RepliesVC") as! RepliesVC
        vc.commentVCDelegate = self
        vc.isEditng = isEditng
        vc.chat = chat
        let navController = UINavigationController(rootViewController: vc)
        navController.navigationBar.isHidden = true
        navController.modalPresentationCapturesStatusBarAppearance = true
        self.present(navController, animated:true, completion: nil)
        self.view.layoutIfNeeded()
    }
    
    func moveChatToBottom() {
        let numberOfRows = self.tblView.numberOfRows(inSection: 0)
        if numberOfRows > 0 {
            let indexPath = IndexPath(row: numberOfRows-1, section: 0)
            self.tblView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.bottom, animated: false)
        }
    }
    
    func commentImageViewTapped(img: UIGestureRecognizer) {
        
        guard let indexPath = img.view!.tableViewIndexPath(tableView: self.tblView) else {
            return
        }
        guard let val = self.chatArray[(self.chatArray.count-1)-indexPath.row] as? [String: AnyObject]  else { return  }
        
        guard let content = val["content"] as? String else {
            print_debug(object: "Content not found in cellforRowAtIndex.")
            return
        }
        
        
        
        
        
        guard let images = val["images"] as? [AnyObject], images.count > 0 else {
            print_debug(object: "images not found in FromUserImgCell.")
            return
        }
        
        guard let url = images[0]["url"] as? String else {
            print_debug(object: "url not found in FromUserImgCell.")
            return
        }
        
        
        
        if content.isEmpty {
            //Return FromImageCell
            self.view.endEditing(true)
            
            if url.isEmpty {
                guard let tempImg = images[0]["tempImg"] as? UIImage else {
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
                    
                    APP_DELEGATE.setStatusBarHidden(true, with: .none)
                })
            }
        }
    }
    
    func commentUserNameTapped(img: UIGestureRecognizer) {
        
        guard let indexPath = img.view!.tableViewIndexPath(tableView: self.tblView) else {
            return
        }
        
        let index = ((self.chatArray.count-1)-indexPath.row)
        guard let creator = self.chatArray[index]["creator"] as? [String : AnyObject] else { return }
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
    
    func flagBtnTap(sender: UIButton) {
        
        guard let indexPath = sender.tableViewIndexPath(tableView: self.tblView) else { return }
        let msgDic = self.chatArray[(self.chatArray.count-1)-indexPath.row]
        guard let msgId = msgDic["id"] as? String else { return }
        
        
        guard let uID = msgDic["id"] as? String else { return }
        
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        
        
        
        let report = UIAlertAction(title: "Flag this message", style: .default, handler: {
            
            (alert: UIAlertAction!) -> Void in
            
            let optionMenu = UIAlertController(title: CommonTexts.FlagThisComment, message: nil, preferredStyle: .alert)
            
            let yesAction = UIAlertAction(title: "Yes", style: .default, handler: {
                
                (alert: UIAlertAction!) -> Void in
                
                self.flagComment(commentId: msgId)
                
                
                //self.reportUser(userId: uID)
            })
            
            let noAction = UIAlertAction(title: "No", style: .destructive, handler: {
                
                (alert: UIAlertAction!) -> Void in
                
                
            })
            optionMenu.addAction(yesAction)
            optionMenu.addAction(noAction)
            
            self.present(optionMenu, animated: true, completion: nil)
            
        })
        
        
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
                    
                    self.blockUser(userId: uID)
                    
                    
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
        
        
        optionMenu.addAction(report)
        optionMenu.addAction(blockAction)
        optionMenu.addAction(cancelAction)
        
        
        
        self.present(optionMenu, animated: true, completion: nil)
    }
}

//MARK:- UITextViewDelegate
//MARK:-
extension CommentVC: UITextViewDelegate {
    
    //MARK:- UITextView Delgate
    //MARK:-
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.moveChatToBottom()
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        /*
         if textView.text.characters.count > 0 {
         self.cameraBtnState = .Send
         self.cameraBtn.setImage(UIImage(), for:  .normal)
         self.cameraBtn.setTitle("SEND", for:  .normal)
         } else {
         self.cameraBtnState = .Camera
         self.cameraBtn.setTitle("", for:  .normal)
         self.cameraBtn.setImage(UIImage(named: "comment_capture"), for:  .normal)
         }*/
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        /*
         if textView.text.characters.count > 0 {
         self.cameraBtnState = .Send
         self.cameraBtn.setImage(UIImage(), for:  .normal)
         self.cameraBtn.setTitle("SEND", for:  .normal)
         } else {
         self.cameraBtnState = .Camera
         self.cameraBtn.setTitle("", for:  .normal)
         self.cameraBtn.setImage(UIImage(named: "comment_capture"), for:  .normal)
         }*/
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        
        print("link clicked")
        
        let webViewVC = self.storyboard?.instantiateViewController(withIdentifier:"WebViewVC") as! WebViewVC
        webViewVC.urlString = URL.absoluteString
        self.present(webViewVC, animated: true, completion: {
            APP_DELEGATE.statusBarStyle = .default
        })
        
        return false
    }
}


//MARK:- UITableView Delegate & DataSource
//MARK:-
extension CommentVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.chatArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let chats = self.chatArray[(self.chatArray.count-1)-indexPath.row] as? [String: AnyObject] {
            guard let content = chats["content"] as? String else {
                print_debug(object: "Content not found in cellforRowAtIndex.")
                return UITableViewCell()
            }
            
            if !content.isEmpty {
                let cell = tableView.dequeueReusableCell(withIdentifier: "CommentTxtCell", for:  indexPath) as! CommentTxtCell
                
                self.setChatData(cell: cell, indexPath: indexPath)
                cell.replayBtn.addTarget(self, action: #selector(CommentVC.replieBtnTap(sender:)), for: .touchUpInside)
                cell.viewAllBtn.addTarget(self, action: #selector(CommentVC.viewAllBtnTap(sender:)), for: .touchUpInside)
                cell.likeBtn.addTarget(self, action: #selector(CommentVC.likeBtnTap(sender:)), for: .touchUpInside)
                //cell.flagBtn.isHidden = true
                cell.commentTextView.delegate = self
                cell.profileImageButton.addTarget(self, action: #selector(CommentVC.userImageBtnTap(sender:)), for: .touchUpInside)
                cell.flagBtn.addTarget(self, action: #selector(CommentVC.flagBtnTap(sender:)), for: .touchUpInside)
                return cell
            } else {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "CommentImgCell", for:  indexPath) as! CommentImgCell
                self.setChatImageData(cell: cell, indexPath: indexPath)
                
                cell.replayBtn.addTarget(self, action: #selector(CommentVC.replieBtnTap(sender:)), for: .touchUpInside)
                cell.viewAllBtn.addTarget(self, action: #selector(CommentVC.viewAllBtnTap(sender:)), for: .touchUpInside)
                cell.likeBtn.addTarget(self, action: #selector(CommentVC.likeBtnTap(sender:)), for: .touchUpInside)
                //cell.flagBtn.isHidden = true
                cell.profileImageButton.addTarget(self, action: #selector(CommentVC.userImageBtnTap(sender:)), for: .touchUpInside)
                cell.flagBtn.addTarget(self, action: #selector(CommentVC.flagBtnTap(sender:)), for: .touchUpInside)
                
                return cell
                
            }
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            self.commentTextView.resignFirstResponder()
        
    }
    
    func setChatData(cell: CommentTxtCell, indexPath: IndexPath) {
        
        if let chats = self.chatArray[(self.chatArray.count-1)-indexPath.row] as? [String: AnyObject] {
            
            if let content  = chats["content"] {
                let myAttribute = [ NSFontAttributeName: CommonFonts.SFUIText_Regular(setsize: 17) ]

                cell.commentTextView.attributedText = NSAttributedString(string: "\(content)", attributes: myAttribute)
                
                
                
            } else {
                cell.commentTextView.attributedText = NSAttributedString(string:"")
            }
            
            guard let creator = chats["creator"] as? [String : AnyObject] else { return }
            guard let uID = creator["id"] as? String else { return }
            
            if let id = CurrentUser.userId, uID == id {
               cell.flagBtn.isHidden = true
            } else {
                cell.flagBtn.isHidden = false
            }
            
            if let countReplies  = chats["countReplies"] {
                
                let counter = countReplies.integerValue ?? 0
                
                if counter < 0 {
                    cell.viewAllBtn.setTitle("", for:  .normal)
                    cell.viewAllBtn.isHidden = true
                    cell.viewAlBtnHeightCons.constant = 0
                } else {
                    if counter == 0 {
                        cell.viewAllBtn.setTitle("", for:  .normal)
                        cell.viewAllBtn.isHidden = true
                        cell.viewAlBtnHeightCons.constant = 0
                    } else if counter == 1 {
                        cell.viewAllBtn.setTitle("View \(counter) Reply", for:  .normal)
                        cell.viewAllBtn.isHidden = false
                        cell.viewAlBtnHeightCons.constant = 30
                    } else {
                        cell.viewAllBtn.setTitle("View \(countReplies) Replies", for:  .normal)
                        cell.viewAllBtn.isHidden = false
                        cell.viewAlBtnHeightCons.constant = 30
                    }
                }
                
            } else {
                cell.viewAllBtn.setTitle("", for:  .normal)
                cell.viewAllBtn.isHidden = true
                cell.viewAlBtnHeightCons.constant = 0
            }
            
            if let postTime = chats["postTime"] as? String   {
                
                if postTime.isEmpty {
                    cell.timeLbl.text = "just now"
                    cell.grayDotView.isHidden = true
                    cell.showLikeLbl.isHidden = true
                    cell.frstRedDotView.isHidden = true
                    cell.secondRedDotView.isHidden = true
                    cell.likeBtn.isHidden = true
                    cell.replayBtn.isHidden = true
                    
                    
                    
                } else {
                    cell.grayDotView.isHidden = false
                    cell.showLikeLbl.isHidden = false
                    cell.frstRedDotView.isHidden = false
                    cell.secondRedDotView.isHidden = false
                    cell.likeBtn.isHidden = false
                    cell.replayBtn.isHidden = false
                    
                    if let userLiked  = chats["userLiked"] as? Bool, userLiked == true  {
                        cell.likeBtn.isHidden = true
                        cell.frstRedDotView.isHidden = true
                        cell.likeBtn.setTitle("", for: .normal)
                        cell.likeBtnWitdhConstraint.constant = 0
                    } else {
                        cell.likeBtn.isHidden = false
                        cell.frstRedDotView.isHidden = false
                        cell.likeBtn.setTitle("Like", for: .normal)
                        cell.likeBtnWitdhConstraint.constant = 42
                    }
                    
                    let dateFormat = DateFormatter()
                    dateFormat.timeZone = TimeZone(identifier: "UTC")
                    dateFormat.dateFormat =  "yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"
                    
                    let preConvertedDate = dateFormat.date(from: postTime)
                    dateFormat.dateFormat = "dd/MM/yyyy hh:mm a"
                    dateFormat.timeZone = TimeZone.current
                    dateFormat.locale = NSLocale.current
                    let convertedDateString = dateFormat.string(from: preConvertedDate!)
                    print_debug(object: convertedDateString)
                    
                    let convertedDate = dateFormat.date(from: convertedDateString)
                    print_debug(object: convertedDate)
                    
                    let days = CommonFunctions.calculateDateTime(dateToCompare: convertedDate! as NSDate)
                    
                    print_debug(object: days)
                    
                    
                    if days.contains("s") {
                        cell.timeLbl.text = "just now"
                    } else {
                        cell.timeLbl.text = days + " ago"
                    }
                    
                }
                
            }
            
            if let countLikes  = chats["countLikes"] {
                let like = countLikes.integerValue ?? 0
                cell.grayDotView.isHidden = false
                if like == 0 {
                    cell.showLikeLbl.text = ""
                    cell.grayDotView.isHidden = true
                    cell.grayDotTrailingConstraint.constant = 0
                    cell.grayDotViewLeadingConstraint.constant = 0
                    //cell.likeBtnWitdhConstraint.constant = 0
                }
                else if like == 1 {
                    cell.showLikeLbl.text = "\(like) like"
                    cell.grayDotTrailingConstraint.constant = 10
                    cell.grayDotViewLeadingConstraint.constant = 10
                    //cell.likeBtnWitdhConstraint.constant = 42
                } else {
                    cell.showLikeLbl.text = "\(like) likes"
                    cell.grayDotTrailingConstraint.constant = 10
                    cell.grayDotViewLeadingConstraint.constant = 10
                    //cell.likeBtnWitdhConstraint.constant = 42
                }
            } else {
                //cell.showLikeLbl.text = "0 like"
                cell.showLikeLbl.text = ""
                cell.grayDotView.isHidden = true
                cell.likeBtnWitdhConstraint.constant = 0
                cell.grayDotTrailingConstraint.constant = 0
                cell.grayDotViewLeadingConstraint.constant = 0
            }
            
            
            
            
            
            if let creator = chats["creator"] as? [String : AnyObject] {
                let name = creator["name"] as? String ?? ""
                cell.nameLbl.text = name
                
                let avatarURL = creator["avatarURL"] as? String ?? ""
                if let url = URL(string: avatarURL) {
                    cell.profileImageView.sd_setImage(with: url, placeholderImage: PROFILEPLACEHOLDER)
                } else {
                    cell.profileImageView.image = PROFILEPLACEHOLDER
                }
                
                let id = creator["id"] as? String ?? ""
                
                if CurrentUser.userId == id {
                    //cell.likeBtn.isSelected = true
                } else {
                    //cell.likeBtn.isSelected = false
                }
            }
            
            
            let chatUserNameTap = UITapGestureRecognizer(target:self, action:#selector(self.commentUserNameTapped(img:)))
            cell.nameLbl.isUserInteractionEnabled = true
            cell.nameLbl.addGestureRecognizer(chatUserNameTap)
        }
        
        
    }
    
    func setChatImageData(cell: CommentImgCell, indexPath: IndexPath) {
        
        if let chats = self.chatArray[(self.chatArray.count-1)-indexPath.row] as? [String: AnyObject] {
            
            guard let creator = chats["creator"] as? [String : AnyObject] else { return }
            guard let uID = creator["id"] as? String else { return }
            
            if let id = CurrentUser.userId, uID == id {
                cell.flagBtn.isHidden = true
            } else {
                cell.flagBtn.isHidden = false
            }
            
            if let countReplies  = chats["countReplies"] {
                
                let counter = countReplies.integerValue ?? 0
                
                if counter < 0 {
                    cell.viewAllBtn.setTitle("", for:  .normal)
                    cell.viewAllBtn.isHidden = true
                    cell.viewAlBtnHeightCons.constant = 0
                } else {
                    if counter == 0 {
                        cell.viewAllBtn.setTitle("", for:  .normal)
                        cell.viewAllBtn.isHidden = true
                        cell.viewAlBtnHeightCons.constant = 0
                    } else if counter == 1 {
                        cell.viewAllBtn.setTitle("View \(counter) Reply", for:  .normal)
                        cell.viewAllBtn.isHidden = false
                        cell.viewAlBtnHeightCons.constant = 30
                    } else {
                        cell.viewAllBtn.setTitle("View \(countReplies) Replies", for:  .normal)
                        cell.viewAllBtn.isHidden = false
                        cell.viewAlBtnHeightCons.constant = 30
                    }
                }
                
            } else {
                cell.viewAllBtn.setTitle("", for:  .normal)
                cell.viewAllBtn.isHidden = true
                cell.viewAlBtnHeightCons.constant = 0
            }
            
            if let postTime = chats["postTime"] as? String   {
                
                if postTime.isEmpty {
                    cell.timeLbl.text = "just now"
                    cell.grayDotView.isHidden = true
                    cell.showLikeLbl.isHidden = true
                    cell.frstRedDotView.isHidden = true
                    cell.secondRedDotView.isHidden = true
                    cell.likeBtn.isHidden = true
                    cell.replayBtn.isHidden = true
                    
                    
                    
                } else {
                    cell.grayDotView.isHidden = false
                    cell.showLikeLbl.isHidden = false
                    cell.frstRedDotView.isHidden = false
                    cell.secondRedDotView.isHidden = false
                    cell.likeBtn.isHidden = false
                    cell.replayBtn.isHidden = false
                    
                    if let userLiked  = chats["userLiked"] as? Bool, userLiked == true  {
                        cell.likeBtn.isHidden = true
                        cell.frstRedDotView.isHidden = true
                        cell.likeBtn.setTitle("", for: .normal)
                        cell.likeBtnWitdhConstraint.constant = 0
                    } else {
                        cell.likeBtn.isHidden = false
                        cell.frstRedDotView.isHidden = false
                        cell.likeBtn.setTitle("Like", for: .normal)
                        cell.likeBtnWitdhConstraint.constant = 42
                    }
                    
                    let dateFormat = DateFormatter()
                    dateFormat.timeZone = TimeZone(identifier: "UTC")
                    dateFormat.dateFormat =  "yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"
                    
                    let preConvertedDate = dateFormat.date(from: postTime)
                    dateFormat.dateFormat = "dd/MM/yyyy hh:mm a"
                    dateFormat.timeZone = TimeZone.current
                    dateFormat.locale = NSLocale.current
                    let convertedDateString = dateFormat.string(from: preConvertedDate!)
                    print_debug(object: convertedDateString)
                    
                    let convertedDate = dateFormat.date(from: convertedDateString)
                    print_debug(object: convertedDate)
                    
                    let days = CommonFunctions.calculateDateTime(dateToCompare: convertedDate! as NSDate)
                    
                    print_debug(object: days)
                    
                    
                    if days.contains("s") {
                        cell.timeLbl.text = "just now"
                    } else {
                        cell.timeLbl.text = days + " ago"
                    }
                    
                }
                
            }
            
            if let countLikes  = chats["countLikes"] {
                let like = countLikes.integerValue ?? 0
                cell.grayDotView.isHidden = false
                if like == 0 {
                    cell.showLikeLbl.text = ""
                    cell.grayDotView.isHidden = true
                   // cell.likeBtnWitdhConstraint.constant = 0
                    cell.grayDotTrailingConstraint.constant = 0
                    cell.grayDotViewLeadingConstraint.constant = 0
                }
                else if like == 1 {
                    cell.showLikeLbl.text = "\(like) like"
                    //cell.likeBtnWitdhConstraint.constant = 42
                    cell.grayDotTrailingConstraint.constant = 10
                    cell.grayDotViewLeadingConstraint.constant = 10
                } else {
                    cell.showLikeLbl.text = "\(like) likes"
                    //cell.likeBtnWitdhConstraint.constant = 42
                    cell.grayDotTrailingConstraint.constant = 10
                    cell.grayDotViewLeadingConstraint.constant = 10
                }
            } else {
                //cell.showLikeLbl.text = "0 like"
                cell.showLikeLbl.text = ""
                cell.grayDotView.isHidden = true
                //cell.likeBtnWitdhConstraint.constant = 42
                cell.grayDotTrailingConstraint.constant = 0
                cell.grayDotViewLeadingConstraint.constant = 0
            }
            
            if let creator = chats["creator"] as? [String : AnyObject] {
                let name = creator["name"] as? String ?? ""
                cell.nameLbl.text = name
                
                let avatarURL = creator["avatarURL"] as? String ?? ""
                if let url = URL(string: avatarURL) {
                    cell.profileImageView.sd_setImage(with: url, placeholderImage: PROFILEPLACEHOLDER)
                } else {
                    cell.profileImageView.image = PROFILEPLACEHOLDER
                }
                
                let id = creator["id"] as? String ?? ""
                
                if CurrentUser.userId == id {
                    //cell.likeBtn.isSelected = true
                } else {
                    //cell.likeBtn.isSelected = false
                }
            }
            
            if let id = chats["id"] as? String, id.hasSuffix("_TempId")  {
                cell.spinner.startAnimating()
                cell.spinner.isHidden = false
            } else {
                cell.spinner.stopAnimating()
                cell.spinner.isHidden = true
            }
            
            let chatImageTap = UITapGestureRecognizer(target:self, action:#selector(self.commentImageViewTapped(img:)))
            cell.commentImgView.isUserInteractionEnabled = true
            cell.commentImgView.addGestureRecognizer(chatImageTap)
            
            let chatUserNameTap = UITapGestureRecognizer(target:self, action:#selector(self.commentUserNameTapped(img:)))
            cell.nameLbl.isUserInteractionEnabled = true
            cell.nameLbl.addGestureRecognizer(chatUserNameTap)
            
            
            guard let images = chats["images"] as? [AnyObject], images.count > 0  else {
                print_debug(object: "images not found in FromUserImgCell.")
                return
            }
            
            
            guard let url = images[0]["url"] as? String else {
                print_debug(object: "url not found in FromUserImgCell.")
                return
            }
            
            
            if url.isEmpty {
                guard let tempImg = images[0]["tempImg"] as? UIImage else {
                    print_debug(object: "tempImg not found...")
                    cell.commentImgView.image = AppIconPLACEHOLDER
                    cell.commentImgView.contentMode = .center

                    return
                }
                print_debug(object: "url is empty in FromUserImgCell.")
                cell.commentImgView.image = tempImg
                cell.commentImgView.contentMode = .scaleToFill
            } else {

                //cell.commentImgView.sd_setImage(with: URL(string: url), placeholderImage: AppIconPLACEHOLDER)
                
                SDWebImageManager.shared().imageDownloader?.downloadImage(with: URL(string: url), options: [], progress: nil, completed: { (image, data, error, succes) in
                    
                    
                        //On Main Thread
                       // DispatchQueue.main.async(){
                            if let newimage = image {
                                cell.commentImgView.image = newimage
                                cell.commentImgView.contentMode = .scaleToFill
                            } else {
                                cell.commentImgView.image = CONTAINERPLACEHOLDER
                                cell.commentImgView.contentMode = .center
                            }
                       // }
                    
                })
            }
            
        }
    }
    
    func refresh(sender: AnyObject) {
        
        if let re = sender as? UIRefreshControl {
            if self.size != 0 || self.size == -1 {
                if self.size == -1{
                    self.size = 0
                }
                self.from = self.size + self.from
                re.beginRefreshing()
                if let firstMsg = self.chatArray.last {
                    let msgTime = firstMsg["postTime"] as? String ?? ""
                    self.getPreviousChannelChat(channelId: self.channelId, from: self.from, size: 10, postTime: msgTime)
                }
            } else {
                re.endRefreshing()
            }
        }
    }
}



//MARK:- WebService
//MARK:-
extension CommentVC {
    
    
    func getChannelChat(channelId: String, from: Int, size: Int) {
        
        let url = WS_ChannelChat + "?" + "parentID=&postTime=&previous=false&channels=\(channelId)&from=\(from)&size=\(size)"
        
        WebServiceController.getChannelsChat(url: url, parameters: [String : AnyObject]()) { (sucess, errorMessage, data) in
            if sucess {
                
                if let chats = data as? [[String: AnyObject]] {
                 //   print_debug(object: chats)
                    
                    if !chats.isEmpty {
                        //self.noChatLbl.isHidden = true
                        //self.chatArray.append(contentsOf: chats)
                        for obj in chats {
                            
                            var newChatExist = false
                            for oldChat in self.chatArray {
                                if let oldChatId = oldChat["id"] as? String, let newChatId = obj["id"] as? String, oldChatId ==  newChatId {
                                    newChatExist = true
                                    break
                                }
                                
                                
                            }
                            if newChatExist ==  false {
                                self.chatArray.append(contentsOf: [obj])
                            }
                            
                            //self.chatArray.insert(obj, atIndex: 0)
                        }
                        
                        self.updateSize = self.chatArray.count
                        self.tblView.reloadData()
                        if self.from == 0 {
                            self.moveChatToBottom()
                        }
                    } else {
                        self.size = -1
                        //self.noChatLbl.isHidden = false
                    }
                    self.refreshControl.endRefreshing()
                    
                } else {
                    //self.noChatLbl.isHidden = false
                }
            }
            
            
            
            self.activityIndicator.isHidden = true
            if self.chatArray.count == 0 {
                self.noChatLbl.isHidden = false
                self.tblView.isHidden = true
            } else {
                self.noChatLbl.isHidden = true
                self.tblView.isHidden = false
            }
            self.refreshControl?.endRefreshing()
        }
    }
    
    func getPreviousChannelChat(channelId: String, from: Int, size: Int, postTime : String) {
        
        let url = WS_ChannelChat + "?" + "parentID=&postTime=\(postTime)&previous=true&channels=\(channelId)&from=\(0)&size=\(size)"
        
        WebServiceController.getChannelsChat(url: url, parameters: [String : AnyObject]()) { (sucess, errorMessage, data) in
            if sucess {
                
                if let chats = data as? [[String: AnyObject]] {
                  //  print_debug(object: chats)
                    
                    if !chats.isEmpty {
                        //self.noChatLbl.isHidden = true
                        for obj in chats {
                            
                            var newChatExist = false
                            for oldChat in self.chatArray {
                                if let oldChatId = oldChat["id"] as? String, let newChatId = obj["id"] as? String, oldChatId ==  newChatId {
                                    newChatExist = true
                                    break
                                }
                                
                                
                            }
                            if newChatExist ==  false {
                                self.chatArray.append(contentsOf: [obj])
                            }
                            
                            //self.chatArray.insert(obj, atIndex: 0)
                        }
                        self.updateSize = self.chatArray.count
                        self.tblView.reloadData()
                        if self.from == 0 {
                            self.moveChatToBottom()
                        }
                    } else {
                        self.size = -1
                        //self.noChatLbl.isHidden = false
                    }
                    self.refreshControl.endRefreshing()
                    
                } else {
                    //self.noChatLbl.isHidden = false
                }
            }
            
            
            
            self.activityIndicator.isHidden = true
            if self.chatArray.count == 0 {
                self.noChatLbl.isHidden = false
                self.tblView.isHidden = true
            } else {
                self.noChatLbl.isHidden = true
                self.tblView.isHidden = false
            }
            self.refreshControl.endRefreshing()
        }
    }
    
    func sendChat(msg: String, isImage: Bool, chatId : String) {
        
        var imageArray : [String] = [String]()
        if isImage == true {
            imageArray.append(msg)
        }
        
        var param = [String: AnyObject]()
        param["parentID"]       =  "" as AnyObject
        param["content"]        =   isImage == true ? "" as AnyObject : msg as AnyObject
        param["imageIDs"]       =  imageArray as AnyObject
        param["targetChannels"] =  [self.channelId] as AnyObject
        param["targetUsers"]    =  [] as AnyObject
        
        param["fromUser"]       =  [
            "id"        : CurrentUser.userId!,
            "name"      : CurrentUser.name!,
            "avatarID"  : CurrentUser.avatarID!,
            "tagLine"   : "",
            "country"   : CurrentUser.country ?? "",
            "admin"     : CurrentUser.isAdmin ?? false
            ] as AnyObject
        
        
        WebServiceController.sendChat(parameters: param) { (sucess, DataHeaderResponse, DataResultResponse) in
            
            if sucess {
                print("Sucess")
                
                if let chat = DataResultResponse {
                    if !chat.isEmpty {
                        //self.noChatLbl.isHidden = true
                        //self.chatArray.append(chats)
                        
                        var oldChatIndex = 0
                        for oldChat in self.chatArray {
                            if let oldChatId = oldChat["id"] as? String, oldChatId ==  chatId {
                                self.chatArray.remove(at: oldChatIndex)
                                self.chatArray.insert(contentsOf: [chat], at: 0)
                                break
                            }
                            oldChatIndex += 1
                            
                        }
                        
//                        self.chatArray.remove(at: 0)
//                        self.chatArray.insert(contentsOf: [chat], at: 0)
                        self.updateSize = self.chatArray.count
                        //self.noChatLbl.isHidden = true
                        self.tblView.reloadData()
                    }
                    
                } else {
                    print("Not parse")
                    var oldChatIndex = 0
                    for oldChat in self.chatArray {
                        if let oldChatId = oldChat["id"] as? String, oldChatId ==  chatId {
                            self.chatArray.remove(at: oldChatIndex)
                            break
                        }
                        oldChatIndex += 1
                        
                    }
                }
            } else {
                print("Faild")
                var oldChatIndex = 0
                for oldChat in self.chatArray {
                    if let oldChatId = oldChat["id"] as? String, oldChatId ==  chatId {
                        self.chatArray.remove(at: oldChatIndex)
                        break
                    }
                    oldChatIndex += 1
                    
                }
            }
            
            self.activityIndicator.isHidden = true
            if self.chatArray.count == 0 {
                self.noChatLbl.isHidden = false
                self.tblView.isHidden = true
            } else {
                self.noChatLbl.isHidden = true
                self.tblView.isHidden = false
            }
        }
        
    }
    
    // nitin
    func updateChats() {
        
        let url = WS_ChannelChat + "?" + "parentID=&postTime=&previous=false&channels=\(self.channelId!)&from=\(0)&size=\(10)"
        
        WebServiceController.getChannelsChat(url: url, parameters: [String : AnyObject]()) { (sucess, errorMessage, data) in
            
            if sucess {
                
                if let chats = data as? [[String: AnyObject]] {
                    
                    if !chats.isEmpty {
                        //self.noChatLbl.isHidden = true
                        //                        if chats.count == self.updateSize {
                        
                        print_debug(object: chats)
                        
                        //                            self.chatArray.removeAll(keepingCapacity: false)
                        //self.chatArray = chats
                        
                        //
                        let count = self.chatArray.count
                        for newChat in chats {
                            
                            var newChatExist = false
                            var oldChatIndex = 0
                            for oldChat in self.chatArray {
                                if let oldChatId = oldChat["id"] as? String, let newChatId = newChat["id"] as? String, oldChatId ==  newChatId {
                                    newChatExist = true
                                    self.chatArray[oldChatIndex] = newChat
                                    break
                                }
                                oldChatIndex += 1
                                
                            }
                            if newChatExist ==  false {
                                self.chatArray.insert(contentsOf: [newChat], at: 0)
                                self.tblView.reloadData()
                            }
                            
                        }
                        
                        if self.chatArray.count > count {
                            self.tblView.reloadData()
                            self.moveChatToBottom()
                        } else {
                            //self.tblView.reloadData()
                            
                        }
                        //                            let conOffset = self.tblView.contentOffset
                        //                            self.tblView.beginUpdates()
                        //                            self.tblView.endUpdates()
                        //                            self.tblView.layer.removeAllAnimations()
                        //
                        //                            self.tblView.setContentOffset(conOffset, animated: false)
                        
                        
                        //                        } else {
                        //                            //self.chatArray.removeAll(keepingCapacity: false)
                        //                            //self.chatArray = chats
                        //                            //self.tblView.reloadData()
                        //                        }
                        
                    } else {
                        //self.noChatLbl.isHidden = false
                    }
                } else {
                    //self.noChatLbl.isHidden = false
                }
                
            } else {
                //self.noChatLbl.isHidden = false
            }
            
            self.activityIndicator.isHidden = true
            if self.chatArray.count == 0 {
                self.noChatLbl.isHidden = false
                self.tblView.isHidden = true
            } else {
                self.noChatLbl.isHidden = true
                self.tblView.isHidden = false
            }
        }
        
        
    }
    
    func likechat(messageId: String) {
        
        let url = WS_LikeChatMsg + "\(messageId)?flag=true"
        
        
        WebServiceController.Like_Chat_Message(url: url, parameters: [String : AnyObject]()) { (sucess, DataHeaderResponse, DataResultResponse) in
            
            
            print_debug(object: sucess)
            
            print_debug(object: DataHeaderResponse)
            
            print_debug(object: DataResultResponse)
        }
        
    }
    
    func unLikechat(messageId: String) {
        
        let url = WS_LikeChatMsg + "\(messageId)?flag=false"
        
        
        WebServiceController.Like_Chat_Message(url: url, parameters: [String : AnyObject]()) { (sucess, DataHeaderResponse, DataResultResponse) in
            
            
            print_debug(object: sucess)
            
            print_debug(object: DataHeaderResponse)
            
            print_debug(object: DataResultResponse)
        }
        
    }
    
    func getChannelPreviousChat(channelId: String,postTime: String, from: Int, size: Int) {
        
        let url = WS_ChannelChat + "?" + "parentID=&postTime=\(postTime)&previous=false&channels=\(channelId)&from=\(from)&size=\(size)"
        
        WebServiceController.getChannelsChat(url: url, parameters: [String : AnyObject]()) { (sucess, errorMessage, data) in
            if sucess {
                
                if let chats = data as? [[String: AnyObject]] {
                    print_debug(object: chats)
                    
                    if !chats.isEmpty {
                        //self.noChatLbl.isHidden = true
                        let count = self.chatArray.count
                        for newChat in chats {
                            
                            var newChatExist = false
                            for oldChat in self.chatArray {
                                if let oldChatId = oldChat["id"] as? String, let newChatId = newChat["id"] as? String, oldChatId ==  newChatId {
                                    newChatExist = true
                                    break
                                }
                                
                                
                            }
                            if newChatExist ==  false {
                                self.chatArray.insert(contentsOf: [newChat], at: 0)
                            }
                            
                        }
                        
                        if self.chatArray.count > count {
                            self.tblView.reloadData()
                        }                    } else {
                        self.size = -1
                        //self.noChatLbl.isHidden = false
                    }
                    self.refreshControl.endRefreshing()
                    
                } else {
                    //self.noChatLbl.isHidden = false
                }
            }
            
            
            
            self.activityIndicator.isHidden = true
            if self.chatArray.count == 0 {
                self.noChatLbl.isHidden = false
                self.tblView.isHidden = true
            } else {
                self.noChatLbl.isHidden = true
                self.tblView.isHidden = false
            }
            self.refreshControl.endRefreshing()
        }
    }
    
    
    func uploadChatPic(tempImg: UIImage, chatId : String) {
        
        guard CurrentUser.userId != nil else { return }
        
        let url = WS_UploadImage + "?userAvatar=false&seedImgID=&channelChat=true&userChat=false"
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
                let _ : [String] = [id]
                if !id.isEmpty {
                    
                    self.sendChat(msg: id, isImage: true, chatId: chatId)
                } else {
                    
                    var oldChatIndex = 0
                    for oldChat in self.chatArray {
                        if let oldChatId = oldChat["id"] as? String, oldChatId ==  chatId {
                            self.chatArray.remove(at: oldChatIndex)
                            break
                        }
                        oldChatIndex += 1
                        
                    }
                    
                    
                    //self.chatArray.remove(at: 0)
                    self.tblView.reloadData()
                }
                
                
            } else{
                var oldChatIndex = 0
                for oldChat in self.chatArray {
                    if let oldChatId = oldChat["id"] as? String, oldChatId ==  chatId {
                        self.chatArray.remove(at: oldChatIndex)
                        break
                    }
                    oldChatIndex += 1
                    
                }
            }
        }
        
    }
    
    func sendTemImgMsg(sendImg: UIImage) {
        
        
        var tempimgObject           = [String: AnyObject]()
        tempimgObject["id"]         = "" as AnyObject
        tempimgObject["url"]        = "" as AnyObject
        tempimgObject["thumbURL"]   = "" as AnyObject
        tempimgObject["tempImg"]    = sendImg as AnyObject
        
        
        let chatId = Globals.getUniqueIdentifier() + "_TempId"
        
        let jsonData: [String: AnyObject] = [
            "id":  chatId as AnyObject,
            "parentID": "" as AnyObject,
            "creator": [
                "id": "\(CurrentUser.userId ?? "" )",
                "name": "\(CurrentUser.name ?? "" )",
                "tagLine": "",
                "country": "\(CurrentUser.country ?? "" )",
                "avatarID": "\(CurrentUser.avatarID ?? "" )",
                "avatarURL": "\(CurrentUser.avatarExtURL ?? "" )",
                "admin": "\(CurrentUser.isAdmin ?? false)"
                ] as AnyObject,
            "postTime": "" as AnyObject,
            "channels": [
                "\(self.channelId ?? "")"
                ] as AnyObject,
            "users": [
                "\(CurrentUser.userId ?? "")"
                ] as AnyObject,
            "content": "\(self.commentTextView.text ?? "")" as AnyObject,
            "countReplies": -1 as AnyObject,
            "countFlags": 0 as AnyObject,
            "countLikes": 0 as AnyObject,
            "images" : [tempimgObject] as AnyObject
        ]
        print_debug(object: tempimgObject)
        print_debug(object: jsonData)
        
        self.chatArray.insert(contentsOf: [jsonData], at: 0)
        if self.chatArray.count == 0 {
            self.noChatLbl.isHidden = false
        } else {
            self.noChatLbl.isHidden = true
        }
        self.activityIndicator.isHidden = true
        if self.chatArray.count == 0 {
            self.noChatLbl.isHidden = false
            self.tblView.isHidden = true
        } else {
            self.noChatLbl.isHidden = true
            self.tblView.isHidden = false
        }
        self.tblView.reloadData()
        self.moveChatToBottom()
        
        self.uploadChatPic(tempImg: sendImg, chatId: chatId)
        
    }
    
    func flagComment(commentId : String) {
        
        CommonFunctions.showLoader()
        let url = WS_ReportMessage + "\(commentId)?flag=true"
        
        WebServiceController.ReportComment(url: url, parameters: [String:AnyObject]()) { (sucess, msg, DataResultResponse) in
            CommonFunctions.hideLoader()
            if sucess {
                CommonFunctions.showAlertSucess(title: CommonTexts.Success, msg: CommonTexts.Reported_SuccessFully) // nitin
                
            } else {
                //CommonFunctions.showAlertWarning(msg: "Detail is not update.")
            }
            
        }
        
    }
    
    func blockUser(userId : String) {
        
        CommonFunctions.showLoader()
        let url = WS_BlockUser + "\(CurrentUser.userId ?? "")/block"
        var param = [String:AnyObject]()
        param["userID"] = userId as AnyObject
        param["block"] = true as AnyObject
        
        WebServiceController.blockUser(url: url, parameters: param) { (sucess, msg, DataResultResponse) in
            CommonFunctions.hideLoader()
            if sucess {
                CommonFunctions.showAlertSucess(title: CommonTexts.Success, msg: CommonTexts.Blocked_SuccessFully) // nitin
                self.chatArray.removeAll()
                self.from = 0
                self.size = 40 // nitin
                self.updateSize = 0
                self.getChannelChat(channelId: self.channelId, from: self.from, size: self.size)
                self.tblView.reloadData()
            } else {
                //CommonFunctions.showAlertWarning(msg: "Detail is not update.")
            }
            
        }
        
    }
}



//MARK:- CommentVCDelegate
//MARK:-
extension CommentVC : CommentVCDelegate {
    func updateReplyCounter(chatId: String, count: Int) {
        
        
        for (index, temp) in self.chatArray.enumerated() {
            
            if  let obj = temp as? [String: AnyObject] {
                
                if  let tempChatID = obj["id"] as? String  {
                    if tempChatID == chatId {
                        var tempChat = obj
                        tempChat["countReplies"] =  count as AnyObject
                        self.chatArray[index] = tempChat
                        self.tblView.reloadData()
                        break
                    }
                }
            }
        }
        
        
    }
    
    
}


//MARK:- UIImagePickerController & UINavigationController Delegate
//MARK:-
extension CommentVC :  UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
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
                
                //self.picker.mediaTypes = forTypes
                
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
        CommonFunctions.delay(delay: 0.2) { 
            if let vc = self.parent as? ChannelViewFanVC {
                vc.viewDidLayoutSubviews()
                
            }
        }
    }
    
    
    
}


//MARK:- SKPhotoBrowserDelegate
//MARK:-
extension CommentVC :  SKPhotoBrowserDelegate {
    
    func willDismissAtPageIndex(_ index: Int) {
        APP_DELEGATE.setStatusBarHidden(false, with: .none)
        if let vc = self.parent as? ChannelViewFanVC {
            vc.viewDidLayoutSubviews()
            vc.setScrollViewPostion()
        }
    }
    
    func didDismissAtPageIndex(_ index: Int) {
        if let vc = self.parent as? ChannelViewFanVC {
            vc.viewDidLayoutSubviews()
           
        }
    }
    
    
}
