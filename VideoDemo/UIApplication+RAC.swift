private var _didLaunchProperty: AnyProperty<(UIApplication, [NSObject:AnyObject]?)>?

// MARK: -
// MARK: Extension, Application Delegate
// MARK: -
public extension UIApplicationDelegate where Self: NSObject {
    /// - parameter didLaunch: A property lifted from the receiver's `(_:didFinishLaunchingWithOptions)` message.
    var didLaunch: AnyProperty<(UIApplication, [NSObject:AnyObject]?)> {
        if _didLaunchProperty == nil {
            let didFinishSignal = RACSignal.`defer` {self
                .rac_signalForSelector(#selector(UIApplicationDelegate.application(_:didFinishLaunchingWithOptions:)), fromProtocol: NSProtocolFromString("UIApplicationDelegate"))
                .distinctUntilChanged()
                .takeUntil(self.rac_willDeallocSignal())
            }
            
            let producer = didFinishSignal
                .toSignalProducer()
                .attemptMap { next -> Result<(UIApplication, Dictionary<NSObject, AnyObject>?), NSError> in
                    if let tuple = next as? RACTuple,
                        let app = tuple.first as? UIApplication {
                        let launchOptions = tuple.last as? [NSObject:AnyObject]
                        let result: (UIApplication, [NSObject:AnyObject]?) = (app, launchOptions)
                        return .Success(result)
                    }
                    return .Failure(NSError(domain: "", code: 0, userInfo: nil))
                }
                .flatMapError { _ in
                    SignalProducer<(UIApplication, [NSObject:AnyObject]?), NoError>.empty
            }
            
            _didLaunchProperty = AnyProperty(initialValue: (UIApplication.sharedApplication(), nil), producer: producer)
        }
        return _didLaunchProperty!
    }
}

private var _isActiveProperty: AnyProperty<Bool>?

// MARK: -
// MARK: Extension, Application Delegate
// MARK: -
public extension UIApplicationDelegate where Self: NSObject {
    /// - parameter isActive: A property lifted from the receiver's `(_:didBecomActive)` & `(_:didEnterBackground)` messages.
    var isActive: AnyProperty<Bool> {
        if _isActiveProperty == nil {
            let mergedDelegateSignals = RACSignal.merge([
                self.rac_signalForSelector(#selector(UIApplicationDelegate.applicationDidBecomeActive(_:)), fromProtocol: NSProtocolFromString("UIApplicationDelegate")).mapReplace(true),
                self.rac_signalForSelector(#selector(UIApplicationDelegate.applicationDidEnterBackground(_:)), fromProtocol: NSProtocolFromString("UIApplicationDelegate")).mapReplace(false)
                ])
                .distinctUntilChanged()
                .startWith(false)
                .takeUntil(self.rac_willDeallocSignal())
            
            let producer = mergedDelegateSignals
                .toSignalProducer()
                .attemptMap { (input: AnyObject?) -> Result<Bool, NSError> in
                    if let state = input as? Bool {
                        return .Success(state)
                    }
                    return .Failure(NSError(domain: "", code: 0, userInfo: nil))
                }
                .flatMapError { _ in SignalProducer<Bool, NoError>.empty }
            _isActiveProperty = AnyProperty(initialValue: false, producer:producer)
        }
        return _isActiveProperty!
    }
}
