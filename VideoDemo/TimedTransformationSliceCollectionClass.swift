//
//  TimedTransformationSliceCollectionClass.swift
//  VideoDemo
//
//  Created by Andrew Sowers on 11/21/16.
//  Copyright © 2016 Andrew Sowers. All rights reserved.
//

import LeanCache

class TimedTransformationSliceCollectionClass {
	let cache: Cache<NSArray>
	
	init(timedTransformationSliceCollection: [TimedTransformationSlice], name: String = "\(TimedTransformationSlice.self)Collection") {
		cache = Cache(name: name)
	}
	
	func get() -> [TimedTransformationSlice]? {
		return (cache.get() as? [TimedTransformationSliceCoder])?.flatMap { $0.slice }
	}
	
	func set(objects: [TimedTransformationSlice]) {
		self.cache.set(objects.map { TimedTransformationSliceCoder(timedTransformationSlice: $0) } as NSArray)
	}
	
	func clear() {
		self.cache.clear()
	}
}
