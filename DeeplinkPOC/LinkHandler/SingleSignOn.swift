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
    static func login(using link: Link) -> SignalProducer<LoginStatus, NoError> {
        switch link.authorization {
        case .singleSignOn(with: _):
            return SignalProducer<LoginStatus, NoError>(value: .loggedIn).delay(0.5, on: QueueScheduler.main).logEvents(identifier: "SSO_URL")
        default:
            return SignalProducer(value: .notNeeded)
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
