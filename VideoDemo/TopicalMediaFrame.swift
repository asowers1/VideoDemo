//
//  TopicalMediaFrame.swift
//  VideoDemo
//
//  Created by Andrew Sowers on 10/22/16.
//  Copyright © 2016 Andrew Sowers. All rights reserved.
//

import UIKit
import QuartzCore

class TopicalMediaFrame: UIViewController, UIGestureRecognizerDelegate {
	
	//MARK - Properties -
	
	var rotation = CGFloat()
	
	let tapRec = UITapGestureRecognizer()
	let pinchRec = UIPinchGestureRecognizer()
	let swipeRec = UISwipeGestureRecognizer()
	let longPressRec = UILongPressGestureRecognizer()
	let rotateRec = UIRotationGestureRecognizer()
	let panRec = UIPanGestureRecognizer()

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
		
		pinchRec.delegate = self
		rotateRec.delegate = self
		panRec.delegate = self
		
		pinchRec.addTarget(self, action: #selector(TopicalMediaFrame.pinchedView(_:)))
		rotateRec.addTarget(self, action: #selector(TopicalMediaFrame.rotatedView(_:)))
		panRec.addTarget(self, action: #selector(TopicalMediaFrame.draggedView(_:)))
		
		self.view?.addGestureRecognizer(pinchRec)
		//imageView.addGestureRecognizer(pinchRec)
		self.view?.addGestureRecognizer(rotateRec)
		//imageView.addGestureRecognizer(rotateRec)
		self.view?.addGestureRecognizer(panRec)
		//imageView.addGestureRecognizer(panRec)
		
		movieView.isUserInteractionEnabled = true
		movieView.isMultipleTouchEnabled = true
		imageView.isUserInteractionEnabled = true
		imageView.isMultipleTouchEnabled = true
		
	}
	
	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
		return true
	}
	
	//MARK: - Gestures -
	func rotatedView(_ sender:UIRotationGestureRecognizer){
		sender.view!.transform = sender.view!.transform.rotated(by: sender.rotation)
		sender.rotation = 0
		
	}
	func pinchedView(_ sender:UIPinchGestureRecognizer){
		sender.view?.transform = ((sender.view?.transform)?.scaledBy(x: sender.scale, y: sender.scale))!
		sender.scale = 1.0
		
	}
	func draggedView(_ sender:UIPanGestureRecognizer){
		self.view.bringSubview(toFront: sender.view!)
		let translation = sender.translation(in: self.view)
		sender.view?.center = CGPoint(x: (sender.view?.center.x)! + translation.x, y: (sender.view?.center.y)! + translation.y)
		sender.setTranslation(CGPoint.zero, in: self.view)
	}
}
