public extension SignalType {
    /**
     Try to cast `Value` to some type `T`.
     `nil` if the attempt fails.
     Equivalent to map { $0 as? T }
     */
    
    func castTo<T>(_ : T.Type) -> Signal<T?, Error> {
        return map { $0 as? T }
    }
}

public extension SignalProducerType {
    /**
     Try to cast `Value` to some type `T`.
     `nil` if the attempt fails.
     Equivalent to map { $0 as? T }
     */
    
    func castTo<T>(_ : T.Type) -> SignalProducer<T?, Error> {
        return lift { $0.castTo(T) }
    }
    
    /**
     Only forward `NEXT` values when sampler (or its latest value) is true
     */
    
    func filterWhile(sampler: SignalProducer<Bool, NoError>) -> SignalProducer<Value, Error> {
        return combineLatestWith(sampler.promoteErrors(Error)).filter { $0.1 } .map { $0.0 }
    }
}

// MARK: -
// MARK: Extension, Signal (Optional Type)
// MARK: -
extension SignalType where Value: OptionalType {
    /**
     Apply a function that takes a single non-optional value as parameter,
     to a signal(producer) whose `Value` is of `Optional`,
     and preserve the nil values
     
     It's the `Optional.flatMap` in Signal space
     i.e.
     Value.Wrapped -> U?
     Nil           -> Nil
     
     - parameter transform: the function to `map`
     */
    public func fmap<U>(transform: (Value.Wrapped) -> U?) -> Signal<U?, Error> {
        return map { $0.optional.flatMap(transform) }
    }
}

// MARK: -
// MARK: Extension, Signal Producuer (Optional Type)
// MARK: -
extension SignalProducerType where Value: OptionalType {
    /**
     Apply a function that takes a single non-optional value as parameter,
     to a signal(producer) whose `Value` is of `Optional`,
     and preserve the nil values
     
     It's the `Optional.flatMap` in Signal space
     i.e.
     Value.Wrapped -> U?
     Nil           -> Nil
     
     - parameter transform: the function to `map`
     */
    public func fmap<U>(transform: (Value.Wrapped) -> U?) -> SignalProducer<U?, Error> {
        return lift { $0.fmap(transform) }
    }
}

/**
 lazy immutable property which will not start doing work until its `producer` is subscribed to

 - important: observing its `signal` or `value` won't start the property's producer
 
 - note: it would be easy to change the implementation so that observing its `value` will also 
 start its producer.

 */

public class LazyProperty<Value>: PropertyType {
	public let signal: Signal<Value, NoError>
    
	private let _observer: Signal<Value, NoError>.Observer
    private let _underlyingProducer: SignalProducer<Value, NoError>
    private let _lock = NSRecursiveLock()
    
   	public var value: Value {
        get { return withValue { $0 } }
    }
    private var _observed = false
    
    public init(_ initialValue: Value, producer: SignalProducer<Value, NoError>) {
        var value = initialValue
        
        //producer copying
        _underlyingProducer = producer
        
        _lock.name = "org.reactivecocoa.ReactiveCocoa.LazyProperty"
        
        getter = { value }
        
        (signal, _observer) = Signal.pipe()
        
        signal.observeNext { value = $0 }
    }
    
    private let getter: () -> Value
    
    public func withValue<Result>(@noescape action: (Value) throws -> Result) rethrows -> Result {
        _lock.lock()
        defer { _lock.unlock() }
        
        return try action(getter())
    }
    
    private func _startObserving() {
        _lock.lock()
        defer { _lock.unlock() }
        if !_observed {
            _observed = true
            
            _underlyingProducer
                .start(_observer)
        }
    }
    
    public var producer: SignalProducer<Value, NoError> {
        
        return SignalProducer { [getter, weak self] ob, disposable in
            
            defer {
                self?._startObserving()
            }
            
            
            if let strongSelf = self {
                strongSelf.withValue { value in
                    ob.sendNext(value)
                    disposable += strongSelf.signal.observe(ob)
                }
                
            } else {
                ob.sendNext(getter())
                ob.sendCompleted()
            }
            
        }
    }
    
    deinit { _observer.sendCompleted() }
}

public extension SignalProducer where Value: OptionalType {
    static var Nil: SignalProducer<Value.Wrapped?, Error> {
        return SignalProducer<Value.Wrapped?, Error>(value: nil)
    }
}
