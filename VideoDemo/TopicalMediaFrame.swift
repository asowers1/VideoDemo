//
//  TopicalMediaFrame.swift
//  VideoDemo
//
//  Created by Andrew Sowers on 10/22/16.
//  Copyright © 2016 Andrew Sowers. All rights reserved.
//

import UIKit
import QuartzCore

protocol TopicalMediaFrameDelegate: class {
	func didSetMedia()
}

class TopicalMediaFrame: UIViewController {

	//MARK - Outlets -
	
	@IBOutlet weak var movieView: AVPlayerLayerView!
	@IBOutlet weak var imageView: UIImageView!
	
	var originalFrame: CGRect?
	var originalBounds: CGRect?
	
	weak var delegate: TopicalMediaFrameDelegate?

	var imageViewImage: UIImage! {
		didSet {
			DispatchQueue.main.async { [unowned self] in
				self.movieView?.stop()
				self.imageView?.image = self.imageViewImage
				self.view?.bringSubview(toFront: self.imageView)
				self.delegate?.didSetMedia()
			}
		}
	}
	
	var movieViewMovieNSURL: URL! {
		didSet {
			DispatchQueue.main.async { [unowned self] in
				self.imageView?.image = nil
				self.movieView.setContentUrl(self.movieViewMovieNSURL)
				self.view?.bringSubview(toFront:self.movieView)
				self.delegate?.didSetMedia()
			}
		}
	}

	//MARK - View Lifecycle -
	override func viewDidLoad() {
		super.viewDidLoad()
		originalFrame = view.frame
		originalBounds = view.bounds
	}
	
	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
		return true
	}
	
}
