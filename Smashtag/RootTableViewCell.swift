//
//  RootTableViewCell.swift
//  Smashtag
//
//  Created by H Hugo Falkman on 2015-04-02.
//  Copyright (c) 2015 H Hugo Fakman. All rights reserved.
//

import UIKit

class RootTableViewCell: TweetTableViewCell {
    
    override func setAccessoryType() {
        if tweetMentionsCount > 0 {
            accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        } else {
            accessoryType = UITableViewCellAccessoryType.None
        }
    }
}
