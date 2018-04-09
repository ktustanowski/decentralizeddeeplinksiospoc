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
linker.handle(URL(string: "dlpoc://Settings")!)



PlaygroundPage.current.needsIndefiniteExecution = true
//: [Next](@next)
