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
import QuartzCore
import ReactiveObjC

class DemoViewController: VideoDemoViewController {
	
	fileprivate let _viewModel = DemoViewModel()

	@IBOutlet weak var topicalContainer: UIView!
	@IBOutlet weak var cameraContainer: UIView!
	
	@IBOutlet weak var recordButton: UIButton!
	@IBOutlet weak var albumButton: UIButton!
	@IBOutlet weak var saveButton: UIButton!
	@IBOutlet weak var replayAnimationsButton: UIButton!
	
	var originalRect: CGRect!
	var originalTransform: CGAffineTransform!
	
	let pinchSelfieRec = UIPinchGestureRecognizer()
	let pinchTopicalRec = UIPinchGestureRecognizer()
	
	let swipeSelfieRec = UISwipeGestureRecognizer()
	let swipeTopicalRec = UISwipeGestureRecognizer()
	
	let rotateSelfieRec = UIRotationGestureRecognizer()
	let rotateTopicalRec = UIRotationGestureRecognizer()
	
	let panSelfieRec = UIPanGestureRecognizer()
	let panTopicalRec = UIPanGestureRecognizer()
	
	var pinchGestureRecognizers: [UIPinchGestureRecognizer] {
		return [pinchSelfieRec, pinchTopicalRec]
	}
	
	var swipeGestureRecognizers: [UISwipeGestureRecognizer] {
		return [swipeSelfieRec, swipeTopicalRec]
	}
	
	var rotateGesureRecognizers: [UIRotationGestureRecognizer] {
		return [rotateSelfieRec, rotateTopicalRec]
	}
	
	var panGestureRecognizers: [UIPanGestureRecognizer] {
		return [panSelfieRec, panTopicalRec]
	}
	
	var selfieGestureRecognizers: [UIGestureRecognizer] {
		return [pinchSelfieRec, swipeSelfieRec, rotateSelfieRec, panSelfieRec]
	}
	
	var topicalGestureRecognizers: [UIGestureRecognizer] {
		return [pinchTopicalRec, swipeTopicalRec, rotateTopicalRec, panTopicalRec]
	}
	
	var gestureRecognizers: [UIGestureRecognizer] {
		return [selfieGestureRecognizers,
		        topicalGestureRecognizers
			].flatMap { $0 }
	}
	
	//children media view
	weak var cameraViewController: CameraViewController?
	weak var dummyViewController: UIViewController?
	weak var topicalMediaFrame: TopicalMediaFrame?
	
