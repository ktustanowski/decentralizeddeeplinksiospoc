//
//  SingleSignOn.swift
//  LinkHandler
//
//  Created by Kamil Tustanowski on 05.04.2018.
//  Copyright © 2018 ktustanowski. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result

public struct SingleSignOn {
    public static func login(using link: Link) -> SignalProducer<LoginStatus, NoError> {
        switch link.authorization {
        case .singleSignOn(with: _):
            return SignalProducer<LoginStatus, NoError> {observer, _ in
                dispatchAfter(0.5) {
                    observer.send(value: .loggedIn)
                    observer.sendCompleted()
                }
                }.logEvents(identifier: "SSO_URL")
        default:
            return SignalProducer.init(value: .notNeeded)
        }
    }
}

public extension SingleSignOn {
    public enum LoginStatus {
        case notNeeded
        case failed
        case loggedIn
    }
}
