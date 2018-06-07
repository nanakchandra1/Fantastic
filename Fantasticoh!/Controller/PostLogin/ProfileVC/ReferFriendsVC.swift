//
//  ReferFriendsVC.swift
//  Fantasticoh!
//
//  Created by Appinventiv on 12/09/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import UIKit
import QuartzCore


class ReferFriendsVC: UIViewController {
    
    //MARK:- @IBOutlet & Propertie's
    //MARK:-
    @IBOutlet weak var topLbl: UILabel!
    @IBOutlet weak var middleLbl: UILabel!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var referralCodeContainer: UIView!
    @IBOutlet weak var referralCodeLbl: UILabel!
    
    //MARK:- View Life Cycle
    //MARK:-
    override func viewDidLoad() {
        super.viewDidLoad()

        self.referralCodeContainer.backgroundColor = UIColor.clear
        self.shareBtn.layer.cornerRadius = 5.0
        self.shareBtn.layer.masksToBounds = true
        
        self.topLbl.text = "Share your referral code with \nfriends and get them on board \n with fantasticoh! \n community"
        
        if let code = CurrentUser.viaCode {
            if !code.isEmpty {
                self.referralCodeLbl.text = code
                self.shareBtn.isUserInteractionEnabled = true
            } else {
                self.referralCodeLbl.text = ""
                self.shareBtn.isUserInteractionEnabled = false
            }
        } else {
            self.referralCodeLbl.text = ""
            self.shareBtn.isUserInteractionEnabled = false
        }
        
        //self.drawRect(self.randomabBtn.layer.contentsRect)
    }
    
    override func viewDidLayoutSubviews() {
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        let shapeLayer:CAShapeLayer = CAShapeLayer()
        let frameSize = referralCodeContainer.frame.size
        let shapeRect = CGRect(x: 0, y: 0, width: frameSize.width, height: frameSize.height)
        shapeLayer.bounds = shapeRect
        shapeLayer.position = CGPoint(x: frameSize.width/2, y: frameSize.height/2)
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = CommonColors.refferalCodeBorderColor().cgColor
        shapeLayer.lineWidth = 0.3
        shapeLayer.lineJoin = kCALineJoinRound
        shapeLayer.lineDashPattern = [5,2,5,2]
        shapeLayer.path = UIBezierPath(roundedRect: shapeRect, cornerRadius: 5.0).cgPath
        self.referralCodeContainer.layer.addSublayer(shapeLayer)
        
        CATransaction.commit()
        
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
    
    @IBAction func randomabBtnTap(sender: UIButton) {
    }
    
    @IBAction func shareBtnTap(sender: UIButton) {
        
        if let txt  = self.referralCodeLbl.text {
            self.displayShareSheet(shareContent: txt)
        } else {
            self.displayShareSheet(shareContent: "")
        }
        
    }
    
    private func displayShareSheet(shareContent: String) {
        
        let activityVC = UIActivityViewController(activityItems: [shareContent as NSString], applicationActivities: nil)
        
        activityVC.completionWithItemsHandler = { activity, success, items, error in
            
            if !success{
                print("cancelled")
                return
            } else {
                print_debug(object: shareContent)
                
            }
            
            if activity == UIActivityType.copyToPasteboard {
                print("copy")
            }
            
            if activity == UIActivityType.postToTwitter {
                print("twitter")
            }
            
            if activity == UIActivityType.mail {
                print("mail")
            }
            
        }
        present(activityVC, animated: true) {
            
            print("compleatsef")
        }
        
    }
    
    
}
