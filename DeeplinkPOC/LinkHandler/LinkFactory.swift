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

public struct LinkFactory {
    private struct DeepLinkParser {
        static func parse(_ url: URL) -> SignalProducer<Link?, NoError> {
            print("Parsed deep link")
            return url.absoluteString.contains("sso")
                ? SignalProducer.init(value: Link(intent: .item(id: "dl::1"), authorization: .singleSignOn(with: url)))
                : SignalProducer.init(value:Link(intent: .item(id: "dl::1")))
        }
    }
    
    private struct UniversalLinkParser {
        static func parse(_ userActivity: NSUserActivity) -> SignalProducer<Link?, NoError> {
            guard userActivity.activityType == NSUserActivityTypeBrowsingWeb else { return SignalProducer.init(value: nil) }
            
            print("Parsed universal link")
            return SignalProducer.init(value: Link(intent:.item(id: "ul::1")))
        }
    }
    
    private struct ShortcutParser {
        static func parse(_ userActivity: NSUserActivity) -> SignalProducer<Link?, NoError> {
            guard userActivity.activityType == "ForceTouchType" else { return SignalProducer.init(value: nil) }
            
            print("Parsed shortcut")
            return SignalProducer.init(value: Link(intent: .item(id: "s::1")))
        }
    }
    
    private struct SpotlightParser {
        static func parse(_ userActivity: NSUserActivity) -> SignalProducer<Link?, NoError> {
            guard userActivity.activityType == CSSearchableItemActionType else { return SignalProducer.init(value: nil) }
            
            print("Parsed spotlight")
            return SignalProducer.init(value: Link(intent: .item(id: "sl::1")))
        }
    }
    
    private struct PushParser {
        static func parse(_ pushDictionary: [String : String]) -> SignalProducer<Link?, NoError> {
            print("Parsed push")
            return SignalProducer.init(value: Link(intent: .item(id: "p::1")))
        }
    }
    
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
