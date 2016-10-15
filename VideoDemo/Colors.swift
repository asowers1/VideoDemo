import UIKit

struct Colors {
	static let NavigationNeonPink = UIColor(red: 177.0/255.0, green: 32.0/255.0, blue: 120.0/255.0, alpha: 1.0)
	static let ColorTop = UIColor(red: 60.0/255.0, green: 67.0/255.0, blue: 83.0/255.0, alpha: 1.0).cgColor
	static let ColorBottom = UIColor(red: 49.0/255.0, green: 55.0/255.0, blue: 65.0/255.0, alpha: 1.0).cgColor
	
	static var DefaultGradient: CAGradientLayer {
		let dg = CAGradientLayer()
		dg.colors = [ ColorTop, ColorBottom]
		dg.locations = [ 0.0, 1.0]
		return dg
	}
	
}
