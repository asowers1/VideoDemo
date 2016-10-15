//
//  VideoDemoViewController.swift
//  VideoDemo
//
//  Created by Andrew Sowers on 10/13/16.
//  Copyright © 2016 Andrew Sowers. All rights reserved.
//

import UIKit

class VideoDemoViewController: UIViewController {
	let colors = Colors()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		let backgroundLayer = colors.defaultGradient
		backgroundLayer.frame = view.frame
		view.layer.insertSublayer(backgroundLayer, at: 0)
	}
}
