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
        static let maxSearches = 100
    }
    
    private var defaults = NSUserDefaults.standardUserDefaults()
    
    var allSearches: [String] {
        get {return defaults.objectForKey(Constants.searchesKey) as? [String] ?? [String]() }
        set {defaults.setObject(newValue, forKey: Constants.searchesKey) }
    }
    
    func addSearch(Search: String) {
        var searches = allSearches
        if let i = find(searches, Search) {
            searches.removeAtIndex(i)
        }
        searches.insert(Search, atIndex: 0)
        while searches.count > Constants.maxSearches {
            searches.removeLast()
        }
        allSearches = searches
    }
}