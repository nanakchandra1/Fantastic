//
//  RepliesVC.swift
//  Fantasticoh!
//
//  Created by Appinventiv on 17/09/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import UIKit
import Accelerate
import Photos

protocol RepliesVCDelegate {
    
    func updateReplyCounter(chatId : String, count: Int)
    
}

class RepliesVC: UIViewController {
    
    //MARK:- IBOutlet & Propertie's
    //MARK:-
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var cameraBtn: UIButton!
    @IBOutlet weak var bottomCons: NSLayoutConstraint!
    
    @IBOutlet var backBtn: UIButton!
    @IBOutlet var closeBtn: UIButton!
    @IBOutlet weak var noDataLbl: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let picker: UIImagePickerController = UIImagePickerController()
    
    let commentImgArray = [UIImage(named: "c1"), UIImage(named: "c2"), UIImage(named: "c3"), UIImage(named: "c4"), UIImage(named: "c5"), UIImage(named: "c6"), UIImage(named: "c7"), UIImage(named: "c8")]
    var commentTextArray = ["Ah, the Facebook photo link http://fantasticoh.com ",
                            "email at demo@appinventiv.com"
    ]
    var cameraBtnState = CameraBtnState.None
    var chat = [String: AnyObject]()
    var chatArray = [[String: AnyObject]]()
    var isEditng = false
    var from = 0
    var size = 20
    var refreshControl: UIRefreshControl!
    var timer: Timer!
    //var updateSize = 0
    var commentVCDelegate: CommentVCDelegate!
    var repliesVCDelegate: RepliesVCDelegate!
    
    //MARK:- View Life Cycle
    //MARK:-
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let commentTxtCell = UINib(nibName: "CommentTxtCell", bundle: nil)
        self.tblView.register(commentTxtCell, forCellReuseIdentifier: "CommentTxtCell")
        
        let commentImgCell = UINib(nibName: "CommentImgCell", bundle: nil)
        self.tblView.register(commentImgCell, forCellReuseIdentifier: "CommentImgCell")
        
        self.tblView.delegate = self
        self.tblView.dataSource = self
        self.commentTextView.delegate = self
        
