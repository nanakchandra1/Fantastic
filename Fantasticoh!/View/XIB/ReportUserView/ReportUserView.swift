//
//  ReportUserView.swift
//  Fantasticoh!
//
//  Created by Appinventiv on 26/09/17.
//  Copyright © 2017 AppInventiv. All rights reserved.
//

import UIKit

class ReportUserView: UIView {

    @IBOutlet weak var reportTextView: KMPlaceholderTextView!
    
    var userId = ""
    override func awakeFromNib() {
        super.awakeFromNib()
        self.reportTextView.delegate = self
    }
    
    
    class  func configureAddOptionView(_ owner: AnyObject) -> ReportUserView {
        
        let addView = Bundle.main.loadNibNamed("ReportUserView",owner:owner, options:nil)?.first as! ReportUserView
        addView.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT)
        return addView
        
    }
    
    //MARK: Private methods and functions
    
    
    func showReportView() {
        self.reportTextView.text = ""
        self.alpha = 0.0
        self.isHidden = false
        UIView.animate(withDuration: 0.5) {
            self.alpha = 1.0
        }
    }
    
    func HideReportView() {
        UIView.animate(withDuration: 0.5, animations: {
            self.alpha = 0.0
        }) { (complete) in
            self.removeFromSuperview()
        }
    }
    
    @IBAction func reportCloseBtnTap(_ sender: Any) {
        self.HideReportView()
    }
    @IBAction func reportBtnTap(_ sender: Any) {
        reportTextView.resignFirstResponder()
        guard let reportText = self.reportTextView.text else {
            return
        }
        
        if reportText.removeExcessiveSpaces.isEmpty {
            CommonFunctions.showAlertWarning(msg: CommonTexts.Please_Enter_Reason_To_Report)
        } else {
            self.reportUser()
            self.HideReportView()
        }
    }
    
    
    func reportUser() {
        
        
        CommonFunctions.showLoader()
        let url = WS_ReportUser + "\(self.userId)?flag=true"
        
        var params = [String: AnyObject]()
        params["reason"]      = self.reportTextView.text.removeExcessiveSpaces as AnyObject
        
        
        WebServiceController.ReportUser(url: url, parameters: params) { (sucess, msg, DataResultResponse) in
            CommonFunctions.hideLoader()
            if sucess {
                CommonFunctions.showAlertSucess(title: CommonTexts.Success, msg: CommonTexts.Reported_SuccessFully) // nitin
                
            } else {
                //CommonFunctions.showAlertWarning(msg: "Detail is not update.")
            }
            
        }
        
    }
}

extension ReportUserView : UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        
        //        if range.toRange()?.lowerBound == 0 {
        //            self.middleViewHeightCons.constant = 100
        //
        //        } else {
        //            var textHeight: CGFloat = 0
        //            if let text = self.bioDescTextView.text {
        //                textHeight = self.getTextHeightWdith(param: text).height
        //            }
        //            self.bioDescTextView.textContainer.maximumNumberOfLines = 10
        //            self.bioDescTextView.textContainer.lineBreakMode = NSLineBreakMode.byClipping
        //            self.middleViewHeightCons.constant = 90 + textHeight
        //        }
        
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.characters.count
        return numberOfChars < 200
    }
}
