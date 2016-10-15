//
//  Storyboard.swift
//  VideoDemo
//
//  Created by Andrew Sowers on 10/15/16.
//  Copyright © 2016 Andrew Sowers. All rights reserved.
//

import Foundation

protocol StoryboardType {
	static var Identifier: String { get }
}

protocol SceneIdentifiersType {
	static var MainViewController: String { get }
}

struct Storyboard {
	struct Main: StoryboardType {
		static var Identifier: String = "Main"
		struct SceneIdentifiers: SceneIdentifiersType {
			static let DemoViewController = "DemoViewController"
			static var MainViewController: String = DemoViewController
		}
	}
}
