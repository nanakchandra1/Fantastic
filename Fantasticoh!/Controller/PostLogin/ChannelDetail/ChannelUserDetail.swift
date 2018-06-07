//
//  ChannelUserDetail.swift
//  Fantasticoh!
//
//  Created by Arvind Rawat on 02/02/18.
//  Copyright © 2018 AppInventiv. All rights reserved.
//

import UIKit
import SafariServices

class ChannelUserDetail: UIViewController {


    
    @IBOutlet weak var detailTableView: UITableView!
    
    var channelData:ChannelUserData?
    var channelID:String = ""
    var name = ["Birthday","Born","Nationality","Height","Net Worth","Marital Status"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.detailTableView.delegate   = self
        self.detailTableView.dataSource = self
        //self.removeBlankData()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidLayoutSubviews() {
        detailTableView.frame = CGRect(x: detailTableView.frame.origin.x, y: detailTableView.frame.origin.y, width: detailTableView.frame.size.width, height: 280)
        detailTableView.reloadData()
    }
    
    
    @objc func profileBtnTapped(sender:UIButton){
        

        if #available(iOS 9.0, *) {
       
            if let strUrl = URL(string: WS_FullProfile + channelID){
                
                let safariVC = SFSafariViewController(url: strUrl)
                self.present(safariVC, animated: true, completion: {
                    APP_DELEGATE.statusBarStyle = .default
                })
            }
            
        } else {
            let webViewVC = self.storyboard?.instantiateViewController(withIdentifier:"WebViewVC") as! WebViewVC
            webViewVC.urlString = "\(WS_FullProfile)\(channelID)"
            self.present(webViewVC, animated: true, completion: {
                APP_DELEGATE.statusBarStyle = .default
            })
        }
    }
   
}

class DetailCell:UITableViewCell{
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    
    
    func populateData(indexPath:IndexPath,data:ChannelUserData?){
        
        switch indexPath.row {
        case 0:
        
            if let text = data?.birth, !text.isEmpty{
                if let day = data?.ageInYears, !day.isEmpty{
                     detailLabel.text = text + " (age \(day))"
                }
            }else{
                detailLabel.text = "No Detail"
            }
        case 1:
             checkEmpty(text: (data?.born) ?? "")
           
        case 2:
            checkEmpty(text: (data?.nationality) ?? "")
        case 3:
            checkEmpty(text: (data?.height) ?? "")
            
        case 4:
            checkEmpty(text: (data?.netWorth) ?? "")
          
        case 5:
            checkEmpty(text: (data?.married) ?? "")
            
        case 6:
            checkEmpty(text: (data?.brand) ?? "")
            
        default:
            detailLabel.text = "No Detail"
        }
    }
    
    func checkEmpty(text:String){
        
        if !text.isEmpty{
            detailLabel.text = text
        }else{
            detailLabel.text = "No Detail"
        }
        
    }
}

class DetailCell2: UITableViewCell {

    @IBOutlet weak var fullProfileBtn: UIButton!
    @IBOutlet weak var fullProfileButtonTitleLabel: UILabel!
    
}

extension ChannelUserDetail:UITableViewDelegate,UITableViewDataSource{
    
    func forSetAttributedTex(text: String) -> NSMutableAttributedString {

         let myMutableString = NSMutableAttributedString(string: "Full Profile\n", attributes: [NSFontAttributeName: CommonFonts.SFUIText_Semibold(setsize: 16.0)])

        let myMutableString1 = NSAttributedString(string: "Background, trivia & much more..", attributes: [NSFontAttributeName: CommonFonts.SFUIText_Semibold(setsize: 14.0)])
        
        myMutableString.append(myMutableString1)
        return myMutableString
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return name.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == (name.count){
            guard let cell  = detailTableView.dequeueReusableCell(withIdentifier: "DetailCell2", for: indexPath) as? DetailCell2  else{
                fatalError("Error in finding the cell")
                
            }
            
            cell.fullProfileButtonTitleLabel.textColor = #colorLiteral(red: 1, green: 0, blue: 0.1025861391, alpha: 1)
            
            let text = self.forSetAttributedTex(text: "Full Profile \n Background, trivia & much more..")
            cell.fullProfileButtonTitleLabel.attributedText = text
            cell.fullProfileButtonTitleLabel.isUserInteractionEnabled = false
            cell.fullProfileBtn.addTarget(self, action: #selector(profileBtnTapped), for: .touchUpInside)
            return cell
        
        }else{
        
        guard let cell  = detailTableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath) as? DetailCell  else{
            fatalError("Error in finding the cell")
            
        }
      
        cell.nameLabel.textColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        cell.detailLabel.textColor = #colorLiteral(red: 0.1990042781, green: 0.2154662807, blue: 0.2393814814, alpha: 1)
//        cell.detailLabel.font   = UIFont.systemFont(ofSize: 15, weight: 20)
        cell.nameLabel.text     =  name[indexPath.row]
        cell.populateData(indexPath: indexPath, data: (channelData)!)
            
        return cell
    }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        switch indexPath.row{
        case 0:
            guard let text = channelData?.birth, !text.isEmpty else{

                NotificationCenter.default.post(name: NSNotification.Name("setHeightNotification"), object: nil, userInfo: ["key":0])
               return 0
            }

        case 1:
            guard let text = channelData?.born, !text.isEmpty else{
                NotificationCenter.default.post(name: NSNotification.Name("setHeightNotification"), object: nil, userInfo: ["key":1])

                return 0
            }

        case 2:
            guard let text = channelData?.nationality, !text.isEmpty else{
                NotificationCenter.default.post(name: NSNotification.Name("setHeightNotification"), object: nil, userInfo: ["key":2])

                return 0
            }

        case 3:
            guard let text = channelData?.height, !text.isEmpty else{
                NotificationCenter.default.post(name: NSNotification.Name("setHeightNotification"), object: nil, userInfo: ["key":3])

                return 0
            }
            if text == "0"{
                return 0
            }

        case 4:
            guard let text = channelData?.netWorth, !text.isEmpty else{
                NotificationCenter.default.post(name: NSNotification.Name("setHeightNotification"), object: nil, userInfo: ["key":4])

                return 0
            }

        case 5:
            guard let text = channelData?.married, !text.isEmpty else{
                NotificationCenter.default.post(name: NSNotification.Name("setHeightNotification"), object: nil, userInfo: ["key":5])

                return 0
                
            }

        default:
            return 43
        }
        return 30
    }
    
}

