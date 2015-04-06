//
//  SettingsViewController.swift
//  Smashtag
//
//  Created by H Hugo Falkman on 2015-04-05.
//  Copyright (c) 2015 H Hugo Fakman. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UITextFieldDelegate {
    
    private struct Constants {
        static let defaultSearchKey = "defaultSearch"
        static let defaultNumberSearchesKey = "defaultSearches"
        static let defaultNumberTweetsKey = "defaultTweets"
    }
    
    private let defaults = NSUserDefaults.standardUserDefaults()
    
    private var searchText: String? {
        get {return defaults.objectForKey(Constants.defaultSearchKey) as? String ?? ""}
        set {defaults.setObject(newValue, forKey: Constants.defaultSearchKey) }
    }
    
    private var numberSearches: Int? {
        get {return defaults.objectForKey(Constants.defaultNumberSearchesKey) as? Int ?? 0}
        set {defaults.setObject(newValue, forKey: Constants.defaultNumberSearchesKey) }
    }
    
    private var numberTweets: Int? {
        get {return defaults.objectForKey(Constants.defaultNumberTweetsKey) as? Int ?? 0}
        set {defaults.setObject(newValue, forKey: Constants.defaultNumberTweetsKey) }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBOutlet weak var textSearchField: UITextField! {
        didSet {
            textSearchField.delegate = self
            textSearchField.text = searchText
        }
    }
    
    @IBOutlet weak var numberSearchesField: UITextField! {
        didSet {
            numberSearchesField.delegate = self
            numberSearchesField.text = "\(numberSearches!)"
        }
    }

    @IBOutlet weak var numberTweetsField: UITextField! {
        didSet {
            numberTweetsField.delegate = self
            numberTweetsField.text = "\(numberTweets!)"
        }
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == textSearchField {
            textField.resignFirstResponder()
            // searchText = textField.text
        }
        return true
    }
    
    func removeKeyboard() {
        numberTweetsField.resignFirstResponder()
        numberSearchesField.resignFirstResponder()
        textSearchField.resignFirstResponder()
    }
    
    @IBAction func tappedCancel(sender: UIBarButtonItem) {
        textSearchField.text = searchText
        numberSearchesField.text = "\(numberSearches!)"
        numberTweetsField.text = "\(numberTweets!)"
        removeKeyboard()
    }
    
    @IBAction func tappedSave(sender: UIBarButtonItem) {
        searchText = textSearchField.text
        numberSearches = numberSearchesField.text.toInt()
        numberTweets = numberTweetsField.text.toInt()
        removeKeyboard()
        
    }
}
