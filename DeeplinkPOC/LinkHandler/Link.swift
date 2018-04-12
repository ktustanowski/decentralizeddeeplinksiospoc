//
//  Link.swift
//  DeeplinkPOC
//
//  Created by Kamil Tustanowski on 05.04.2018.
//  Copyright © 2018 ktustanowski. All rights reserved.
//

import Foundation

public struct Link {
    public let intent: Intent
    public let authorization: Authorization
    public let didAuthorize: Bool
    
    public enum Authorization {
        case none
        case singleSignOn(with: Any)
    }
    
    public enum Intent {
        case showItem(id: String)
        case showContent(id: String, parentId: String)
        case showPromos(id: String, parentId: String)
        case showSettings
        case showLogin
        case showTermsConditions
        case showLegal
        case postBeacon
    }
    
    public init(intent: Intent, authorization: Authorization = .none, didAuthorize: Bool = false) {
        self.intent = intent
        self.authorization = authorization
        self.didAuthorize = didAuthorize
    }
}

extension Link.Intent: Equatable {}

public func ==(lhs: Link.Intent, rhs: Link.Intent) -> Bool {
    switch (lhs, rhs) {
    case (.showItem(let leftId), .showItem(let rightId)):
        return leftId == rightId
    case (.showContent(let leftId, let leftParentId), .showContent(let rightId, let rightParentId)):
        return leftId == rightId && leftParentId == rightParentId
    case (.showPromos(let leftId, let leftParentId), .showPromos(let rightId, let rightParentId)):
        return leftId == rightId && leftParentId == rightParentId
    case (.showSettings, .showSettings):
        return true
    case (.showLogin, .showLogin):
        return true
    case (.showTermsConditions, .showTermsConditions):
        return true
    case (.showLegal, .showLegal):
        return true
    case (.postBeacon, .postBeacon):
        return true        
    default:
        return false
    }
}
