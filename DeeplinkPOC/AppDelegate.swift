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
        //TODO: Handle cold-open linking
        return true
    }

    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        linkDispatcher.handle(userActivity)
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        linkDispatcher.handle(url)
        return true
    }
}

extension AppDelegate: LinkDispatcherDelegate {
    var loadingViewController: LoadingViewController? {
        return window?.rootViewController as? LoadingViewController
    }
    
    func willStartLinking() {
        // Do anything needed to reset the app to common DL startpoint
        loadingViewController?.dismiss(animated: false, completion: nil)
    }
    
    func link(with link: Link) {
        // Start deeplinking process
        window?.rootViewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateInitialViewController()
        loadingViewController?.open(link: link, animated: true)
    }
}

