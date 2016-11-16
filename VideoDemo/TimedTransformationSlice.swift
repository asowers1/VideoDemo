//
//  TimedTransformationSlice.swift
//  VideoDemo
//
//  Created by Andrew Sowers on 11/16/16.
//  Copyright © 2016 Andrew Sowers. All rights reserved.
//

import Foundation
import UIKit

struct TimedTransformationSlice {
	let transformation: CGAffineTransform?
	let point: CGPoint?
	let date: NSDate
	
	init(transformation: CGAffineTransform? = nil
		, point: CGPoint? = nil
		, date: NSDate = NSDate()) {
		self.transformation = transformation
		self.point = point
		self.date = date
	}
}
