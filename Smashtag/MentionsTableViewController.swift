//
//  MentionsTableViewController.swift
//  Smashtag
//
//  Created by H Hugo Falkman on 2015-03-12.
//  Copyright (c) 2015 H Hugo Fakman. All rights reserved.
//

import UIKit

class MentionsTableViewController: UITableViewController {
    
    private enum Mention: Printable {
        case Image(NSURL, Double)
        case Hashtag(String)
        case User(String)
        case URL(String)
        
        var description: String {
            switch self {
            case .Image(let URL, _): return URL.path!
            case .Hashtag (let key): return key
            case .User (let key): return key
            case .URL (let key): return key
            }
        }
    }
    
    var tweet: Tweet? {
        didSet {
            title = tweet?.user.name
            
            setSection("Images", tweetProperty: tweet?.media) {Mention.Image($0.url, $0.aspectRatio)}
            setSection("Hashtags", tweetProperty: tweet?.hashtags) {Mention.Hashtag($0.keyword)}
            if let name = tweet?.user.screenName {
            setSection("Users", tweetProperty: tweet?.userMentions, propertyInit:
                Mention.User("@\(name)")) {Mention.User($0.keyword)}
            }
            setSection("URLs", tweetProperty: tweet?.urls) {Mention.URL($0.keyword)}
        }
    }
    
    private var mentions = [[Mention]]()
    private var sections = [String]() // section headers
    
    // help function to set one section in mentions array of arrays
    private func setSection<T>(section: String, tweetProperty: [T]?, transform: T -> Mention) {
        return setSection(section, tweetProperty: tweetProperty, propertyInit: nil , transform: transform)
    }
    private func setSection<T>(section: String, tweetProperty: [T]?, propertyInit: Mention?, transform: T -> Mention) {
        var sectionToAdd = [Mention]()
        if let pI = propertyInit { sectionToAdd.append(pI) }
        if let property = tweetProperty { sectionToAdd += property.map(transform) }
        if sectionToAdd.count > 0 {
            mentions.append(sectionToAdd)
            sections.append(section)
        }
    }

    private struct Storyboard {
        static let imageCellReuseIdentifier = "Image"
        static let mentionCellReuseIdentifier = "Mention"
        static let unwindSegueIdentifier = "searchMention"
        static let scrollViewSegueIdentifier = "showScrolledImage"
        static let webViewSegueIdentifier = "showWebView"
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return mentions.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mentions[section].count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let mention = mentions[indexPath.section][indexPath.row]
        switch mention {
        case .Image(let url, let _):
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.imageCellReuseIdentifier, forIndexPath: indexPath) as ImageTableViewCell
            cell.imageUrl = url
            return cell
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.mentionCellReuseIdentifier, forIndexPath: indexPath) as UITableViewCell
            cell.textLabel?.text = mention.description
            return cell
        }
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let mention = mentions[indexPath.section][indexPath.row]
        switch mention {
        case .Image(_, let ratio):
            return tableView.bounds.size.width / CGFloat(ratio)
        default:
            return UITableViewAutomaticDimension
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header:UITableViewHeaderFooterView = view as UITableViewHeaderFooterView
        header.textLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
    }
    
    // MARK: - Navigation
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        // if url, cancel seque and open safari
        if identifier == Storyboard.unwindSegueIdentifier {
            if let cell = sender as? UITableViewCell {
                if let url = cell.textLabel?.text {
                    if url.hasPrefix("http") {
                        performSegueWithIdentifier(Storyboard.webViewSegueIdentifier, sender: cell)
                        // UIApplication.sharedApplication().openURL(NSURL(string: url)!)
                        return false
                    }
                }
            }
        }
        return true
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
            case Storyboard.unwindSegueIdentifier:
                if let ttvc = segue.destinationViewController as? TweetTableViewController {
                    if let cell = sender as? UITableViewCell {
                        // wait to add to searchText until in the IBAction returnMention function
                        // you know that the segue wasnt cancelled for a url -- see above
                        ttvc.searchTextCandidate = cell.textLabel?.text
                    }
                }
            case Storyboard.scrollViewSegueIdentifier:
                if let ivc = segue.destinationViewController as? ImageViewController {
                    if let cell = sender as? ImageTableViewCell {
                        ivc.image = cell.tweetImage.image
                        if let title = self.title {
                        ivc.title = title + ": Image"
                        }
                    }
                }
            case Storyboard.webViewSegueIdentifier:
                if let wvc = segue.destinationViewController as? WebViewController {
                    if let cell = sender as? UITableViewCell {
                        if let url = cell.textLabel?.text {
                            wvc.title = url
                            wvc.url = NSURL(string: url)
                        }
                    }
                }
            default: break
            }
            
        }
    }
    

}
