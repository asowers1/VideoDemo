//
//  DemoViewController.swift
//  VideoDemo
//
//  Created by Andrew Sowers on 10/13/16.
//  Copyright © 2016 Andrew Sowers. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer
import MobileCoreServices
import AVKit

class DemoViewController: VideoDemoViewController {
	
	fileprivate let _viewModel = DemoViewModel()

	@IBOutlet weak var recordButton: UIButton!
	@IBOutlet weak var albumButton: UIButton!
	@IBOutlet weak var saveButton: UIButton!
	
	//children media view
	weak var cameraViewController: CameraViewController?
	weak var topicalMediaFrame: TopicalMediaFrame?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		_viewModel.mediaAlertController.signal.observeValues { [weak self] in
			guard let alertController = $0 else { return }
			self?.present(alertController, animated: true, completion: { _ in
				alertController.view.tintColor = Colors.NavigationNeonPink
			})
		}
		
		_viewModel.mediaPicker.signal.observeValues { [weak self] in
			guard let alertController = $0 as UIImagePickerController? else { return }
			alertController.delegate = self as (UIImagePickerControllerDelegate & UINavigationControllerDelegate)?
			self?.present(alertController, animated: true, completion: nil)
		}
		
		_viewModel.mediaPicker.value?.delegate = self
	}
	

	@IBAction func didTapRecordButton(_ sender: AnyObject) {
		cameraViewController?.startRecording()
	}
	
	@IBAction func didTapAlbumButton(_ sender: AnyObject) {
		_viewModel.prepareMediaAlertController()
	}
	
	@IBAction func didTapSaveButton(_ sender: AnyObject) {
		self.displayMessage("Feature not yet implemented")
	}

}

//MARK: - CameraVieController Delegation -
extension DemoViewController: CameraViewControllerDelegate {
	func didStartRecording() {
		self.recordButton?.setTitle("Pause", for: .normal)
	}
	func didPauseRecording() {
		self.recordButton?.setTitle("Resume", for: .normal)
	}
	func didStopRecording() {
		self.recordButton?.setTitle("Record", for: .normal)
	}
}

//MARK: - Segueways -
extension DemoViewController {
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		switch segue.identifier ?? "" {
		case "CameraViewController":
			guard let vc = segue.destination as? CameraViewController else {
				fatalError("This should be a camera view controller")
			}
			self.cameraViewController = vc
			self.cameraViewController?.delegate = self
		case "TopicalMediaFrame":
			guard let vc = segue.destination as? TopicalMediaFrame else {
				fatalError("This should be a topical media frame")
			}
			self.topicalMediaFrame = vc
			
		default: break
		}
	}
}

//MARK: - Delegation -
//------------------------------------------------------------------------------
extension DemoViewController: UIImagePickerControllerDelegate, MPMediaPickerControllerDelegate, UINavigationControllerDelegate {
	public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
	}
	
	public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
		
		guard let mediaType = info[UIImagePickerControllerMediaType] as? NSString else {
			self.displayMessage("Picking media failed D:")
			dismiss(animated: true, completion: nil)
			return
		}
		
		// 2
		dismiss(animated: true) {
			// 3
			if mediaType == kUTTypeMovie {
				self.topicalMediaFrame?.movieViewMovieNSURL = (info[UIImagePickerControllerMediaURL] as! NSURL) as URL!
				self.topicalMediaFrame?.movieView?.play()
			} else if mediaType == kUTTypeImage {
				guard let image = info[UIImagePickerControllerEditedImage] as? UIImage else {
					self.displayMessage("Could not load image D:")
					return
				}
				self.topicalMediaFrame?.imageViewImage = image
			}
		}
	}
	
	public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		dismiss(animated: true, completion: nil)
	}
	
	public func mediaPicker(_: MPMediaPickerController, didPickMediaItems: MPMediaItemCollection) {
		
	}
	
	public func mediaPickerDidCancel(_: MPMediaPickerController) {
		dismiss(animated: true, completion: nil)
	}
}

