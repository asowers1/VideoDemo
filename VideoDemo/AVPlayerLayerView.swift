//
//  AVPlayerLayerView.swift
//  VideoDemo
//
//  Created by Andrew Sowers on 10/23/16.
//  Copyright © 2016 Andrew Sowers. All rights reserved.
//

import UIKit
import AVFoundation

@IBDesignable
class AVPlayerLayerView: UIView {
	var player: AVPlayer = AVPlayer()
	var avPlayerLayer: AVPlayerLayer!
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		print("AVPlayerLayerView -> init with frame")
		
		inits()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		print("AVPlayerLayerView -> init with coder")
		
		inits()
	}
	
	private func inits() {
		
		avPlayerLayer = AVPlayerLayer(player: player)
		avPlayerLayer.bounds = self.layer.bounds
		
		//avPlayerLayer.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: self.layer.frame.width, height: self.layer.frame.height))
		self.layer.insertSublayer(avPlayerLayer, at: 0)
	}
	
	func setContentUrl(url: NSURL) {
		print("Setting up item: \(url)")
		let item = AVPlayerItem(url: url as URL)
		player.replaceCurrentItem(with: item)
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
}
