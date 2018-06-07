//
//  Extension.swift
//  Fantasticoh!
//
//  Created by Shubham on 7/28/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import Foundation
import UIKit
import AVKit

//MARK: extension for table TableView
extension UIView {
    
    func tableViewCell() -> UITableViewCell? {
        
        var tableViewcell : UIView? = self
        
        while(tableViewcell != nil) {
            
            if tableViewcell! is UITableViewCell {
                break
            }
            tableViewcell = tableViewcell!.superview
        }
        return tableViewcell as? UITableViewCell
    }
    
    func tableViewIndexPath(tableView: UITableView) -> IndexPath? {
        
        if let cell = self.tableViewCell() {
            return tableView.indexPath(for: cell)
        }
        return nil
    }
    
    func collectionViewCell() -> UICollectionViewCell? {
        
        var collectionViewcell : UIView? = self
        
        while(collectionViewcell != nil) {
            
            if collectionViewcell! is UICollectionViewCell {
                break
            }
            collectionViewcell = collectionViewcell!.superview
        }
        return collectionViewcell as? UICollectionViewCell
    }
    
    func collectionViewIndexPath(collectionView: UICollectionView) -> IndexPath? {
        
        if let cell = self.collectionViewCell() {
            return collectionView.indexPath(for: cell)
        }
        return nil
    }
}


extension AVPlayerViewController {
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIDevice.current.setValue(UIInterfaceOrientationMask.portrait.rawValue, forKey: "orientation")
    }
}
