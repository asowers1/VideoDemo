//
//  DemoViewModel.swift
//  VideoDemo
//
//  Created by Andrew Sowers on 10/15/16.
//  Copyright © 2016 Andrew Sowers. All rights reserved.
//

import UIKit
import MobileCoreServices

public struct DemoViewModel {
	
	//MARK: - Avatar Picker -
	//--------------------------------------------------------------------------
	let mediaPicker: MutableProperty<CaptureMediaPickerController?> = MutableProperty(nil)
	let media: MutableProperty<UIImage?> = MutableProperty(nil)
	let mediaAlertController: MutableProperty<UIAlertController?> = MutableProperty(nil)
	
	func prepareMediaAlertController() {
		
		let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
		
		alertController.view.tintColor = Colors.NavigationNeonPink
		
		let mediaLibraryAction = UIAlertAction(title: "Media Library", style: .default) { (action) in
			self.mediaLibrary()
		}
		let newMediaAction = UIAlertAction(title: "Take Photo/Video", style: .default) { (action) in
			self.takePhotoOrVideo()
		}
		let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
			self.cancelAction()
		})
		
		alertController.addAction(mediaLibraryAction)
		alertController.addAction(newMediaAction)
		alertController.addAction(cancelAction)
		alertController.view.tintColor = Colors.NavigationNeonPink
		mediaAlertController.value = alertController
	}
	
	func mediaLibrary() {
		let mediaPicker = CaptureMediaPickerController()
		mediaPicker.allowsEditing = true
		mediaPicker.sourceType = .savedPhotosAlbum
		mediaPicker.mediaTypes = [String(kUTTypeImage), String(kUTTypeMovie)]
		mediaPicker.modalPresentationStyle = .popover
		mediaPicker.view.tintColor = Colors.NavigationNeonPink
		self.mediaPicker.value = mediaPicker
	}
	
	func takePhotoOrVideo() {
		let mediaPicker = CaptureMediaPickerController()
		mediaPicker.allowsEditing = true
		mediaPicker.sourceType = .camera
		mediaPicker.mediaTypes = [String(kUTTypeImage), String(kUTTypeMovie)]
		mediaPicker.modalPresentationStyle = .popover
		self.mediaPicker.value = mediaPicker
	}
	
	func cancelAction() {
		//TODO: - Add cancel analytics -
	}
	
}

