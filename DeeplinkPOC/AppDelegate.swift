//
//  AppDelegate.swift
//  DeeplinkPOC
//
//  Created by Kamil Tustanowski on 30.03.2018.
//  Copyright © 2018 ktustanowski. All rights reserved.
//

import UIKit
import LinkHandler

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    private lazy var linkDispatcher: LinkDispatcher = {
        return LinkDispatcher(delegate: self)
    }()
    
    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        //TODO: check for any stuff - app might be opened directly
        return true
    }

    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        print("tried to continue")
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        print("\(url)")
        linkDispatcher.handle(url)
        return true
    }
}

extension AppDelegate: LinkDispatcherDelegate {
    var loadingViewController: LoadingViewController? {
        return window?.rootViewController as? LoadingViewController
    }
    
    func willStartLinking() {
        loadingViewController?.dismiss(animated: false, completion: nil)
        
    }
    
    func link(with link: Link) {
        window?.rootViewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateInitialViewController()
        loadingViewController?.open(link: link, animated: true)
    }
}

