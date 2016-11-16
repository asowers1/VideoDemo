//
//  TimedTransformationSliceCoder.swift
//  VideoDemo
//
//  Created by Andrew Sowers on 11/16/16.
//  Copyright © 2016 Andrew Sowers. All rights reserved.
//

import Foundation
import UIKit

class TimedTransformationSliceCoder: NSObject, NSCoding {
	
	typealias Slice = TimedTransformationSlice?
	
	let slice: Slice?
	
	init(timedTransformationSlice: Slice) {
		self.slice = timedTransformationSlice
	}
	
	required init?(coder: NSCoder) {
		if let transformation = coder.decodeObject(forKey: "transformation") as? CGAffineTransform,
		let point = coder.decodeObject(forKey: "point") as? CGPoint,
			let date = coder.decodeObject(forKey: "date") as? NSDate {
			self.slice = TimedTransformationSlice(transformation: transformation, point: point, date: date)
		} else {
			self.slice = nil
		}
		
		super.init()
	}
	
	func encode(with aCoder: NSCoder) {
		aCoder.encode(self.slice??.transformation, forKey: "transformation")
		aCoder.encode(self.slice??.point, forKey: "point")
		aCoder.encode(self.slice??.date, forKey: "date")
	}
}
