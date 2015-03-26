//
//  WebViewController.swift
//  Smashtag
//
//  Created by H Hugo Falkman on 2015-03-25.
//  Copyright (c) 2015 H Hugo Fakman. All rights reserved.
//

import UIKit

class WebViewController: UIViewController, UIWebViewDelegate {
    
    var url: NSURL?
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        webView.delegate = self
        if let actualURL = url {
            let urlRequest = NSURLRequest(URL: actualURL)
            webView.scalesPageToFit = true
            webView.loadRequest(urlRequest)
        }
    }
    
    private var numLoads = 0
    
    func webViewDidStartLoad(webView: UIWebView) {
        numLoads++
        spinner.startAnimating()
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        numLoads--
        if numLoads < 1 {
            spinner.stopAnimating()
        }
    }
}
