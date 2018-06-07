//
//  BeepChatVC.swift
//  Fantasticoh!
//
//  Created by Appinventiv on 12/10/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import UIKit
import Accelerate
import Photos

class BeepCommentVC: UIViewController {

    //MARK:- IBOutlet & Propertie's
    //MARK:-
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var bottomCons: NSLayoutConstraint!
    @IBOutlet weak var bgView: UIView!

    @IBOutlet weak var noOfLikeBtn: UIButton!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var cameraBtn: UIButton!

    let picker : UIImagePickerController = UIImagePickerController()
    var cameraBtnState = CameraBtnState.None
    var likes = 0
    var beepId = ""
    
    //MARK:- View Life cycle
    //MARK:-
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.tblView.delegate = self
        //self.tblView.dataSource = self
        self.commentTextView.delegate = self
        self.initSetup()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(NSNotification.Name.UIKeyboardWillShow)
        NotificationCenter.default.removeObserver(NSNotification.Name.UIKeyboardWillHide)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        CommonFunctions.hideKeyboard()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- IBAction, Selector & Private Method
    //MARK:-
    
     func initSetup() {
    
        self.tblView.estimatedRowHeight = 50.0
        self.tblView.rowHeight = UITableViewAutomaticDimension
        
        self.bgView.layer.cornerRadius = 12.0
        self.bgView.layer.masksToBounds = true
        self.bgView.clipsToBounds = true
        
        self.commentTextView.layer.cornerRadius = 5.0
        self.commentTextView.layer.masksToBounds = true
        
        self.commentTextView.layer.borderWidth = 0.5
        self.commentTextView.layer.borderColor = CommonColors.lightGrayColor().cgColor
        
        //self.commentTextView.becomeFirstResponder()
        
        self.cameraBtnState = CameraBtnState.Camera
        var like = ""
        if self.likes > 1 {
            like = "\( self.likes ) Likes"
        } else {
            like = "\( self.likes ) Like"
        }
        self.noOfLikeBtn.setTitle(like, for:  .normal)
        
        let commentImgCell = UINib(nibName: "CommentImgCell", bundle: nil)
        self.tblView.register(commentImgCell, forCellReuseIdentifier: "CommentImgCell")
        
        let commentTxtCell = UINib(nibName: "CommentTxtCell", bundle: nil)
        self.tblView.register(commentTxtCell, forCellReuseIdentifier: "CommentTxtCell")
        
        NotificationCenter.default.addObserver(self, selector: #selector(BeepCommentVC.keyboardShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(BeepCommentVC.keyboardHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            self.bottomCons.constant = keyboardSize.height
        }
    }
    
    func keyboardHide(notification: NSNotification) {
        self.bottomCons.constant = 0
    }
    
    
    @IBAction func noOfLikeBtnTap(sender: UIButton) {
        
        
        if self.likes > 0 {
            let vc = self.storyboard?.instantiateViewController(withIdentifier:"BeepCommentLikesVC") as! BeepCommentLikesVC
            vc.beepId = self.beepId
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    @IBAction func nextBtnTap(sender: UIButton) {
        self.commentTextView.resignFirstResponder()
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func galleryBtnTap(sender: UIButton) {
        self.checkAndOpenLibrary(forTypes: ["\(kUTTypeImage)"])
    }

    @IBAction func cameraBtnTap(sender: UIButton) {
        if self.cameraBtnState == CameraBtnState.Camera {
            self.checkAndOpenCamera(forTypes: ["\(kUTTypeImage)"])
        } else  {
            self.commentTextView.resignFirstResponder()
            //self.commentTextArray.append(self.commentTextView.text)
            self.commentTextView.text = ""
            self.cameraBtnState = .Camera
            self.cameraBtn.setTitle("", for:  .normal)
            self.cameraBtn.setImage(UIImage(named: "comment_capture"), for:  .normal)
            self.tblView.reloadData()
        }
    }
    
    
}

//MARK:- UITextViewDelegate
//MARK:-
extension BeepCommentVC: UITextViewDelegate {
    
    //MARK:- UITextView Delgate
    //MARK:-
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.characters.count > 0 {
            self.cameraBtnState = .Send
            self.cameraBtn.setImage(UIImage(), for:  .normal)
            self.cameraBtn.setTitle("SEND", for:  .normal)
        } else {
            self.cameraBtnState = .Camera
            self.cameraBtn.setTitle("", for:  .normal)
            self.cameraBtn.setImage(UIImage(named: "comment_capture"), for:  .normal)
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.characters.count > 0 {
            self.cameraBtnState = .Send
            self.cameraBtn.setImage(UIImage(), for:  .normal)
            self.cameraBtn.setTitle("SEND", for:  .normal)
        } else {
            self.cameraBtnState = .Camera
            self.cameraBtn.setTitle("", for:  .normal)
            self.cameraBtn.setImage(UIImage(named: "comment_capture"), for:  .normal)
        }
    }
}


//MARK:- UIImagePickerController & UINavigationController Delegate
//MARK:-
extension BeepCommentVC :  UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
     func checkAndOpenLibrary(forTypes: [String]) {
        
        self.picker.delegate = self
        
        self.picker.mediaTypes = forTypes
        
        let status: PHAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        
        if (status == .notDetermined) {
            
            let sourceType: UIImagePickerControllerSourceType = UIImagePickerControllerSourceType.photoLibrary
            
            self.picker.sourceType = sourceType
            
            self.navigationController!.present(self.picker, animated: true, completion: nil)
            
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
                    
                    print_debug(object: image)
                    
                    //self.profileImageView.image = image
                    
                    
                    
                    //self.uploadProfilePic(image)
                    
                }
                
            })
            
        } else {
            
            print_debug(object: "Data not found.")
            
        }
        
    }
    
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        self.picker.dismiss(animated: true, completion: nil)
        
    }
    
    
    
}

