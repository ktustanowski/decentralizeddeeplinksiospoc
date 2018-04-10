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


public struct LinkFactory {
    public static func make(with userActivity: NSUserActivity) -> SignalProducer<Link?, NoError> {
        return SignalProducer.merge(SpotlightParser.parse(userActivity).logEvents(identifier: "SL"),
                                    UniversalLinkParser.parse(userActivity).logEvents(identifier: "UL"),
                                    ShortcutParser.parse(userActivity).logEvents(identifier: "SC"))
    }
    
    public static func make(with url: URL) -> SignalProducer<Link?, NoError> {
        return DeepLinkParser.parse(url).logEvents(identifier: "DL")
    }
    
    public static func make(with info: [String: String]) -> SignalProducer<Link?, NoError> {
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
                    return SignalProducer.init(value: Link(intent: .showContent(id: childId, parentId: parentId), authorization: authorization))
                } else if childId.contains("Promo") {
                    return SignalProducer.init(value: Link(intent: .showPromos(id: childId, parentId: parentId), authorization: authorization))
                } else {
                    return .empty
                }
            } else {
                return SignalProducer.init(value: Link(intent: .showItem(id: parentId), authorization: authorization))
            }
        case "Settings":
            guard let subScreen = components.last else {
                return SignalProducer.init(value: Link(intent: .showSettings, authorization: authorization))
            }
            
            switch subScreen {
            case "Legal":
                return SignalProducer.init(value: Link(intent: .showLegal, authorization: authorization))
            case "Login":
                return SignalProducer.init(value: Link(intent: .showLogin, authorization: authorization))
            case "Tc":
                return SignalProducer.init(value: Link(intent: .showTermsConditions, authorization: authorization))
            default:
                return SignalProducer.init(value: Link(intent: .showSettings, authorization: authorization))
            }
        default:
            return .empty
        }
    }
}

private struct UniversalLinkParser {
    static func parse(_ userActivity: NSUserActivity) -> SignalProducer<Link?, NoError> {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb else { return SignalProducer.init(value: nil) }
        
        return SignalProducer.init(value: Link(intent:.showItem(id: "ul::1")))
    }
}

private struct ShortcutParser {
    static func parse(_ userActivity: NSUserActivity) -> SignalProducer<Link?, NoError> {
        guard userActivity.activityType == "ForceTouchType" else { return SignalProducer.init(value: nil) }
        
        return SignalProducer.init(value: Link(intent: .showItem(id: "s::1")))
    }
}

private struct SpotlightParser {
    static func parse(_ userActivity: NSUserActivity) -> SignalProducer<Link?, NoError> {
        guard userActivity.activityType == CSSearchableItemActionType else { return SignalProducer.init(value: nil) }
        
        return SignalProducer.init(value: Link(intent: .showItem(id: "sl::1")))
    }
}

private struct PushParser {
    static func parse(_ pushDictionary: [String : String]) -> SignalProducer<Link?, NoError> {
        return SignalProducer.init(value: Link(intent: .showItem(id: "p::1")))
    }
}
