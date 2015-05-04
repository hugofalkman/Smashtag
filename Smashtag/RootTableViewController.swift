//
//  RootTableViewController.swift
//  Smashtag
//
//  Created by H Hugo Falkman on 2015-04-01.
//  Copyright (c) 2015 H Hugo Fakman. All rights reserved.
//

import UIKit

class RootTableViewController: TweetTableViewController {
    
    private struct Constants {
        static let cellReuseIdentifier = "Tweet2"
        static let defaultSearchKey = "defaultSearch"
        static let defaultFirstSearch = "#Stanford"
        static let defaultNumberSearchesKey = "defaultSearches"
        static let defaultFirstSearches = 100
        static let defaultNumberTweetsKey = "defaultTweets"
        static let defaultFirstTweets = 100
    }
    
    private var defaultSearchText: String? {
        get { return defaults.objectForKey(Constants.defaultSearchKey) as? String }
        set { defaults.setObject(newValue, forKey: Constants.defaultSearchKey) }
    }
    
    private var numberSearches: Int? {
        get {return defaults.objectForKey(Constants.defaultNumberSearchesKey) as? Int}
        set {defaults.setObject(newValue, forKey: Constants.defaultNumberSearchesKey) }
    }
    
    private var numberTweets: Int? {
        get {return defaults.objectForKey(Constants.defaultNumberTweetsKey) as? Int}
        set {defaults.setObject(newValue, forKey: Constants.defaultNumberTweetsKey) }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // needs to be set ahead of viewDidLoad
        numberTweets = numberTweets ?? Constants.defaultFirstTweets
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // set defaults if NSUserDefaults is not initialized
        defaultSearchText = defaultSearchText ?? Constants.defaultFirstSearch
        if searchText == nil {
        searchText = defaultSearchText
        }
        numberSearches = numberSearches ?? Constants.defaultFirstSearches
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.cellReuseIdentifier, forIndexPath: indexPath) as! RootTableViewCell
        // Configure the cell...
        cell.tweet = tweets[indexPath.section][indexPath.row]
        return cell
    }

    @IBAction func returnImages(segue: UIStoryboardSegue) {

    }
}
