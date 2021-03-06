//
//  LinkDispatcher.swift
//  LinkHandler
//
//  Created by Kamil Tustanowski on 05.04.2018.
//  Copyright © 2018 ktustanowski. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result

public protocol LinkDispatcherDelegate {
    func willStartLinking()
    func link(with link: Link)
}

public struct LinkDispatcher {
    var delegate: LinkDispatcherDelegate?
    
    public init(delegate: LinkDispatcherDelegate) {
        self.delegate = delegate
    }
    
    public func handle(_ userActivity: NSUserActivity) {
        delegate?.willStartLinking()
        
        let linkProducer = LinkFactory.make(with: userActivity)
        startLinkFlow(with: linkProducer)
    }
    
    public func handle(_ url: URL) {
        delegate?.willStartLinking()
        
        let linkProducer = LinkFactory.make(with: url)
        startLinkFlow(with: linkProducer)
    }
    
    public func handle(_ info: [AnyHashable : Any]) {
        delegate?.willStartLinking()
        
        let linkProducer = LinkFactory.make(with: info)
        startLinkFlow(with: linkProducer)
    }

    public func handle(_ shortcutItem: UIApplicationShortcutItem) {
        delegate?.willStartLinking()
        
        let linkProducer = LinkFactory.make(with: shortcutItem)
        startLinkFlow(with: linkProducer)
    }
    
    private func startLinkFlow(with linkProducer: SignalProducer<Link?, NoError>) {
        let _ = linkProducer
            .skipNil()
            .take(first: 1)
            .logEvents(identifier: "LPP")
            .flatMap(.latest) { link in
            // Any other operation that needs to be done before linking flow
            // commences can be added to the zip
            SignalProducer.zip(ConfigurationProvider.load(), //load some config file
                               SingleSignOn.login(using: link), //try to login using SSO flow
                               BeaconPoster.post(with: link),
                               SignalProducer(value: link)) // just pass the link
            }.startWithResult { result in
                switch result {
                case .success(let (_, ssoLoginStatus, _, link)):
                    self.delegate?.link(with: Link(intent: link.intent,
                                                   authorization: link.authorization,
                                                   didAuthorize: ssoLoginStatus == .loggedIn ))
                case .failure(let error):
                    print("\(error)")
                }
        }
    }
}

/// Some pre-linking-needed config loading
struct ConfigurationProvider {
    static func load() -> SignalProducer<Bool, NoError> {
        return SignalProducer(value: true).delay(1.0, on: QueueScheduler.main).logEvents(identifier: "CP")
    }
}

/// Ssync stuff needed for some links
struct BeaconPoster {
    static func post(with link: Link) -> SignalProducer<Bool, NoError> {
        guard link.intent == .postBeacon else { return SignalProducer(value: false) }
        
        return SignalProducer(value: true).delay(1.0, on: QueueScheduler.main).logEvents(identifier: "CP")
    }
}

func dispatchAfter(_ delay: Double, closure: @escaping () -> ()) {
    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
        closure()
    }
}
