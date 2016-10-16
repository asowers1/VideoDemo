//
//  DemoViewController.swift
//  VideoDemo
//
//  Created by Andrew Sowers on 10/13/16.
//  Copyright © 2016 Andrew Sowers. All rights reserved.
//

import UIKit
import AVFoundation

class DemoViewController: VideoDemoViewController {
	
	private let _viewModel = DemoViewModel()

	@IBOutlet weak var recordButton: UIButton!
	@IBOutlet weak var albumButton: UIButton!
	@IBOutlet weak var saveButton: UIButton!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		recordButton?.racutil_signalProducer
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


}

