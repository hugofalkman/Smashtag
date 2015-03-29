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
    
    var searchText: String? = "#Stanford" {
        didSet {
            lastSuccessfulRequest = nil
            searchTextField?.text = searchText
            tweets.removeAll()
            if let text = searchText {
            history.addSearch(text)
            }
            tableView.reloadData()
            refresh()
        }
    }
    var searchTextCandidate: String?
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let text = searchText {
        history.addSearch(text)
        }
        
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        refresh()
        
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "preferredContentSizeChanged:",
            name: UIContentSizeCategoryDidChangeNotification,
            object: nil)
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    private var lastSuccessfulRequest: TwitterRequest?
    
    private var nextRequestToAttempt: TwitterRequest? {
        if lastSuccessfulRequest == nil {
            if searchText != nil {
                return TwitterRequest(search: searchText!, count: 100)
            } else {
                return nil
            }
        } else {
            return lastSuccessfulRequest!.requestForNewer
        }
    }

    func preferredContentSizeChanged(notification: NSNotification) {
        refresh()
    }
    
    private func refresh() {
        if refreshControl != nil {
            refreshControl?.beginRefreshing()
        }
        refresh(refreshControl)
    }
    
    @IBAction func refresh(sender: UIRefreshControl?) {
        if searchText != nil {
            if let request = nextRequestToAttempt {
                request.fetchTweets { (newTweets) -> Void in
                    dispatch_async(dispatch_get_main_queue()) { () -> Void in
                        if newTweets.count > 0 {
                            self.lastSuccessfulRequest = request
                            self.tweets.insert(newTweets, atIndex: 0)
                            self.tableView.reloadData()
                            self.tableView.reloadSections(NSIndexSet(indexesInRange: NSMakeRange(0, self.tableView.numberOfSections() - 1)), withRowAnimation: .None)
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
    
    @IBAction func returnMention(segue: UIStoryboardSegue) {
        // seque wasn't cancelled so now searchText can be set
        if let candidate = searchTextCandidate {
            searchText = candidate
            if candidate.hasPrefix("@") {
                searchText! += " OR from:" + candidate
            }
        }
        
    }
    
    // MARK: - UITableViewDataSource
    
    private struct Storyboard {
        static let cellReuseIdentifier = "Tweet"
        static let mentionsSegueIdentifier = "showMentions"
        static let imagesSegueIdentifier = "showTweetSearchImages"
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return tweets.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets[section].count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.cellReuseIdentifier, forIndexPath: indexPath) as TweetTableViewCell

        // Configure the cell...
        cell.tweet = tweets[indexPath.section][indexPath.row]
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    
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
                    let mtvc = segue.destinationViewController as MentionsTableViewController
                    mtvc.tweet = cell.tweet
                }
            case Storyboard.imagesSegueIdentifier:
                if let cell = sender as? UIBarButtonItem {
                    let icvc = segue.destinationViewController as ImagesCollectionViewController
                    icvc.title = title! + ": Images"
                    icvc.allMedia = allMedia
                    icvc.allTweets = allTweets
                }
            default: break
            }
        }
    }
}
