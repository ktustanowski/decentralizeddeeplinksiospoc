//
//  LinkHandler.swift
//  LinkHandler
//
//  Created by Kamil Tustanowski on 05.04.2018.
//  Copyright © 2018 ktustanowski. All rights reserved.
//

import Foundation

public enum LinkHandling: CustomStringConvertible {
    
    // deeplink successfully handled
    case opened(Link)
    
    // deeplink was rejected because it can't be handeled, with optional log message
    case rejected(Link, String?)
    
    // deeplink handling delayed because more data is needed
    case delayed(Link, Bool)
    
    // deeplink was passed through to some other handler
    case passedThrough(Link)
    
    public var inProgress: Bool {
        switch self {
        case .delayed(_, _):
            return true
        default:
            return false
        }
    }
    
    public var description: String {
        switch self {
        case .opened(let deeplink):
            return "Opened deeplink \(deeplink)"
        case .rejected(let deeplink, let reason):
            return "Rejected deeplink \(deeplink) for reason : \(reason ?? "unknown")"
        case .delayed(let deeplink, _):
            return "Delayed deeplink \(deeplink)"
        case .passedThrough(let deeplink):
            return "Passed through deeplink \(deeplink)"
        }
    }
}

public protocol LinkHandler: class {
    // stores the current state of deeplink handling
    var linkHandling: LinkHandling? { get set }
    // attempts to handle deeplink and returns next state
    func process(link: Link, animated: Bool) -> LinkHandling
}

public extension LinkHandler {
    
    // Attempts to handle deeplink and updates its state,
    // should be always called instead of method that returns state
    public func open(link: Link, animated: Bool) {
        let result = process(link: link, animated: animated)
        print(result)
        // ANALYTICS TIP: we can track deeplink process from here
        linkHandling = result.inProgress ? result : nil
    }
        
    // Call to complete deeplink handling if it was delayed
    public func completeLinking(or alternative: (() -> Void)? = nil) { // maybe add sth like completeLinkingOr { } <- completion handler if completion wasn't needed
        if case let .delayed(link, animated)? = self.linkHandling {
            open(link: link, animated: animated) as Void
            if case .delayed? = self.linkHandling { return }
        } else {
            alternative?()
        }
    }
}

public extension UIViewController {
    public func pass(link: Link?, animated: Bool) {
        guard let linkHandler = self as? LinkHandler,
            let link = link else { return }
        
        linkHandler.open(link: link, animated: animated)
    }
}
