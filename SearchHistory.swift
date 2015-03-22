//
//  SearchHistory.swift
//  Smashtag
//
//  Created by H Hugo Falkman on 2015-03-22.
//  Copyright (c) 2015 H Hugo Fakman. All rights reserved.
//

import Foundation

class SearchHistory
{
    private struct Constants {
        static let searchesKey = "searchHistory"
        static let maxSearches = 5
    }
    
    private var defaults = NSUserDefaults.standardUserDefaults()
    
    var allSearches: [String] {
        get {return defaults.objectForKey(Constants.searchesKey) as? [String] ?? [String]() }
        set {defaults.setObject(newValue, forKey: Constants.searchesKey) }
    }
    
    func addSearch(Search: String) {
        if let i = find(allSearches, Search) {
            allSearches.removeAtIndex(i)
        }
        allSearches.insert(Search, atIndex: 0)
        while allSearches.count > Constants.maxSearches {
            allSearches.removeLast()
        }
    }
}