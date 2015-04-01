//
//  RootTableViewController.swift
//  Smashtag
//
//  Created by H Hugo Falkman on 2015-04-01.
//  Copyright (c) 2015 H Hugo Fakman. All rights reserved.
//

import UIKit

class RootTableViewController: TweetTableViewController {
    
    private struct Storyboard {
        static let cellReuseIdentifier = "Tweet2"
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.cellReuseIdentifier, forIndexPath: indexPath) as RootTableViewCell
        // Configure the cell...
        cell.tweet = tweets[indexPath.section][indexPath.row]
        return cell
    }

    
    @IBAction func returnImages(segue: UIStoryboardSegue) {

    }
}
