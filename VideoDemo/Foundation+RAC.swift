// MARK: -
// MARK: Extension, NSObject
// MARK: -
extension NSObject {
    /**
     A signal producer fired when the receiver is messaged
     */
    public var racutil_willDeallocProducer: SignalProducer<(), NoError> {
        return self.rac_willDeallocSignal()
            .toSignalProducer()
            .map { _ in }
            .ignoreError()
    }
    
    public var racutil_willDeallocSignal: Signal<(), NoError> {
        return Signal {[weak self] in
            if let strongSelf = self {
                return strongSelf.racutil_willDeallocProducer.start($0)
            } else {
                $0.sendCompleted()
                return nil
            }
        }
    }
}

import SwiftyUserDefaults

// MARK: -
// MARK: Extension, Defaults Key
// MARK: -
public extension DefaultsKey where ValueType: OptionalType {
    /// - parameter signalProducer: A computed property that
    /// returns a signal producer which reflects the changes to `self`.
    var racutil_signalProducer: SignalProducer<ValueType.Wrapped?, NoError> {
        get {
            return NSUserDefaults.standardUserDefaults().rac_channelTerminalForKey(_key)
            .toSignalProducer()
            .ignoreError()
            .castTo(ValueType.Wrapped.self)
        }
    }
}
