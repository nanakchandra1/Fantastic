//
//  UnderDevelopmentVC.swift
//  Fantasticoh!
//
//  Created by Shubham on 8/4/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import UIKit

class UnderDevelopmentVC: UIViewController {
    
    //MARK:- @IBOutlet & Properties
    //MARK:-
    @IBOutlet weak var tableView: UITableView!
    
    //MARK:- View Life Cycle
    //MARK:-
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.hidden = true
        let userDataCell = UINib(nibName: "FanCellXIB", bundle: nil)
        self.tableView.registerNib(userDataCell, forCellReuseIdentifier: "FanCellXIB")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK:- @IBAction, Selector & Private method's
    //MARK:-
    func fanBtnTap(sender: UIButton) {
        
        if !sender.selected {
            print_debug("oN")
            CommonFunctions.fanBtnOnFormatting(sender)
        } else {
            print_debug("oFF")
            CommonFunctions.fanBtnOffFormatting(sender)
        }
        
        sender.selected = !sender.selected
    }
    
}

//MARK:- UITableViewDelegate & DataSource
//MARK:-
extension UnderDevelopmentVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 65
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("FanCellXIB", forIndexPath: indexPath) as! FanCellXIB
        cell.grayDot.hidden = true
        cell.secondCounterLbl.hidden = true
        cell.redDot.hidden = true
        
        //cell.btn.addTarget(self, action: #selector(UnderDevelopmentVC.fanBtnTap(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        cell.btn.addTarget(self, action: #selector(UnderDevelopmentVC.fanBtnTap(_:)), forControlEvents: .TouchUpInside)
        
        return cell
    }
    
}
