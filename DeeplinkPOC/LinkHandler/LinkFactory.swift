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

//dlpoc://settings
//dlpoc://settings/login
//dlpoc://settings/legal
//dlpoc://settings/tc

private struct DeepLinkParser {
    static func parse(_ url: URL) -> SignalProducer<Link?, NoError> {
        guard let rootName = url.host else { return .empty }
        let components = url.pathComponents.filter{ $0 != "/"}

        switch rootName {
        case "Item":
            guard let parentNumber = components.first else { return .empty }
            let parentId = "\(rootName) \(parentNumber)"
            let authorization = url.absoluteString.contains("sso") ? Link.Authorization.singleSignOn(with: url) : Link.Authorization.none
            
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

//import Foundation
//import ReactiveSwift
//import Result
//import CoreSpotlight
//
//enum LinkParserError: Error {
//    case unrecognized
//}
//
//public struct LinkFactory {
//    private struct DeepLinkParser {
//        static func parse(_ url: URL) -> SignalProducer<RegularLink?, NoError> {
//            print("Parsed deep link")
//            return url.absoluteString.contains("sso")
//                ? SignalProducer.init(value: RegularLink(intent: .item(id: "dl::1"), authorization: .singleSignOn(with: url)))
//                : SignalProducer.init(value:RegularLink(intent: .item(id: "dl::1")))
//        }
//    }
//    
//    private struct UniversalLinkParser {
//        static func parse(_ userActivity: NSUserActivity) -> SignalProducer<RegularLink?, NoError> {
//            guard userActivity.activityType == NSUserActivityTypeBrowsingWeb else { return SignalProducer.init(value: nil) }
//            
//            print("Parsed universal link")
//            return SignalProducer.init(value: RegularLink(intent:.item(id: "ul::1")))
//        }
//    }
//    
//    private struct ShortcutParser {
//        static func parse(_ userActivity: NSUserActivity) -> SignalProducer<RegularLink?, NoError> {
//            guard userActivity.activityType == "ForceTouchType" else { return SignalProducer.init(value: nil) }
//            
//            print("Parsed shortcut")
//            return SignalProducer.init(value: RegularLink(intent: .item(id: "s::1")))
//        }
//    }
//    
//    private struct SpotlightParser {
//        static func parse(_ userActivity: NSUserActivity) -> SignalProducer<RegularLink?, NoError> {
//            guard userActivity.activityType == CSSearchableItemActionType else { return SignalProducer.init(value: nil) }
//            
//            print("Parsed spotlight")
//            return SignalProducer.init(value: RegularLink(intent: .item(id: "sl::1")))
//        }
//    }
//    
//    private struct PushParser {
//        static func parse(_ pushDictionary: [String : String]) -> SignalProducer<RegularLink?, NoError> {
//            print("Parsed push")
//            return SignalProducer.init(value: RegularLink(intent: .item(id: "p::1")))
//        }
//    }
//    
//    public static func make(with userActivity: NSUserActivity) -> SignalProducer<RegularLink?, NoError> {
//        return SignalProducer.merge(SpotlightParser.parse(userActivity).logEvents(identifier: "SL"),
//                                    UniversalLinkParser.parse(userActivity).logEvents(identifier: "UL"),
//                                    ShortcutParser.parse(userActivity).logEvents(identifier: "SC"))
//    }
//    
//    public static func make(with url: URL) -> SignalProducer<RegularLink?, NoError> {
//        return DeepLinkParser.parse(url).logEvents(identifier: "DL")
//    }
//    
//    public static func make(with info: [String: String]) -> SignalProducer<RegularLink?, NoError> {
//        return PushParser.parse(info)
//    }
//}