        self.initSetup()
        // nitin
        self.noDataLbl.text = CommonTexts.NoDataIsAvailable
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(RepliesVC.keyboardShow(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(RepliesVC.keyboardHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        self.timer = Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(self.updateData), userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        self.timer.invalidate()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        CommonFunctions.hideKeyboard()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK:- IBAction, Selector & Private Method
    //MARK:-
    func keyboardShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.bottomCons.constant = keyboardSize.height
             self.view.layoutIfNeeded()
        }
    }
    
    func keyboardHide(notification: NSNotification) {
        self.bottomCons.constant = 0
    }
    
    func updateData() {
        
        guard let chatid = self.chat["id"] as? String else { return }
        guard let channels = self.chat["channels"] as? [String] else { return }
        guard let channel = channels.first else { return }
        //self.getChannelChat(chatid, channelId: channel, from: self.from, size: self.size)
        self.updateComments(contentID: chatid, channelId: channel)
    }
    
    @IBAction func backBtnTap(sender: UIButton) {
        
        self.commentTextView.endEditing(true)
        guard let chatid = self.chat["id"] as? String else { return }
        
        if self.navigationController?.viewControllers.count == 1 {
            if self.chatArray.count != 0 {
                self.commentVCDelegate.updateReplyCounter(chatId: chatid, count: self.chatArray.count)
                
            }
            CommonFunctions.delay(delay: 0.01) {
                self.dismiss(animated: true) {
                    APP_DELEGATE.isStatusBarHidden = false
                }
            }
        } else {
            self.repliesVCDelegate.updateReplyCounter(chatId: chatid, count: self.chatArray.count )
            CommonFunctions.delay(delay: 0.01) {
                self.navigationController?.popViewController(animated: true, completion: {
                    APP_DELEGATE.isStatusBarHidden = false
                })
            }
            
        }
        
        
    }
    
    @IBAction func galleryBtnTap(sender: UIButton) {
        //self.checkAndOpenLibrary(["\(kUTTypeImage)"])
    }
    
    @IBAction func cameraBtnTap(sender: UIButton) {
        
        guard CommonFunctions.checkLogin() else {
            CommonFunctions.showLoginAlert(vc: self)
            return
        }
        
        let myString = self.commentTextView.text
        let trimmedString = myString?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if (trimmedString?.isEmpty)! {
            return
        }
        
        self.commentTextView.resignFirstResponder()
        
        guard let parentID = self.chat["id"] else { return }
        let chatId = Globals.getUniqueIdentifier() + "_TempId"
        let jsonData: [String: AnyObject] = [
            "id": chatId as AnyObject,
            "parentID": "\(parentID)" as AnyObject,
            "creator": [
                "id"        : CurrentUser.userId!,
                "name"      : CurrentUser.name!,
                "tagLine"   : "",
                "country"   : CurrentUser.country ?? "",
                "avatarID"  : CurrentUser.avatarID ?? "",
                "avatarURL" : CurrentUser.avatarExtURL ?? "",
                "admin"     : CurrentUser.isAdmin ?? false
            ] as AnyObject,
            "postTime": "" as AnyObject,
            "channels": [
                "\("")"
            ] as AnyObject,
            "users": [
                CurrentUser.userId!
            ] as AnyObject,
            "content": self.commentTextView.text as AnyObject ,
            "images": [] as AnyObject,
            "countReplies": -1 as AnyObject,
            "countFlags": 0 as AnyObject,
            "countLikes": 0 as AnyObject
        ]
        self.chatArray.insert(contentsOf: [jsonData], at: 0)
        self.activityIndicator.isHidden = true
        if self.chatArray.count == 0 {
            //self.noDataLbl.isHidden = false
            //self.tblView.isHidden = true
        } else {
            //self.noDataLbl.isHidden = true
            //self.tblView.isHidden = false
        }
        self.tblView.reloadData()
        self.moveChatToBottom()
        
        if let text = self.commentTextView.text {
            self.sendChat(msg: text, chatId: chatId)
        }
        
        self.commentTextView.text = ""
    }
    
    
    @IBAction func closeBtnTap(sender: UIButton) {
        self.commentTextView.endEditing(true)
        
        guard let chatid = self.chat["id"] as? String else { return }
        
        if self.navigationController?.viewControllers.count == 1 {
            if self.chatArray.count != 0 {
                self.commentVCDelegate.updateReplyCounter(chatId: chatid, count: self.chatArray.count)
            }
        }
        CommonFunctions.delay(delay: 0.001) {
            self.dismiss(animated: true) {
                APP_DELEGATE.isStatusBarHidden = false
            }
            
        }
    }
    
    private func initSetup() {
        
        self.noDataLbl.isHidden = true
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
        self.tblView.isHidden = false
        
        self.tblView.estimatedRowHeight = 50.0
        self.tblView.rowHeight = UITableViewAutomaticDimension
        
        self.bgView.layer.cornerRadius = 12.0
        self.bgView.layer.masksToBounds = true
        self.bgView.clipsToBounds = true
        
        self.commentTextView.layer.cornerRadius = 5.0
        self.commentTextView.layer.masksToBounds = true
        
        self.commentTextView.layer.borderWidth = 0.5
        self.commentTextView.layer.borderColor = CommonColors.lightGrayColor().cgColor
        
        self.cameraBtnState = CameraBtnState.Camera
        
        let commentTxtCell = UINib(nibName: "CommentTxtCell", bundle: nil)
        self.tblView.register(commentTxtCell, forCellReuseIdentifier: "CommentTxtCell")
        
        if self.isEditng {
            self.commentTextView.becomeFirstResponder()
        }
        
        guard let countReplies = self.chat["countReplies"] else { return }
        let counter = Int(countReplies as! NSNumber)
        if counter == 0 {
            return
        }
        guard let chatid = self.chat["id"] as? String else { return }
        guard let channels = self.chat["channels"] as? [String] else { return }
        guard let channel = channels.first else { return }
        self.getChannelChat(contentID: chatid, channelId: channel, from: self.from, size: self.size)
        
        self.refreshControl = UIRefreshControl()
        self.tblView.addSubview(refreshControl)
        self.refreshControl.tintColor = CommonColors.globalRedColor()
        self.refreshControl.addTarget(self, action: #selector(RepliesVC.refresh(sender:)), for: UIControlEvents.valueChanged)
        
        self.tblView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 40, right: 0)
        self.tblView.backgroundColor = UIColor.white
    }
    
    func moreBtnTap(sender: UIButton) {
    }
    
    func replieBtnTap(sender: UIButton) {
        
        guard CommonFunctions.checkLogin() else {
            CommonFunctions.showLoginAlert(vc: self)
            return
        }
        
        guard let indexPath = sender.tableViewIndexPath(tableView: self.tblView) else { return }
        self.replyMsg(row: ((self.chatArray.count-1)-indexPath.row), isEditng: false)
    }
    
    func likeBtnTap(sender: UIButton) {
        
        
        guard CommonFunctions.checkLogin() else {
            CommonFunctions.showLoginAlert(vc: self)
            return
        }
        
        guard let indexPath = sender.tableViewIndexPath(tableView: self.tblView) else { return }
        
        let msgDic = self.chatArray[(self.chatArray.count-1)-indexPath.row]
        guard let msgId = msgDic["id"] as? String else { return }
        
        var tempMsgDic = msgDic
        
        
        
        if let userLiked  = msgDic["userLiked"] as? Bool, userLiked == true  {
            if let countLikes  = msgDic["countLikes"] {
                let like = Int(countLikes as! NSNumber)
                tempMsgDic["countLikes"] = like - 1 as AnyObject
            }
            
            tempMsgDic["userLiked"] = false as AnyObject
            self.unLikechat(messageId: msgId)
        } else {
            if let countLikes  = msgDic["countLikes"] {
                let like = Int(countLikes as! NSNumber)
                tempMsgDic["countLikes"] = like + 1 as AnyObject
            }
            
            tempMsgDic["userLiked"] = true as AnyObject
            self.likechat(messageId: msgId)
        }
        
        self.chatArray[(self.chatArray.count-1)-indexPath.row] = tempMsgDic
        self.tblView.reloadData()
        
    }
    
    func viewAllBtnTap(sender: UIButton) {
        
        guard let indexPath = sender.tableViewIndexPath(tableView: self.tblView) else { return }
        self.replyMsg(row: ((self.chatArray.count-1)-indexPath.row), isEditng: false)
    }
    
     func replyMsg(row: Int, isEditng: Bool) {
        guard let chat = self.chatArray[row] as? [String: AnyObject] else { return }
        print_debug(object: chat)
        //APP_DELEGATE.statusBarHidden = true
        let vc = self.storyboard!.instantiateViewController(withIdentifier:"RepliesVC") as! RepliesVC
        vc.repliesVCDelegate = self
        vc.isEditng = isEditng
        vc.chat = chat
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func moveChatToBottom() {
        let numberOfRows = self.tblView.numberOfRows(inSection: 0)
        if numberOfRows > 0 {
            let indexPath = IndexPath(row: numberOfRows-1, section: 0)
            self.tblView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.bottom, animated: false)
            
        }
    }
    
    func refresh(sender: AnyObject) {
        
        if let re = sender as? UIRefreshControl {
            if self.size != 0 {
                if self.size == -1{
                    self.size = 0
                }
                self.from = self.size + self.from
                re.beginRefreshing()
                //self.getChannelChat("bbceec35c7e04726", from: self.from, size: self.size)
                if let firstMsg = self.chatArray.last {
                    guard let chatid = self.chat["id"] as? String else { return }
                    guard let channels = self.chat["channels"] as? [String] else { return }
                    guard let channel = channels.first else { return }
                    let msgTime = firstMsg["postTime"] as? String ?? ""
                    self.getPreviousChannelChat(contentID: chatid, channelId: channel, from: self.from, size: 10, postTime: msgTime)
                }
            } else {
                re.endRefreshing()
            }
        }
        
        
        
    }
    
    func commentUserNameTapped(img: UIGestureRecognizer) {
        
        guard let indexPath = img.view!.tableViewIndexPath(tableView: self.tblView) else {
            return
        }
        
        let index = (self.chatArray.count-1)-indexPath.row
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
    
    func userImageBtnTap(sender: UIButton) {
        
        guard let indexPath = sender.tableViewIndexPath(tableView: self.tblView) else { return }
        let index = (self.chatArray.count-1)-indexPath.row
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
        
        guard let creator = msgDic["creator"] as? [String : AnyObject] else { return }
        guard let uID = creator["id"] as? String else { return }
        
        
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        
        
        
        let report = UIAlertAction(title: "Flag", style: .default, handler: {
            
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
        
        
        let blockAction = UIAlertAction(title: "Block", style: .default, handler: {
            
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
extension RepliesVC: UITextViewDelegate {
    
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
        /*if textView.text.characters.count > 0 {
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
extension RepliesVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return self.commentTextArray.count
        return self.chatArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentTxtCell", for:  indexPath) as! CommentTxtCell
        cell.selectionStyle = .none
        
        self.setChatData(cell: cell, indexPath: indexPath)
        cell.replayBtn.addTarget(self, action: #selector(RepliesVC.replieBtnTap(sender:)), for: .touchUpInside)
        cell.viewAllBtn.addTarget(self, action: #selector(RepliesVC.viewAllBtnTap(sender:)), for: .touchUpInside)
        cell.likeBtn.addTarget(self, action: #selector(RepliesVC.likeBtnTap(sender:)), for: .touchUpInside)
        cell.profileImageButton.addTarget(self, action: #selector(self.userImageBtnTap(sender:)), for: .touchUpInside)
        cell.flagBtn.addTarget(self, action: #selector(self.flagBtnTap(sender:)), for: .touchUpInside)
        return cell
        
        
    }
    
    
     func setChatData(cell: CommentTxtCell, indexPath: IndexPath) {
        
        if let chats = self.chatArray[(self.chatArray.count-1)-indexPath.row] as? [String: AnyObject] {
            
            if let content  = chats["content"] {
                let myAttribute = [ NSFontAttributeName: CommonFonts.SFUIText_Regular(setsize: 17) ]
                
                cell.commentTextView.attributedText = NSAttributedString(string: "\(content)", attributes: myAttribute)
            } else {
                cell.commentTextView.text = ""
            }
            
            guard let creator = chats["creator"] as? [String : AnyObject] else { return }
            guard let uID = creator["id"] as? String else { return }
            
            if let id = CurrentUser.userId, uID == id {
                cell.flagBtn.isHidden = true
            } else {
                cell.flagBtn.isHidden = false
            }
            
            
            if let countReplies  = chats["countReplies"] {
                print_debug(object: countReplies)
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
                    cell.secondRedDotView.isHidden = true
                    cell.likeBtn.isHidden = false
                    cell.replayBtn.isHidden = true
                    
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
                    let convertedDate = dateFormat.date(from: convertedDateString)
                    let days = CommonFunctions.calculateDateTime(dateToCompare: convertedDate! as NSDate)
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

//                    if cell.profileImageView.image == PROFILEPLACEHOLDER{
//                    cell.profileImageView.sd_setImage(with: url, placeholderImage: PROFILEPLACEHOLDER)
//                    }
                } else {
                    cell.profileImageView.image = PROFILEPLACEHOLDER
                }
            }
            
            cell.profileImageLeadingConstraint.constant = 60
            
            let chatUserNameTap = UITapGestureRecognizer(target:self, action:#selector(self.commentUserNameTapped(img:)))
            cell.nameLbl.isUserInteractionEnabled = true
            cell.nameLbl.addGestureRecognizer(chatUserNameTap)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 300
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        
            guard let content = chat["content"] as? String else {
                print_debug(object: "Content not found in cellforRowAtIndex.")
                return UITableViewCell()
            }
            
            if !content.isEmpty {
                let cell = tableView.dequeueReusableCell(withIdentifier: "CommentTxtCell") as! CommentTxtCell
                
                self.setHeaderData(cell: cell)
                cell.flagBtn.isHidden = true
                cell.commentTextView.delegate = self
                
                return cell.contentView
            } else {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "CommentImgCell") as! CommentImgCell
                
                self.setHeaderImageData(cell: cell)
                cell.flagBtn.isHidden = true
                return cell.contentView
                
            }
        
        
        
    }
    
    
     func setHeaderData(cell: CommentTxtCell ) {
        
        let chats = chat
        
        if let content  = chats["content"] {
            let myAttribute = [ NSFontAttributeName: CommonFonts.SFUIText_Regular(setsize: 17) ]
            
            cell.commentTextView.attributedText = NSAttributedString(string: "\(content)", attributes: myAttribute)
        } else {
            cell.commentTextView.attributedText = NSAttributedString(string:"")
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
                cell.secondRedDotView.isHidden = true
                cell.likeBtn.isHidden = false
                cell.replayBtn.isHidden = true
                
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
            }
            else if like == 1 {
                cell.showLikeLbl.text = "\(like) like"
            } else {
                cell.showLikeLbl.text = "\(like) likes"
            }
        } else {
            //cell.showLikeLbl.text = "0 like"
            cell.showLikeLbl.text = ""
            cell.grayDotView.isHidden = true
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
        
        cell.grayDotView.isHidden = true
        cell.showLikeLbl.isHidden = true
        cell.frstRedDotView.isHidden = true
        cell.secondRedDotView.isHidden = true
        cell.likeBtn.isHidden = true
        cell.replayBtn.isHidden = true
        cell.viewAllBtn.isHidden = true
        cell.viewAlBtnHeightCons.constant = 0
        cell.profileImageLeadingConstraint.constant = 15
    }
    
     func setHeaderImageData(cell: CommentImgCell ) {
        
        let chats = chat
        

        
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
                cell.secondRedDotView.isHidden = true
                cell.likeBtn.isHidden = false
                cell.replayBtn.isHidden = true
                
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
            }
            else if like == 1 {
                cell.showLikeLbl.text = "\(like) like"
            } else {
                cell.showLikeLbl.text = "\(like) likes"
            }
        } else {
            //cell.showLikeLbl.text = "0 like"
            cell.showLikeLbl.text = ""
            cell.grayDotView.isHidden = true
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
        
        cell.grayDotView.isHidden = true
        cell.showLikeLbl.isHidden = true
        cell.frstRedDotView.isHidden = true
        cell.secondRedDotView.isHidden = true
        cell.likeBtn.isHidden = true
        cell.replayBtn.isHidden = true
        cell.viewAllBtn.isHidden = true
        cell.viewAlBtnHeightCons.constant = 0
        cell.profileImageLeadingConstraint.constant = 15
        
        if let id = chats["id"] as? String, id == "-1" || id == "" {
            cell.spinner.startAnimating()
            cell.spinner.isHidden = false
        } else {
            cell.spinner.stopAnimating()
            cell.spinner.isHidden = true
        }
        
        guard let images = chats["images"] as? [AnyObject], images.count > 0 else {
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

           // cell.commentImgView.sd_setImage(with: URL(string: url), placeholderImage: CONTAINERPLACEHOLDER)
            SDWebImageManager.shared().imageDownloader?.downloadImage(with: URL(string: url), options: [], progress: nil, completed: { (image, data, error, succes) in
                
                if self != nil {
                    
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
                }
            })
        }
    }
    
}

//MARK:- WebService extenison
//MARK:-
extension RepliesVC {
    
     func getChannelChat(contentID: String, channelId: String, from: Int, size: Int) {
        
        let url = WS_ChannelChat + "?" + "parentID=\(contentID)&postTime=&previous=false&channels=\(channelId)&from=\(from)&size=\(size)"
        
        print_debug(object: url)
        WebServiceController.getChannelsChat(url: url, parameters: [String : AnyObject]()) { (sucess, errorMessage, data) in
            
            if sucess {
                
                if let chats = data as? [[String: AnyObject]] {
                    
                    print_debug(object: chats)
                    
                    if !chats.isEmpty {
                        
                        self.chatArray.append(contentsOf: chats)
                        self.tblView.reloadData()
                        
                        if self.from == 0 {
                            
                            self.moveChatToBottom()
                        }
                        
                    } else {
                        
                        self.size = 0
                    }
                    self.refreshControl.endRefreshing()
                    
                } else {
                    
                }
            }
            
            print_debug(object: self.chatArray.count)
            print_debug(object: self.chatArray)
            
            
            self.activityIndicator.isHidden = true
            if self.chatArray.count == 0 {
                //self.noDataLbl.isHidden = false
                // self.tblView.isHidden = true
            } else {
                //self.noDataLbl.isHidden = true
                //self.tblView.isHidden = false
            }
            self.refreshControl.endRefreshing()
        }
    }
    
    
     func updateComments(contentID: String, channelId: String) {
        
        let url = WS_ChannelChat + "?" + "parentID=\(contentID)&postTime=&previous=false&channels=\(channelId)&from=\(0)&size=\(10)"
        
        print_debug(object: url)
        WebServiceController.getChannelsChat(url: url, parameters: [String : AnyObject]()) { (sucess, errorMessage, data) in
            if sucess {
                
                if let chats = data as? [[String: AnyObject]] {
                    print_debug(object: chats)
                    
                    if !chats.isEmpty {
                        print_debug(object: chats)
                        
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
                            }
                            
                        }
                        
                        if self.chatArray.count > count {
                            self.tblView.reloadData()
                            self.moveChatToBottom()
                        }
//                        else {
//                            self.tblView.reloadData()
//                        }
                        
                        
                    }
                }
            }
            self.activityIndicator.isHidden = true
            if self.chatArray.count == 0 {
                //self.noDataLbl.isHidden = false
                //self.tblView.isHidden = true
            } else {
                //self.noDataLbl.isHidden = true
                //self.tblView.isHidden = false
            }
        }
    }
    
    func getPreviousChannelChat(contentID: String,channelId: String, from: Int, size: Int, postTime : String) {
        
        let url = WS_ChannelChat + "?" + "parentID=\(contentID)&postTime=\(postTime)&previous=true&channels=\(channelId)&from=\(0)&size=\(size)"
        
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
            
            
            
        }
    }
    
     func sendChat(msg: String, chatId : String) {
        
        guard CommonFunctions.checkLogin() else {
            CommonFunctions.showLoginAlert(vc: self)
            return
        }
        
        print_debug(object: chat)
        guard let parentID = self.chat["id"] else { return }
        guard let channels = self.chat["channels"] as? [String] else { return }
        guard let channelId = channels.first else { return }
        print_debug(object: parentID)
        print_debug(object: channels.first)
        
        var param = [String: AnyObject]()
        param["parentID"]       =  "\(parentID)" as AnyObject
        param["content"]        =  msg as AnyObject
        param["imageIDs"]       =  [] as AnyObject
        param["targetChannels"] =  [channelId] as AnyObject
        param["targetUsers"]    =  [] as AnyObject
        param["fromUser"]       =  [
            "id"        : CurrentUser.userId!,
            "name"      : CurrentUser.name!,
            "avatarID"  : CurrentUser.avatarID!,
            "tagLine"   : "",
            "country"   : CurrentUser.country ?? "",
            "admin"     : CurrentUser.isAdmin ?? false
        ] as AnyObject
        
        print_debug(object: param)
        
        WebServiceController.sendChat(parameters: param) { (sucess, DataHeaderResponse, DataResultResponse) in
            
            if sucess {
                print_debug(object: "Sucess")
                
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
                    self.tblView.reloadData()
                }
            } else {
                print_debug(object: "Faild")
                
                var oldChatIndex = 0
                for oldChat in self.chatArray {
                    if let oldChatId = oldChat["id"] as? String, oldChatId ==  chatId {
                        self.chatArray.remove(at: oldChatIndex)
                        break
                    }
                    oldChatIndex += 1
                    
                }
                self.tblView.reloadData()
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
                self.size = 20 // nitin
                guard let chatid = self.chat["id"] as? String else { return }
                guard let channels = self.chat["channels"] as? [String] else { return }
                guard let channel = channels.first else { return }
                self.getChannelChat(contentID: chatid, channelId: channel, from: self.from, size: self.size)
                self.tblView.reloadData()
                
            } else {
                //CommonFunctions.showAlertWarning(msg: "Detail is not update.")
            }
            
        }
        
    }
}


extension RepliesVC: RepliesVCDelegate {
    
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
