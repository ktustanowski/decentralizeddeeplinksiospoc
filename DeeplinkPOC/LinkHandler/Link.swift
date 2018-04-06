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
    }
    
    init(intent: Intent, authorization: Authorization = .none, didAuthorize: Bool = false) {
        self.intent = intent
        self.authorization = authorization
        self.didAuthorize = didAuthorize
    }
}

//protocol AuthorizableLink {
//    var authorization: AuthorizableLink.Authorization { get }
//}
//
//public extension AuthorizableLink {
//    public enum Authorization {
//        case none
//        case singleSignOn(with: Any)
//    }
//}
//
//public protocol IntentableLink {
//    var intent: IntentableLink.Intent { get }
//}
//
//public extension IntentableLink {
//    public enum Intent {
//        case item(id: String)
//        case showContent(id: String, parentId: String)
//        case showPromos(id: String, parentId: String)
//        case showSettings
//        case showLogin
//        case showTermsConditions
//        case showLegal
//    }
//}
//
//public struct RegularLink: AuthorizableLink, IntentableLink {
//    public var intent: IntentableLink.Intent
//    public var authorization: AuthorizableLink.Authorization
//    
//    init(intent: Intent, authorization: AuthorizableLink.Authorization = .none) {
//        self.intent = intent
//        self.authorization = authorization
//    }
//}
//
//public struct AuthorizedLink: IntentableLink {
//    var intent: IntentableLink.Intent
//    
//    init(intent: IntentableLink.Intent) {
//        self.intent = intent
//    }
//}

