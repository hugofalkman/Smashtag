//
//  ImageCollectionViewCell.swift
//  Smashtag
//
//  Created by H Hugo Falkman on 2015-03-27.
//  Copyright (c) 2015 H Hugo Fakman. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var imageUrl: NSURL? {
        didSet {updateUI()}
    }
    var tweet: Tweet!
    var cache: NSCache!
    
    private func updateUI() {
        if let url = imageUrl {
            if let cachedImage = cache.objectForKey(self.imageUrl!) as? UIImage {
                imageView.image = cachedImage
                return
            }
            spinner?.startAnimating()
            let qos = Int(QOS_CLASS_USER_INITIATED.value)
            dispatch_async(dispatch_get_global_queue(qos, 0)) { () -> Void in
                let imageData = NSData(contentsOfURL: url)
                dispatch_async(dispatch_get_main_queue()) {
                    if url == self.imageUrl {
                        if imageData != nil {
                            if let fetchedImage = UIImage(data: imageData!) {
                                self.imageView?.image = fetchedImage
                                self.cache.setObject(fetchedImage, forKey: self.imageUrl!, cost: Int(fetchedImage.size.width * fetchedImage.size.height / 1024))
                            } else {self.imageView?.image = nil}
                        } else {self.imageView?.image = nil}
                        self.spinner?.stopAnimating()
                    }
                }
            }
        }
    }

    
}
