import UIKit

public protocol NibType: class {
}

extension NibType {
	/// "Valencia.WhateverTheHellCell.Type" -> "WhateverTheHellCell"
	/// override in accordance with your xib file name
	public static var nibName: String {
		let x = String(describing: Self.Type.self).components(separatedBy: ".")
		precondition(x.count > 1,
		             "type name \(Self.Type.self) is not expected. Override nibName in your own protocol extension")
		return x[x.count-2]
	}
	
	#if os(iOS)
	public static var nib: UINib {
		return UINib(nibName: nibName, bundle: Bundle.main)
	}
	#endif
}


//MARK: ReusableType
public protocol ReusableType { }

extension NibType where Self: ReusableType {
	public static var reuseIdentifier: String {
		return nibName + "ReuseIdentifier"
	}
}

open class MessageOverlay: UIView, NibType {
    @IBOutlet weak var title: UILabel!
    
    open class func instanitiate() -> MessageOverlay {
        guard let v = nib.instantiate(withOwner: nil, options: nil).first as? MessageOverlay
            else { fatalError() }
        return v
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        title.font = UIFont.systemFont(ofSize: 20.0)
        title.textColor = UIColor.white
    }
    
    override open func draw(_ rect: CGRect) {
        let l = CAShapeLayer()
        l.path = UIBezierPath(roundedRect: rect, byRoundingCorners: [.bottomLeft, .bottomRight], cornerRadii: CGSize(width: 15, height: 10)).cgPath
        
        layer.mask = l
    }
    
    open func displayOn(_ viewController: UIViewController) {
        removeFromSuperview()
        viewController.view.addSubview(self)
        viewController.view.bringSubview(toFront: self)
        
        translatesAutoresizingMaskIntoConstraints = false
        topAnchor.constraint(equalTo: viewController.topLayoutGuide.bottomAnchor).isActive = true
        centerXAnchor.constraint(equalTo: viewController.view.centerXAnchor).isActive = true
        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    
    open func remove() {
        removeFromSuperview()
        UIApplication.shared.endIgnoringInteractionEvents()
    }
}

public extension UIViewController {
    func displayMessage(_ message: String, duration: TimeInterval = 2, completion: (()->Void)? = nil) {
        let v = MessageOverlay.instanitiate()
        v.title.text = message
        v.displayOn(self)
        UIView.animate(withDuration: 0.3, delay: duration, options: [], animations: {
            v.alpha = 0
        }) { _ in
            v.remove()
            completion?()
        }
    }
}
