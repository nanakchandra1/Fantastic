//
//  AllPhotosVC.swift
//  Fantasticoh!
//
//  Created by Arvind Rawat on 05/02/18.
//  Copyright © 2018 AppInventiv. All rights reserved.
//

import UIKit
import SwiftyJSON

class AllPhotosVC: UIViewController {
    
    @IBOutlet weak var allPhotosTableView: UITableView!
    @IBOutlet weak var naviagtionTitle: UILabel!
    
    @IBOutlet weak var backButton: UIButton!
    var channelId:String = ""
    var includeNonGraphBeeps:String = ""
    var tagsDisplay:String = ""
    var name:String = ""
    var channelRequest:Bool = false
    var hashTags = [String]()
    var allPhotos = [SeeAllPhotosAndVideos]()
    var beepDimention = [CGFloat]()
    var from:Int = 0
    var nextCount = 1
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: .white)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CommonFunctions.showLoader()
        self.spinner.color = CommonColors.globalRedColor()
        self.spinner.startAnimating()
        self.spinner.frame = CGRect(x:0,y: 0,width: SCREEN_WIDTH,height: 28)
        self.allPhotosTableView.tableFooterView = spinner

        FB_AD = false // for activating the ads
        self.backButton.setImage(#imageLiteral(resourceName: "nav_back"), for: .normal)
        naviagtionTitle.text            = "\(tagsDisplay)"
        allPhotosTableView.delegate     = self
        allPhotosTableView.dataSource   = self
        self.getSeeAllData()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func backBtn(_ sender: UIButton) {
        
        self.navigationController?.popViewController(animated: true)
        
    }
    
    func getSeeAllData(){
        
        //Arvind Rawat
        //=============
        
        var param = [String : AnyObject]()
        param["channels"]  = channelId as AnyObject
        param["hashtags"]  =  self.hashTags as AnyObject
        param["from"]  = from as AnyObject
        param["size"]  = 10 as AnyObject
        param["includeNonGraphBeeps"]  = self.includeNonGraphBeeps as AnyObject
        
        
        WebServiceController.seeAllChannelPhotosAndVideos(parameters: param) { (sucess, msg, DataResultResponse) in
            
            if sucess {
                
                if let response = DataResultResponse{
                    
                    if response.count < 10 || response.count == 0 {
                        self.nextCount = 0
                        self.spinner.stopAnimating()
                    }
                self.spinner.stopAnimating()
                    
                    for data in response{
                        self.allPhotos.append(SeeAllPhotosAndVideos(data:JSON(data)))
                    }
                }
                
                self.channelRequest = true
                self.allPhotosTableView.reloadData()
                CommonFunctions.hideLoader()
            }
        }
    }
}


extension AllPhotosVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if allPhotos.count == 0{
            return 0
        }
        return  allPhotos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = allPhotosTableView.dequeueReusableCell(withIdentifier: "photoCell", for: indexPath) as? photoCell else{
            
            fatalError("Error in All photos cell")
        }
        
        let imgUrl =  allPhotos[indexPath.row].image2x
        cell.PhotoImageView.contentMode = .center

        if let url =  URL(string: imgUrl) {
            cell.PhotoImageView.sd_setImage(with: url, placeholderImage: CHANNELLOGOPLACEHOLDER, options: SDWebImageOptions(rawValue: 1), completed: { (image, error, type, url) in
                if error != nil{
                    cell.PhotoImageView.contentMode = .center
                    
                }else{
                    cell.PhotoImageView.contentMode = .scaleAspectFill
                    
                }
            })
//            cell.PhotoImageView.sd_setImage(with: url, placeholderImage: CHANNELLOGOPLACEHOLDER)
            
        }else{
            cell.PhotoImageView.contentMode = .center
        }
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let img2xH =  allPhotos[indexPath.row].imageHeight
        let img2xW =  allPhotos[indexPath.row].imageWeight
        let ratio = (CGFloat(img2xH)/CGFloat(img2xW)) * SCREEN_WIDTH
        
        if ratio <= 10 {
            
            return 180
            
        } else {
            
            if ratio.isNaN {
                
                return 180
                
            } else {
                
                return  ratio
                
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier:"BeepDetailVC") as! BeepDetailVC
        
        vc.beepVCState = BeepVCState.AllTagVCState
        
        /*
         vc.allTagVCDelegate = self
         if let dele = self.delegate {
         vc.delegate = dele
         } else  {
         vc.delegate = TABBARDELEGATE
         }
         */
        
        //  if let dele = self.delegate {
        //       vc.tabBarDelegate = dele
        //   }
        
        //  vc.delegte = self
        //vc.tagHeight = self.tagHeight(row)
        //vc.isNotBeepDetail = false
        
        vc.hasTags = self.hashTags
        vc.beepData =  self.allPhotos[indexPath.row]
        vc.from = indexPath.row
        
        //self.currentRow = indexPath.row
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        spinner.stopAnimating()

        if self.allPhotos.count-1 == indexPath.row {
            self.from = self.from+10
            
            if self.nextCount != 0 {
                self.spinner.startAnimating()
                self.getSeeAllData()
            } else {
                
                self.spinner.stopAnimating()
            }
        }
        cell.contentView.layoutIfNeeded()
        cell.clipsToBounds = true

    }
}


class photoCell:UITableViewCell{
    
    @IBOutlet weak var PhotoImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        self.PhotoImageView.contentMode = .scaleToFill

    }
}
