//
//  TweetTableViewController.swift
//  Smashtag
//
//  Created by H Hugo Falkman on 2015-03-09.
//  Copyright (c) 2015 H Hugo Fakman. All rights reserved.
//

import UIKit

class TweetTableViewController: UITableViewController, UITextFieldDelegate {
    
    var tweets: [[Tweet]] = [[Tweet]]()
    
    var history = SearchHistory()
    
    var searchText: String? {
        didSet {
            if oldValue != searchText {
            lastSuccessfulRequest = nil
            searchTextField?.text = searchText
            // add search to NSUserDefaults
            if let text = searchText {
            history.addSearch(text)
            }
            tweets.removeAll()
            // blank out screen while refreshing
            tableView.reloadData()
            refresh()
            }
        }
    }
    // var searchTextCandidate: String?
    
    private struct Storyboard {
        static let cellReuseIdentifier = "Tweet"
        static let mentionsSegueIdentifier = "showMentions"
        static let imagesSegueIdentifier = "showTweetSearchImages"
        
        static let NumberTweetsKey = "defaultTweets"
    }
    
    let defaults = NSUserDefaults.standardUserDefaults()
   
    private var numTweets: Int {
        return defaults.objectForKey(Storyboard.NumberTweetsKey) as? Int ?? 1
    }
    
       // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // if tweets is nonzero dont refresh and instead display the single tweet in tweets
        if tweets.count == 0 {
            // add search to NSUserDefaults and refresh
            if let text = searchText {
                history.addSearch(text)
            }
            refresh()
            // also add camera icon
            let cameraButton = UIBarButtonItem(barButtonSystemItem: .Camera, target: self, action: "segueImages:")
            if let button = navigationItem.rightBarButtonItem {
                navigationItem.rightBarButtonItems = [button,cameraButton]
            } else {
                navigationItem.rightBarButtonItem = cameraButton
            }
            
        } else {
            // setup single tweet case
            searchTextField.text = " "
            let tweet = tweets.first!.first!
            title = "Tweet by " + tweet.user.name
            tableView.reloadSections(NSIndexSet(indexesInRange: NSMakeRange(0, tableView.numberOfSections())), withRowAnimation: .None)
        }
    }
    
    func segueImages(sender: UIBarButtonItem) {
        extractMediaItems()
        if allMedia.count != 0 {
        performSegueWithIdentifier(Storyboard.imagesSegueIdentifier, sender: sender)
        }
    }
    
    private var lastSuccessfulRequest: TwitterRequest?
    
    private var nextRequestToAttempt: TwitterRequest? {
        if lastSuccessfulRequest == nil {
            if searchText != nil {
                return TwitterRequest(search: searchText!, count: numTweets)
            } else {
                return nil
            }
        } else {
            return lastSuccessfulRequest!.requestForNewer
        }
    }
    
    func refresh() {
        if refreshControl != nil {
            refreshControl?.beginRefreshing()
        }
        refresh(refreshControl)
    }
    
    @IBAction func refresh(sender: UIRefreshControl?) {
        if searchText != nil {
            if let request = nextRequestToAttempt {
                lastSuccessfulRequest = request
                request.fetchTweets { (newTweets) -> Void in
                    dispatch_async(dispatch_get_main_queue()) { () -> Void in
                        if newTweets.count > 0 {
                            self.tweets.insert(newTweets, atIndex: 0)
                            self.tableView.reloadData()
                            self.tableView.reloadSections(NSIndexSet(indexesInRange: NSMakeRange(0, self.tableView.numberOfSections() )), withRowAnimation: .None)
                            self.title = self.searchText
                        }
                        sender?.endRefreshing()
                    }
                }
            }
        } else {
            sender?.endRefreshing()
        }
    }
    
    @IBOutlet weak var searchTextField: UITextField! {
        didSet {
            searchTextField.delegate = self
            searchTextField.text = searchText
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == searchTextField {
            textField.resignFirstResponder()
            searchText = textField.text
        }
        return true
    }
    
    /*
    @IBAction func returnMention(segue: UIStoryboardSegue) {
        // seque wasn't cancelled so now searchText can be set
        if let candidate = searchTextCandidate {
            searchText = candidate
            if candidate.hasPrefix("@") {
                searchText! += " OR from:" + candidate
            }
        }
        
    }
    */
    
    // MARK: - UITableViewDataSource

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return tweets.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets[section].count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.cellReuseIdentifier, forIndexPath: indexPath) as! TweetTableViewCell
        // Configure the cell...
        cell.tweet = tweets[indexPath.section][indexPath.row]
        return cell
    }

    // MARK: - Navigation
    
    private var allMedia = [[MediaItem]]()
    private var allTweets = [[Tweet]]()
    
    private func extractMediaItems() {
        allMedia = []
        allTweets = []
        for sect in tweets {
            var sectMedia = [MediaItem]()
            var sectTweet = [Tweet]()
            for tweet in sect {
                if tweet.media.count > 0 {
                    sectMedia += tweet.media
                    for _ in 0..<tweet.media.count {
                    sectTweet.append(tweet)
                    }
                }
            }
            if sectMedia.count > 0 {
                allMedia.append(sectMedia)
                allTweets.append(sectTweet)
            }
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        // cancel segue if zero mentions
        if identifier == Storyboard.mentionsSegueIdentifier {
            if let cell = sender as? TweetTableViewCell {
                if cell.tweetMentionsCount == 0 {return false}
            }
        }
        // cancel segue if zero images
        if identifier == Storyboard.imagesSegueIdentifier {
            if let cell = sender as? UIBarButtonItem {
                extractMediaItems()
                if allMedia.count == 0 {return false}
            }
        }
        return true
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let identifier = segue.identifier {
            switch identifier {
            case Storyboard.mentionsSegueIdentifier:
                if let cell = sender as? TweetTableViewCell {
                    let mtvc = segue.destinationViewController as! MentionsTableViewController
                    mtvc.tweet = cell.tweet
                }
            case Storyboard.imagesSegueIdentifier:
                if let cell = sender as? UIBarButtonItem {
                    let icvc = segue.destinationViewController as! ImagesCollectionViewController
                    icvc.title = title! + ": Images"
                    icvc.allMedia = allMedia
                    icvc.allTweets = allTweets
                }
            default: break
            }
        }
    }
}
