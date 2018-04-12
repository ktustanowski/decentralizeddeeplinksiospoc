//
//  LinkFactory.swift
//  DeeplinkPOC
//
//  Created by Kamil Tustanowski on 05.04.2018.
//  Copyright © 2018 ktustanowski. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result
import CoreSpotlight

enum LinkParserError: Error {
    case unrecognized
}

//dlpoc://Settings
//dlpoc://Settings/Login
//dlpoc://Settings/Legal
//dlpoc://Settings/Tc

//dlpoc://Item/3/Content/5
//dlpoc://Item/6/Content/7
//dlpoc://Item/6/Content/7?sso=go

//dlpoc://Item/3/Promo/5
//dlpoc://Item/6/Promo/7

//dlpoc://Beacon?sso=go

public struct LinkFactory {
    public static func make(with userActivity: NSUserActivity) -> SignalProducer<Link?, NoError> {
        return SignalProducer.merge(SpotlightParser.parse(userActivity).logEvents(identifier: "SL"),
                                    UniversalLinkParser.parse(userActivity).logEvents(identifier: "UL"))
    }
    
    public static func make(with shortcutItem: UIApplicationShortcutItem) -> SignalProducer<Link?, NoError> {
        return ShortcutParser.parse(shortcutItem).logEvents(identifier: "SC")
    }

    public static func make(with url: URL) -> SignalProducer<Link?, NoError> {
        return DeepLinkParser.parse(url).logEvents(identifier: "DL")
    }
    
    public static func make(with info: [AnyHashable : Any]) -> SignalProducer<Link?, NoError> {
        return PushParser.parse(info)
    }
}

private struct DeepLinkParser {
    static func parse(_ url: URL) -> SignalProducer<Link?, NoError> {
        guard let rootName = url.host else { return .empty }
        let components = url.pathComponents.filter{ $0 != "/"}

        let authorization = url.absoluteString.contains("sso") ? Link.Authorization.singleSignOn(with: url) : Link.Authorization.none
        switch rootName {
        case "Item":
            guard let parentNumber = components.first else { return .empty }
            let parentId = "\(rootName) \(parentNumber)"
            
            if components.count == 3 {
                let childId = "\(parentId) \(components[1]) \(components[2])"
                if childId.contains("Content") {
                    return SignalProducer(value: Link(intent: .showContent(id: childId, parentId: parentId), authorization: authorization))
                } else if childId.contains("Promo") {
                    return SignalProducer(value: Link(intent: .showPromos(id: childId, parentId: parentId), authorization: authorization))
                } else {
                    return .empty
                }
            } else {
                return SignalProducer(value: Link(intent: .showItem(id: parentId), authorization: authorization))
            }
        case "Settings":
            guard let subScreen = components.last else {
                return SignalProducer(value: Link(intent: .showSettings, authorization: authorization))
            }
            
            switch subScreen {
            case "Legal":
                return SignalProducer(value: Link(intent: .showLegal, authorization: authorization))
            case "Login":
                return SignalProducer(value: Link(intent: .showLogin, authorization: authorization))
            case "Tc":
                return SignalProducer(value: Link(intent: .showTermsConditions, authorization: authorization))
            default:
                return SignalProducer(value: Link(intent: .showSettings, authorization: authorization))
            }
        case "Beacon":
            return SignalProducer(value: Link(intent: .postBeacon, authorization: authorization))
        default:
            return .empty
        }
    }
}

private struct UniversalLinkParser {
    static func parse(_ userActivity: NSUserActivity) -> SignalProducer<Link?, NoError> {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb else { return .empty }
        
        return SignalProducer(value: Link(intent:.showItem(id: "STUB_IMPLEMENTATION")))
    }
}

private struct ShortcutParser {
    static func parse(_ shortcutItem: UIApplicationShortcutItem) -> SignalProducer<Link?, NoError> {
        switch shortcutItem.type {
        case "poc.dl.shortcut.recent":
            // Let's pretend this is the recently visited item to make this clear
            return SignalProducer(value: Link(intent:.showContent(id: "Item 8 Content 5", parentId: "Item 8")))
        case "poc.dl.shortcut.login":
            return SignalProducer(value: Link(intent:.showLogin))
        default:
            return .empty
        }
    }
}

private struct SpotlightParser {
    static func parse(_ userActivity: NSUserActivity) -> SignalProducer<Link?, NoError> {
        guard userActivity.activityType == CSSearchableItemActionType else { return .empty }
        
        return SignalProducer(value: Link(intent: .showItem(id: "STUB_IMPLEMENTATION")))
    }
}

private struct PushParser {
    static func parse(_ pushPayload: [AnyHashable : Any]) -> SignalProducer<Link?, NoError> {
        return SignalProducer(value: Link(intent: .showItem(id: "STUB_IMPLEMENTATION")))
    }
}
