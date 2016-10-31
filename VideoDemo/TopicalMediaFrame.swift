//
//  TopicalMediaFrame.swift
//  VideoDemo
//
//  Created by Andrew Sowers on 10/22/16.
//  Copyright © 2016 Andrew Sowers. All rights reserved.
//

import UIKit
import QuartzCore

class TopicalMediaFrame: UIViewController {

	//MARK - Outlets -
	
	@IBOutlet weak var movieView: AVPlayerLayerView!
	@IBOutlet weak var imageView: UIImageView!

	var imageViewImage: UIImage! {
		didSet {
			imageView?.image = imageViewImage
			self.view?.bringSubview(toFront: imageView)
		}
	}
	
	var movieViewMovieNSURL: URL! {
		didSet {
			movieView.setContentUrl(movieViewMovieNSURL)
			self.view?.bringSubview(toFront: movieView)
		}
	}

	//MARK - View Lifecycle -
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
		return true
	}
	
}
