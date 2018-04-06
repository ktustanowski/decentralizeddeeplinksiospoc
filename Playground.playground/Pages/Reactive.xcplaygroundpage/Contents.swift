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

//let homeDataProducer = SignalProducer<Bool, NoError> {observer, _ in
//    dispatchAfter(1.0) {
//        observer.send(value: true)
//        observer.sendCompleted()
//    }
//}//.logEvents(identifier: "HP")
//
//let newRequirementProducer = SignalProducer<Bool, NoError> {observer, _ in
//    dispatchAfter(3.0) {
//        observer.send(value: false)
//        observer.sendCompleted()
//    }
//    }//.logEvents(identifier: "NEW")
//
//let newestRequirementProducer = SignalProducer<Bool, NoError> {observer, _ in
//    dispatchAfter(3.5) {
//        observer.send(value: false)
//        observer.sendCompleted()
//    }
//    }//.logEvents(identifier: "NEWEST")
//
//let universalLinkActivity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
//
//let linkParserProducer = LinkFactory.make(with: URL(string: "http://www.o2.pl?sso=go")!)
//    .skipNil()
//    .take(first: 1)
//    .logEvents(identifier: "LPP")
//
//
//// UL LinkFactory.make(with: universalLinkActivity)
//// URL LinkFactory.make(with: URL(string: "http://www.o2.pl")!)
//
//let x = linkParserProducer.flatMap(.latest) { link in
//    SignalProducer.zip(homeDataProducer,
//                       SingleSignOn.login(using: link),
//                       newRequirementProducer,
//                       newestRequirementProducer,
//                       SignalProducer.init(value: link))
//    }.startWithResult { result in
//        switch result {
//        case .success(let (isHomeLoaded, ssoLoginStatus, newFeature, newestFeature, link)):
//            print("GOT: home loaded: \(isHomeLoaded), sso authenticated: \(ssoLoginStatus), new requirement: \(newFeature), newest requirement: \(newestFeature) link: \(link)")
//        //TODO: Handle appropriately
//        case .failure(let error):
//            print("GOT: \(error)")
//        }
//        //TODO: start navigation here based on outcome
//}

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
linker.handle(URL(string: "dlpoc://Item/2/Content/3?sso=go")!)



PlaygroundPage.current.needsIndefiniteExecution = true
//: [Next](@next)
