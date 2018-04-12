//: [Previous](@previous)

import UIKit
import ReactiveSwift
import Result
import PlaygroundSupport
import CoreSpotlight
import LinkHandler

func dispatchAfter(_ delay: Double, closure: @escaping () -> ()) {
    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
        closure()
    }
}

struct LinkerDelegate: LinkDispatcherDelegate {
    func willStartLinking() {
        print("Reset to loading screen")
    }
    
    func link(with link: Link) {
        print("Got: \(link)")
    }
}


let linkerDelegate = LinkerDelegate()
let linker = LinkDispatcher(delegate: linkerDelegate)
//let activity = NSUserActivity(activityType: "invalid")
//linker.handle(activity)
//linker.handle(URL(string: "dlpoc://Item/1")!)
//linker.handle(["some": ""])
//let activity = NSUserActivity(activityType: "poc.dl.spotlight.items")
//activity.title = "Item 5"
//let linkTitle = "Item 5".components(separatedBy: " ").joined(separator: "/")
//activity.userInfo = ["deeplinkURL": URL(string: "dlpoc://\(linkTitle)")]
//activity.isEligibleForSearch = true
//linker.handle(activity)

let shortcut = UIApplicationShortcutItem(type: "poc.dl.shortcut.recent",
                                         localizedTitle: "Show Recent",
                                         localizedSubtitle: "Navigate to recently accessed item",
                                         icon: nil,
                                         userInfo: nil)

linker.handle(shortcut)


PlaygroundPage.current.needsIndefiniteExecution = true
//: [Next](@next)
