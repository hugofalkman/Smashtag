//
//  ImageViewController.swift
//  Smashtag
//
//  Created by H Hugo Falkman on 2015-03-18.
//  Copyright (c) 2015 H Hugo Fakman. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController, UIScrollViewDelegate {
    
    var image: UIImage? {
        get { return imageView.image }
        set {
            imageView.image = newValue
            imageView.sizeToFit()
            scrollView?.contentSize = imageView.frame.size
            imageSize = imageView.frame.size
        }
    }

    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.contentSize = imageView.frame.size
            scrollView.delegate = self
        }
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    private struct Constants {
        static let maxZooming: CGFloat = 5.0
    }
    
    private var notZoomed = true
    func scrollViewDidEndZooming(scrollView: UIScrollView, withView view: UIView!, atScale scale: CGFloat) {
        notZoomed = false
    }
    
    private var imageView = UIImageView()
    private var imageSize = CGSizeMake(0, 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.addSubview(imageView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if notZoomed {
        scrollView.contentSize = imageSize
        scrollView.contentOffset = CGPointZero
        let widthScale = scrollView.bounds.size.width / imageSize.width
        let heightScale = scrollView.bounds.size.height / imageSize.height
        let minimum = min(widthScale, heightScale)
        scrollView.minimumZoomScale = minimum
        scrollView.maximumZoomScale = max(widthScale, heightScale, Constants.maxZooming)
        scrollView.zoomScale = minimum
        // println("\(widthScale) \(heightScale)")
        }
    }
}




