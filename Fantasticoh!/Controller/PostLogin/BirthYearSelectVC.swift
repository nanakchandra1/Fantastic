//
//  BirthYearSelectVC.swift
//  Fantasticoh!
//
//  Created by Appinventiv on 23/08/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import UIKit

class BirthYearSelectVC: UIViewController {
    
    //MARK:- IBOutlet & Propertie's
    //MARK:-
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var okBtn: UIButton!
    
    @IBOutlet weak var skipButton: UIButton!
    var pickerDataSource = [Int]()
    var selectedYear = 0
    weak var delegate: SendDataDelegate?
    
    //MARK:- View Life Cycle
    //MARK:-
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.picker.delegate = self
        self.picker.dataSource = self
        APP_DELEGATE.statusBarStyle = UIStatusBarStyle.default
        self.initialSetup()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK:- IBAction, Selector & Private method's
    //MARK:-
    @IBAction func okBtnTap(sender: UIButton) {
        
        self.delegate?.sendData(text: self.selectedYear)
        self.mz_dismissFormSheetController(animated: true, completionHandler: nil)
    }
    
    @IBAction func skipBtnTap(_ sender: Any) {
        self.mz_dismissFormSheetController(animated: true, completionHandler: nil)
    }
    
    
    private func initialSetup() {
        
        self.titleLbl.text =  CommonTexts.BIRTH_MESSAGE_TEXT
        self.titleLbl.textColor = CommonColors.globalRedColor()
        
        self.okBtn.layer.cornerRadius = 5.0
        self.okBtn.layer.masksToBounds = true
        
        self.picker.layer.cornerRadius = 5.0
        self.picker.layer.masksToBounds = true
        
        self.dateArray()
        
        self.picker.layer.borderWidth = 1.0
        self.picker.layer.borderColor = UIColor(red: 211/245, green: 211/245, blue: 211/245, alpha: 0.7).cgColor
        
        self.picker.selectRow(self.pickerDataSource.count-1, inComponent: 0, animated: false)
        self.selectedYear = self.pickerDataSource[self.pickerDataSource.count-1]
        
    }
    
    private func dateArray() {
        
        let startDate = NSDateComponents()
        startDate.year = 1920
        startDate.month = 9
        startDate.day = 1
        let calendar = NSCalendar.current
        let startDateNSDate = calendar.date(from: startDate as DateComponents)!
        let offsetComponents:NSDateComponents = NSDateComponents();
        offsetComponents.year = 1
        var nd:Date = startDateNSDate ;
        while nd.timeIntervalSince1970 < NSDate().timeIntervalSince1970 {
            nd = calendar.date(byAdding: offsetComponents as DateComponents, to: nd as Date, wrappingComponents: true)!
            let components = calendar.component(.year, from: nd)
            self.pickerDataSource.append(components)
        }
        
        let strtRng = self.pickerDataSource.count-16
        let endRng  = self.pickerDataSource.count-1
        self.pickerDataSource.removeSubrange(strtRng...endRng)
    }
    
}

//MARK:- UIPickerViewDelegate & DataSource Extension
//MARK:-
extension BirthYearSelectVC: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.pickerDataSource.count
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let titleData = "\(self.pickerDataSource[row])"
        let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:CommonFonts.SFUIText_Regular(setsize: 11),NSForegroundColorAttributeName:UIColor.black])
        return myTitle
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectedYear = self.pickerDataSource[row]
    }
}


