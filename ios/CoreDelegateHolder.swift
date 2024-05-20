import Foundation

@objc public class CoreDelegateHolder: NSObject {
    static let shared = { CoreDelegateHolder() }()
    
    var delegateRespondsTo: (didReceiveNotificationEvent: Bool, somethning: Bool)? = nil
    
    var pendingEvents: [NSDictionary] = []
    private var _delegate: CoreDelegate? = nil
    @objc public var delegate: CoreDelegate? {
        get { return _delegate }
        set {
            if newValue === _delegate {
                return
            }
            if let newValue = newValue {
                let didReceiveGuuCoreEventSelector = #selector(didReceiveGuuCoreEvent(_:))
                delegateRespondsTo = (newValue.responds(to: didReceiveGuuCoreEventSelector), false)
            }
            if(pendingEvents.count > 0) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.pendingEvents.forEach { event in
                        self.didReceiveGuuCoreEvent(event)
                    }
                    self.pendingEvents = []
                }
            }
            _delegate = newValue
            
        }
    }
    
    @objc public class func instance() -> CoreDelegateHolder {
        return CoreDelegateHolder.shared
    }
    
    @objc public func didReceiveGuuCoreEvent(_ event: NSDictionary) {
        if let repondsTo = self.delegateRespondsTo?.didReceiveNotificationEvent, repondsTo {
            self.delegate?.didReceiveGuuCoreEvent?(event as! [AnyHashable : Any])
        } else {
            self.pendingEvents.append(event)
        }
    }
}
