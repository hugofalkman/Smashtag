//
//  HistoryTableViewController.swift
//  Smashtag
//
//  Created by H Hugo Falkman on 2015-03-21.
//  Copyright (c) 2015 H Hugo Fakman. All rights reserved.
//

import UIKit

class HistoryTableViewController: UITableViewController {

    let history = SearchHistory()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(false)
        tableView.reloadData()
    }
    
    private struct Constants {
        static let cellReuseIdentifier = "searchHistory"
        static let segueIdentifier = "showHistorySearchItem"
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int { return 1 }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return history.allSearches.count }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.cellReuseIdentifier, forIndexPath: indexPath) as UITableViewCell
        let test = history.allSearches[indexPath.row]
        cell.textLabel?.text = test
        return cell
    }

    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            history.allSearches.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }    
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let identifier = segue.identifier {
            if identifier == Constants.segueIdentifier {
                if let cell = sender as? UITableViewCell {
                    if let ttvc = segue.destinationViewController as? TweetTableViewController {
                    ttvc.searchText = cell.textLabel?.text
                    }
                }
            }
        }

    }
}
