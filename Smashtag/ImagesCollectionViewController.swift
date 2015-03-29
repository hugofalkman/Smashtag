//
//  ImagesCollectionViewController.swift
//  Smashtag
//
//  Created by H Hugo Falkman on 2015-03-26.
//  Copyright (c) 2015 H Hugo Fakman. All rights reserved.
//

import UIKit

class ImagesCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout
{
    private struct Constants {
        static let cellReuseIdentifier = "Image"
        static let sectionInsets = UIEdgeInsets(top: 50, left: 20, bottom: 50, right: 20)
        static let blackBorderWidth = CGFloat(10.0)
        static let tweetSequeIdentifier = "showTweetFromImage"
    }

    var allMedia = [[MediaItem]]()
    var allTweets = [[Tweet]]()
    
    private var cache = NSCache()
    
    private var cellAreaSize = CGSize(width: 100.0, height: 100.0)
    private var pinchScale: CGFloat = 100.0 {
        didSet {
            cellAreaSize.height = pinchScale
            cellAreaSize.width = pinchScale
            collectionView?.collectionViewLayout.invalidateLayout()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: "scale:"))
    }
    func scale(gesture:UIPinchGestureRecognizer) {
        if gesture.state == .Changed {
            pinchScale *= gesture.scale
            gesture.scale = 1
        }
    }
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        super.willRotateToInterfaceOrientation(toInterfaceOrientation, duration: duration)
        collectionView?.collectionViewLayout.invalidateLayout()
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        
        return allMedia.count
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return allMedia[section].count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(Constants.cellReuseIdentifier, forIndexPath: indexPath) as ImageCollectionViewCell
        
        cell.backgroundColor = UIColor.blackColor()
        cell.cache = cache
        let mediaItem = allMedia[indexPath.section][indexPath.row]
        cell.imageUrl = mediaItem.url
        cell.tweet = allTweets[indexPath.section][indexPath.row]
        
        return cell
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let mediaItem = allMedia[indexPath.section][indexPath.row]
        let maxCellWidth = collectionView.bounds.size.width - Constants.sectionInsets.left - Constants.sectionInsets.right
        var size = cellAreaSize
        let aR = CGFloat(mediaItem.aspectRatio)
        if aR > 1 {
            size.height /= aR
        } else {
            size.width *= aR
        }
        size.width += Constants.blackBorderWidth
        size.height += Constants.blackBorderWidth
        if size.width > maxCellWidth {
            size.width = maxCellWidth
            size.height = Constants.blackBorderWidth + (size.width - Constants.blackBorderWidth) / aR
        }
        return size
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return Constants.sectionInsets
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Constants.tweetSequeIdentifier {
            if let ttvc = segue.destinationViewController as? TweetTableViewController {
                if let cell = sender as? ImageCollectionViewCell {
                    ttvc.tweets = [[cell.tweet]]
                }
            }
        }
    }

}
