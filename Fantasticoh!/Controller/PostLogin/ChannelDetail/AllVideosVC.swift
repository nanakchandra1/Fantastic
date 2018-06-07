//
//  AllVideosVC.swift
//  Fantasticoh!
//
//  Created by Arvind Rawat on 05/02/18.
//  Copyright © 2018 AppInventiv. All rights reserved.
//

import UIKit
import SwiftyJSON

class AllVideosVC: UIViewController {
    
    @IBOutlet weak var navigationTitle: UILabel!
    @IBOutlet weak var videosTableView: UITableView!
    
    @IBOutlet weak var backButton: UIButton!
    var channelId:String = ""
    var includeNonGraphBeeps:String = ""
    var tagsDisplay:String = ""
    var avtarUrl:String = ""
    var hashTags = [String]()
    var allVideos = [SeeAllPhotosAndVideos]()
    var beepDimention = [CGFloat]()
    var from:Int = 0
    var nextCount = 1
    var channelName = ""
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: .white)
    
    
    @IBAction func backBtn(_ sender: UIButton) {
        
        self.navigationController?.popViewController(animated: true)
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationTitle.text = tagsDisplay
        self.backButton.setImage(#imageLiteral(resourceName: "nav_back"), for: .normal)
        getSeeAllData()
        self.videosTableView.delegate   = self
        self.videosTableView.dataSource = self
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
                        self.allVideos.append(SeeAllPhotosAndVideos(data:JSON(data)))
                    }
                }
                self.videosTableView.reloadData()
            }
        }
    }
}


class VideoCell:UITableViewCell{
    
    
    @IBOutlet weak var imageContainerView: UIView!
    @IBOutlet weak var videoImageView: UIImageView!
    @IBOutlet weak var tapView: UIView!
    @IBOutlet weak var channelImageView: UIView!
    @IBOutlet weak var channelName: UILabel!
    @IBOutlet weak var timeStamp: UIImageView!
    @IBOutlet weak var postTimeStampLabel: UILabel!
    @IBOutlet weak var channelSource: UIImageView!
    @IBOutlet weak var titleDataLabel: UILabel!
    @IBOutlet weak var ChannelImage: UIImageView!
    
}

extension AllVideosVC:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allVideos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = videosTableView.dequeueReusableCell(withIdentifier: "VideoCell", for: indexPath) as? VideoCell else{
            
            fatalError("fattal error in AllVideoVC")
        }
        cell.videoImageView.contentMode = .center

         let imgUrl =  allVideos[indexPath.row].image2x
            
            cell.videoImageView.sd_setImage(with: URL(string: imgUrl), placeholderImage: CHANNELLOGOPLACEHOLDER, options: SDWebImageOptions(rawValue: 1), completed: { (image, error, type, url) in
                
                if error != nil{
                    cell.videoImageView.contentMode = .center
                    
                }else{
                    cell.videoImageView.contentMode = .scaleAspectFill
                    
                }

            })
            
        
        cell.ChannelImage.contentMode = .center

        cell.ChannelImage.sd_setImage(with: URL(string: avtarUrl), placeholderImage: CHANNELLOGOPLACEHOLDER, options: SDWebImageOptions(rawValue: 1), completed: { (image, error, type, url) in
            
            if error != nil{
                cell.ChannelImage.contentMode = .center
                
            }else{
                cell.ChannelImage.contentMode = .scaleAspectFill
                
            }
        })

        cell.ChannelImage.sd_setImage(with: URL(string: avtarUrl), placeholderImage: CHANNELLOGOPLACEHOLDER)
        cell.ChannelImage.layer.cornerRadius = cell.ChannelImage.frame.size.width/2
        cell.ChannelImage.clipsToBounds = true
        cell.postTimeStampLabel.text = allVideos[indexPath.row].postTimeDisplay
        // cell.channelName.text = allVideos[indexPath.row].
        cell.postTimeStampLabel.text = allVideos[indexPath.row].postTimeDisplay
        cell.channelName.text = self.channelName
        cell.titleDataLabel.text =  allVideos[indexPath.row].title
        
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let img2xH =  allVideos[indexPath.row].imageHeight
        let img2xW =  allVideos[indexPath.row].imageWeight
        let ratio = (CGFloat(img2xH)/CGFloat(img2xW)) * SCREEN_WIDTH
        
        if ratio <= 10 {
            return 180 + 72
        } else {
            
            if ratio.isNaN {
                return 180 + 132
            } else {
                return  ratio  + 132
            }
            
        }
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if self.allVideos.count-1 == indexPath.row {
            self.from = self.from+10
            
            if self.nextCount != 0 {
                self.spinner.startAnimating()
                self.getSeeAllData()
            } else {
                
                self.spinner.stopAnimating()
            }
            
            
        }
        
        cell.clipsToBounds = true
        cell.contentView.layoutIfNeeded()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier:"BeepDetailVC") as! BeepDetailVC
        vc.beepVCState = BeepVCState.AllTagVCState
        /* vc.allTagVCDelegate = self
         if let dele = self.delegate {
         vc.delegate = dele
         } else  {
         vc.delegate = TABBARDELEGATE
         }
         */
        
        //  if let dele = self.delegate {
        //       vc.tabBarDelegate = dele
        //   }
        //    vc.delegte = self
        //vc.tagHeight = self.tagHeight(row)
        vc.hasTags = self.hashTags
        //vc.isNotBeepDetail = false
        vc.beepData =  self.allVideos[indexPath.row]
        vc.from = indexPath.row
        // self.currentRow = indexPath.row
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
