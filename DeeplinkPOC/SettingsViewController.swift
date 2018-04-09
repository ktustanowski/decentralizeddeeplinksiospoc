//
//  SettingsViewController.swift
//  DeeplinkPOC
//
//  Created by Kamil Tustanowski on 04.04.2018.
//  Copyright © 2018 ktustanowski. All rights reserved.
//

import UIKit
import LinkHandler

class SettingsViewController: UIViewController {
    var linkHandling: LinkHandling?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        completeLinking()
    }
}

extension SettingsViewController: LinkHandler {
    func process(link: Link, animated: Bool) -> LinkHandling {
        guard isViewLoaded else { return .delayed(link, animated) }
        
        switch link.intent {
        case .showLogin:
            performSegue(withIdentifier: "ToLogin", sender: link)
            return .passedThrough(link)
        case .showTermsConditions:
            performSegue(withIdentifier: "ToTermsConditions", sender: link)
            return .passedThrough(link)
        case .showLegal:
            performSegue(withIdentifier: "ToLegal", sender: link)
            return .passedThrough(link)
        default:
            return .rejected(link, "Unsupported link")
        }
    }
}
