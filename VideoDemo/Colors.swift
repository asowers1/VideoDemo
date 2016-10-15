import UIKit

class Colors {
	let colorTop = UIColor(red: 60.0/255.0, green: 67.0/255.0, blue: 83.0/255.0, alpha: 1.0).cgColor
	let colorBottom = UIColor(red: 49.0/255.0, green: 55.0/255.0, blue: 65.0/255.0, alpha: 1.0).cgColor
	
	let defaultGradient: CAGradientLayer
	
	init() {
		defaultGradient = CAGradientLayer()
		defaultGradient.colors = [ colorTop, colorBottom]
		defaultGradient.locations = [ 0.0, 1.0]
	}
}