	var mediaViews: [UIView] {
		var views = [UIView]()
		if let view = cameraViewController?.view {
			views.append(view)
		}
		if let view = topicalMediaFrame?.view {
			views.append(view)
		}
		return views
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		originalRect = CGRect(x: cameraContainer.frame.origin.x, y: cameraContainer.frame.origin.y, width: cameraContainer.frame.width, height: cameraContainer.frame.height)
		originalTransform = cameraContainer.layer.affineTransform()
		
		for recognizer in gestureRecognizers {
			recognizer.delegate = self
		}
		
		pinchGestureRecognizers.forEach {
			$0.addTarget(self, action: #selector(DemoViewController.pinchedView(_:)))
		}
		
		rotateGesureRecognizers.forEach {
			$0.addTarget(self, action: #selector(DemoViewController.rotatedView(_:)))
		}
		
		panGestureRecognizers.forEach {
			$0.addTarget(self, action: #selector(DemoViewController.draggedView(_:)))

		}
		
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
		
		
		self.topicalContainer.rac_values(forKeyPath: "center", observer: self)
			.subscribeNext { next in
				print("New topicalContainer center received: \n\(self.topicalContainer.center)")
		}
		
		self.topicalContainer.rac_values(forKeyPath: "transform", observer: self)
			.subscribeNext { next in
				print("New topicalContainer transform received: \n\(self.topicalContainer.transform)")
		}
		
		self.cameraContainer.rac_values(forKeyPath: "center", observer: self)
			.subscribeNext { next in
				print("New cameraContainer center received: \n\(self.cameraContainer.center)")
		}
		
		self.cameraContainer.rac_values(forKeyPath: "transform", observer: self)
			.subscribeNext { next in
				print("New cameraContainer transform received: \n\(self.cameraContainer.transform)")
		}
		
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		selfieGestureRecognizers.forEach {
			dummyViewController?.view.addGestureRecognizer($0)
		}
		
		topicalGestureRecognizers.forEach {
			topicalMediaFrame?.view.addGestureRecognizer($0)
		}
		
		mediaViews.forEach {
			$0.isUserInteractionEnabled = true
			$0.isMultipleTouchEnabled = true
		}
	}
	

	@IBAction func didTapRecordButton(_ sender: AnyObject) {
		cameraViewController?.toggleRecording()
	}
	
	@IBAction func didTapAlbumButton(_ sender: AnyObject) {
		_viewModel.prepareMediaAlertController()
	}
	
	@IBAction func didTapSaveButton(_ sender: AnyObject) {
		self.displayMessage("Feature not yet implemented")
	}
	
	@IBAction func didTapReplayAnimationsButton(_ sender: AnyObject) {
		self.replayAnimations()
	}

}

//MARK: - Animation Replay -
extension DemoViewController {
	func replayAnimations() {
		
	}
}

//MARK: - DemoViewController TopicalMediaFrame Delegation -
extension DemoViewController: TopicalMediaFrameDelegate {
	func didSetMedia() {
		self.view.bringSubview(toFront: self.cameraContainer)
		self.cameraContainer.frame = originalRect!
		self.topicalContainer.frame = originalRect!
		
		UIView.animate(withDuration: 0.1,
		               delay: 0.1,
		               options: UIViewAnimationOptions.curveEaseIn,
		               animations: { [unowned self] () -> Void in
						
						//vc.view.frame = vc.originalFrame!
						
						let halfWidth = self.cameraContainer.frame.width / 2
						let halfHeight = self.cameraContainer.frame.height / 2
						let newY = self.cameraContainer.frame.origin.y + halfHeight
						let newX = self.cameraContainer.frame.origin.x + halfWidth
						
						let newRect = CGRect(x: newX, y: newY, width: halfWidth, height: halfHeight)
						
						self.cameraContainer.frame = newRect
						//selfieVC.view.superview!.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
						
		}, completion: { (finished) -> Void in
			self.cameraViewController?.aVPlayerLayerView.replay()
		})
	}
}

//MARK: - DemoViewController Gesture Recognition -
extension DemoViewController: UIGestureRecognizerDelegate {
	//MARK: - Gestures -
	func rotatedView(_ sender:UIRotationGestureRecognizer){
		DispatchQueue.main.async { [unowned self] in
			self.view?.bringSubview(toFront: sender.view!)
			sender.view?.superview?.transform = sender.view!.transform.rotated(by: sender.rotation)
			sender.rotation = 0
		}
	}
	func pinchedView(_ sender:UIPinchGestureRecognizer){
		DispatchQueue.main.async { [unowned self] in
			self.view?.bringSubview(toFront: sender.view!.superview!)
			let scale = sender.scale
			sender.view?.superview?.transform = sender.view!.superview!.transform.scaledBy(x: scale, y: scale)
			sender.scale = 1.0
		}
	}
	func draggedView(_ sender:UIPanGestureRecognizer){
		DispatchQueue.main.async { [unowned self] in
			self.view?.bringSubview(toFront: sender.view!.superview!)
			let translation = sender.translation(in: self.view!)
			sender.view!.superview!.center.x += translation.x
			sender.view!.superview!.center.y += translation.y
			sender.setTranslation(CGPoint.zero, in: self.view)
		}
	}
	
	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
		return true
	}
	
}

//MARK: - CameraViewController Delegation -
extension DemoViewController: CameraViewControllerDelegate {
	func didStartRecording() {
		DispatchQueue.main.async {
			self.recordButton?.setTitle("Pause", for: .normal)
		}
	}
	func didPauseRecording() {
		DispatchQueue.main.async {
			self.recordButton?.setTitle("Resume", for: .normal)
		}
	}
	func didStopRecording() {
		DispatchQueue.main.async {
			self.recordButton?.setTitle("Record", for: .normal)
			self.topicalMediaFrame?.movieView?.replay()
		}
	}
}

//MARK: - Segueways -
extension DemoViewController {
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		switch segue.identifier ?? "" {
		case "CameraViewController":
			guard let vc = segue.destination as? CameraViewController else {
				//fatalError("This should be a camera view controller")
				self.dummyViewController = segue.destination
				return
			}
			self.cameraViewController = vc
			self.cameraViewController?.delegate = self
		case "TopicalMediaFrame":
			guard let vc = segue.destination as? TopicalMediaFrame else {
				fatalError("This should be a topical media frame")
			}
			self.topicalMediaFrame = vc
			self.topicalMediaFrame?.delegate = self
			
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

