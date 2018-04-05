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
    
    public enum Authorization {
        case none
        case singleSignOn(with: Any)
    }
    
    public enum Intent {
        case item(id: String)
        case showContent(id: String, parentId: String)
        case showPromos(id: String, parentId: String)
        case showSettings
        case showLogin
        case showTermsConditions
        case showLegal
    }
    
    init(intent: Intent, authorization: Authorization = .none) {
        self.intent = intent
        self.authorization = authorization
    }
}
