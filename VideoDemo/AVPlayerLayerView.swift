//
//  AVPlayerLayerView.swift
//  VideoDemo
//
//  Created by Andrew Sowers on 10/23/16.
//  Copyright © 2016 Andrew Sowers. All rights reserved.
//

import UIKit
import AVFoundation

class AVPlayerLayerView: UIView {
	
	let player: AVPlayer = AVPlayer()
	let loopable = MutableProperty<Bool>(true)
	
	var avPlayerLayer: AVPlayerLayer {
		return layer as! AVPlayerLayer
	}

	// MARK: UIView
	
	override class var layerClass: AnyClass {
		return AVPlayerLayer.self
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
		setup()
	}
	
	func setup() {
		avPlayerLayer.player = player
		avPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
		
		// Add notification block for replay
		
//		NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: nil)
//		{ notification in
//			self.replay()
//		}
	}
	
	func setContentUrl(_ url: URL) {
		print("Setting up item: \(url)")
		let item = AVPlayerItem(url: url as URL)
		player.replaceCurrentItem(with: item)
		play()
	}
	
	func play() {
		if (player.currentItem != nil) {
			print("Starting playback!")
			player.play()
		}
	}
	
	func pause() {
		player.pause()
	}
	
	func rewind() {
		player.seek(to: CMTime(seconds: 0, preferredTimescale: 1))
	}
	
	func stop() {
		pause()
		rewind()
	}
	
	func replay() {
		stop()
		play()
	}
}
