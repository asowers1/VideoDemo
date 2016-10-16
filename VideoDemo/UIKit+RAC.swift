// MARK: -
// MARK: Extension, UIControl
// MARK: -
extension UIControl {
    @warn_unused_result(message="Did you forget to call `start` on the producer?")
    //FIXME: make it return SignalProducer<Self, NoError>
    public func racutil_signalProducer(ForControlEvents controlEvents: UIControlEvents) -> SignalProducer<(), NoError> {
        return rac_signalForControlEvents(controlEvents)
            .takeUntil(rac_willDeallocSignal())
            .toSignalProducer()
            .ignoreError()
            .map { _ in }
    }
}

// MARK: -
// MARK: Extension, UIControl
// MARK: -
extension UITextField {
    /**
     Creates a producer that sends the receiver's current value of `text` upon
     being changed.
     */
    public var racutil_textSignalProducer: SignalProducer<String?, NoError> {
        return rac_textSignal().toSignalProducer()
            .map { $0 as? String }
            .ignoreError()
    }
    
    /**
     Merges _start_ & _end_ signal states fired while the receiver is being edited.
     */
    public var racutil_isEditingProducer: SignalProducer<Bool, NoError> {
        let beginEditing: SignalProducer<Bool, NoError> = rac_signalForControlEvents(.EditingDidBegin)
            .toSignalProducer()
            .ignoreError()
            .map { _ in true }
        
        let endEditing: SignalProducer<Bool, NoError> = rac_signalForControlEvents(.EditingDidEnd)
            .toSignalProducer()
            .ignoreError()
            .map { _ in false }
        
        return SignalProducer(values: [beginEditing, endEditing])
            .flatten(.Merge)
    }
    
}

// MARK: -
// MARK: Extension, Table View Cell
// MARK: -
extension UITableViewCell {
    var racutil_prepareForReuseProducer: SignalProducer<(), NoError> {
        return self.rac_prepareForReuseSignal
            .toSignalProducer()
            .map { _ in }
            .ignoreError()
    }
}

// MARK: -
// MARK: Extension, Table Header View
// MARK: -
extension UITableViewHeaderFooterView {
    var racutil_prepareForReuseProducer: SignalProducer<(), NoError> {
        return rac_prepareForReuseSignal
            .toSignalProducer()
            .map { _ in }
            .ignoreError()
    }
}

// MARK: -
// MARK: Extension, Collection View Cell
// MARK: -
extension UICollectionViewCell {
    var racutil_prepareForReuseProducer: SignalProducer<(), NoError> {
        return self.rac_prepareForReuseSignal
            .toSignalProducer()
            .map { _ in }
            .ignoreError()
    }
}

// MARK: -
// MARK: AssociationKey for associated properties
// MARK: -

struct AssociationKey {
    static var hidden: UInt8 = 1
    static var alpha: UInt8 = 2
    static var text: UInt8 = 3
}

// MARK: -
// MARK: lazily creates a gettable associated property via the given factory
// MARK: -

func lazyAssociatedProperty<T: AnyObject>(host: AnyObject, key: UnsafePointer<Void>, factory: ()->T) -> T {
    return objc_getAssociatedObject(host, key) as? T ?? {
        let associatedProperty = factory()
        objc_setAssociatedObject(host, key, associatedProperty, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        return associatedProperty
        }()
}

func lazyMutableProperty<T>(host: AnyObject, key: UnsafePointer<Void>, setter: T -> (), getter: () -> T) -> MutableProperty<T> {
    return lazyAssociatedProperty(host, key: key) {
        let property = MutableProperty<T>(getter())
        property.producer
            .startWithNext{
                newValue in
                setter(newValue)
        }
        
        return property
    }
}

// MARK: -
// MARK: UIKit Extensions for MutableProperty bindings e.g. UIView.rac_hidden <~ true
// MARK: -

extension UIView {
    public var rac_alpha: MutableProperty<CGFloat> {
        return lazyMutableProperty(self, key: &AssociationKey.alpha, setter: { [unowned self] in self.alpha = $0 }, getter: { [unowned self] in self.alpha  })
    }
    
    public var rac_hidden: MutableProperty<Bool> {
        return lazyMutableProperty(self, key: &AssociationKey.hidden, setter: { [unowned self] in self.hidden = $0 }, getter: { [unowned self] in self.hidden  })
    }
}

extension UILabel {
    public var rac_text: MutableProperty<String> {
        return lazyMutableProperty(self, key: &AssociationKey.text, setter: { [unowned self] in self.text = $0 }, getter: { [unowned self] in self.text ?? "" })
    }
}

extension UIImageView {
    public var rac_image: MutableProperty<UIImage?> {
        return lazyMutableProperty(self
            , key: &AssociationKey.text
            , setter: { [weak self] in
                self?.image = $0
                self?.setNeedsDisplay()
            }
            , getter: { [weak self] in
                self?.image
            })
    }
}

extension UITextField {
    public var rac_text: MutableProperty<String> {
        return lazyAssociatedProperty(self, key: &AssociationKey.text) {
            
            self.addTarget(self, action: #selector(self.changed), forControlEvents: UIControlEvents.EditingChanged)
            
            let property = MutableProperty<String>(self.text ?? "")
            property.producer
                .startWithNext {
                    newValue in
                    self.text = newValue
            }
            return property
        }
    }
    
    func changed() {
        rac_text.value = self.text ?? ""
    }
}
