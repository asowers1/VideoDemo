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
	
	let captureSession = AVCaptureSession()
	var previewLayer : AVCaptureVideoPreviewLayer?
 
	// If we find a device we'll store it here for later use
	var captureDevice : AVCaptureDevice?
 
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		captureSession.sessionPreset = AVCaptureSessionPresetLow
		
		let devices = [AVCaptureDevice.defaultDevice(withDeviceType: .builtInWideAngleCamera, mediaType: AVMediaTypeVideo, position: .front), AVCaptureDevice.defaultDevice(withDeviceType: .builtInMicrophone, mediaType: AVMediaTypeAudio, position: .unspecified)]
		
		// Loop through all the capture devices on this phone
		for device in devices {
			// Make sure this particular device supports video
			if (device?.hasMediaType(AVMediaTypeVideo))! {
				// Finally check the position and confirm we've got the back camera
				if(device?.position == AVCaptureDevicePosition.back) {
					captureDevice = device
				}
			}
		}
		
		if captureDevice != nil {
			beginSession()
		}
		
	}
	
	func beginSession() {
		
		do {
			try captureSession.addInput(AVCaptureDeviceInput(device: captureDevice))
		} catch {
			print("error")
		}
		
		previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
		self.view.layer.addSublayer(previewLayer!)
		previewLayer?.frame = self.view.layer.frame
		captureSession.startRunning()
	}
	
	func configureDevice() {
		if let device = captureDevice {
			device.unlockForConfiguration()
			device.focusMode = .locked
			device.unlockForConfiguration()
		}
	}
	
	func focusTo(value : Float) {
		if let device = captureDevice {
			do {
				try device.lockForConfiguration()
				device.setFocusModeLockedWithLensPosition(value, completionHandler: { (time) -> Void in
					//
				})
				device.unlockForConfiguration()
			} catch {
				
			}
		}
	}
	
	let screenWidth = UIScreen.main.bounds.size.width
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		let anyTouch = touches.first
		let touchPercent = anyTouch!.location(in: self.view).x / screenWidth
		focusTo(value: Float(touchPercent))
	}
	
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		let anyTouch = touches.first
		let touchPercent = anyTouch!.location(in: self.view).x / screenWidth
		focusTo(value: Float(touchPercent))
	}


}

