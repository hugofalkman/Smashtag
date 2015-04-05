//
//  TweetTableViewCell.swift
//  Smashtag
//
//  Created by H Hugo Falkman on 2015-03-09.
//  Copyright (c) 2015 H Hugo Fakman. All rights reserved.
//

import UIKit

class TweetTableViewCell: UITableViewCell {
    
    var tweet: Tweet? {
        didSet {
            tweetMentionsCount = (tweet?.hashtags.count ?? 0) + (tweet?.urls.count ?? 0) + (tweet?.userMentions.count ?? 0) + (tweet?.media.count ?? 0)
            updateUI()
        }
    }
    var tweetMentionsCount = 0

    @IBOutlet weak var tweetProfileImageView: UIImageView!
    @IBOutlet weak var tweetScreenNameLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    @IBOutlet weak var tweetCreatedLabel: UILabel!
    
    private struct Constants {
        static let hashtagColor = UIColor.purpleColor()
        static let urlColor = UIColor.blueColor()
        static let userColor = UIColor.orangeColor()
    }
    
    private func updateUI() {
        
        // reset any existing tweet information
        tweetTextLabel?.attributedText = nil
        tweetScreenNameLabel?.text = nil
        tweetProfileImageView?.image = nil
        tweetCreatedLabel?.text = nil
        
        // load new information from our tweet (if any)
        if let tweet = self.tweet{
            tweetTextLabel?.attributedText = setTextLabel(tweet)
            tweetScreenNameLabel?.text = "\(tweet.user)" // tweet.user.description
            setProfileImageView(tweet) // tweetProfileImageView updated asynchronously
            tweetCreatedLabel?.text = setCreatedLabel(tweet)
            
            // set disclosure indicator
            setAccessoryType()
        }
    }
    
    func setAccessoryType() {
        if tweetMentionsCount > 0 {
            accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        } else {
            accessoryType = UITableViewCellAccessoryType.None
        }
    }
    
    private func setTextLabel(tweet: Tweet) -> NSMutableAttributedString {
        var tweetText = tweet.text
        for _ in tweet.media {tweetText += " 📷"}
        var attribText = NSMutableAttributedString(string: tweetText)
        
        // help function to color keywords
        func setColor(keywords: [Tweet.IndexedKeyword], color: UIColor) {
            for keyword in keywords {
                attribText.addAttribute(NSForegroundColorAttributeName,value: color, range: keyword.nsrange)
            }
        }
        setColor(tweet.hashtags, Constants.hashtagColor)
        setColor(tweet.urls, Constants.urlColor)
        setColor(tweet.userMentions, Constants.userColor)
        return attribText
    }
    
    private func setProfileImageView(tweet: Tweet) {
        if let profileImageURL = tweet.user.profileImageURL {
            let qos = Int(QOS_CLASS_USER_INITIATED.value)
            dispatch_async(dispatch_get_global_queue(qos, 0)) { () -> Void in
                let imageData = NSData(contentsOfURL: profileImageURL)
                dispatch_async(dispatch_get_main_queue()) {
                    if profileImageURL == tweet.user.profileImageURL {
                        if imageData != nil {
                            self.tweetProfileImageView?.image = UIImage(data: imageData!)
                        } else {
                            self.tweetProfileImageView?.image = nil
                        }
                    }
                }
            }
        }
    }
    
    private func setCreatedLabel(tweet: Tweet) -> String {
        let formatter = NSDateFormatter()
        formatter.locale = NSLocale(localeIdentifier: "en_US")
        if NSDate().timeIntervalSinceDate(tweet.created) > 24*60*60 {
            formatter.dateStyle = NSDateFormatterStyle.ShortStyle
        } else {
            formatter.timeStyle = NSDateFormatterStyle.ShortStyle
        }
        return formatter.stringFromDate(tweet.created)
    }
}





