// MARK: -
// MARK: URL to Data
// MARK: -
extension SignalProducerType where Value == NSURL, Error == NoError {
    public func racutil_urlToData() -> SignalProducer<NSData, NoError> {
        return map(Optional.init)
            .racutil_urlToData()
            .ignoreNil()
    }
}

// MARK: -
// MARK: URL? to Data?
// MARK: -
extension SignalProducerType where Value: OptionalType, Value.Wrapped == NSURL, Error == NoError {
    public func racutil_urlToData() -> SignalProducer<NSData?, NoError> {
        return fmap(NSURLRequest.init(URL:))
            .fmap(NSURLSession.sharedSession().rac_dataWithRequest)
            .map { $0?.map(Optional.init) ?? SignalProducer(value: nil) }
            .map { $0.ignoreError() }
            //FIXME: error handling
            .flatten(.Latest) .fmap { $0.0 }
    }
}
