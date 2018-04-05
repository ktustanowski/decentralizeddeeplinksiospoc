//: Playground - noun: a place where people can play

import UIKit
import ReactiveSwift
import Result
import CoreSpotlight

struct Linker {

    func handle(_ userActivity: NSUserActivity) {
        startFlow(with: SignalProducer{ observer, _ in
            guard let link = LinkFactory.make(with: userActivity) else {
                observer.send(error: .unrecognized)
                return
            }

            observer.send(value: link)
            observer.sendCompleted()
        })
    }

    func handle(_ url: URL) {
        startFlow(with: SignalProducer<Link, LinkParserError> { observer, _ in
            guard let link = LinkFactory.make(with: url) else {
                observer.send(error: .unrecognized)
                return
            }

            observer.send(value: link)
            observer.sendCompleted()
        })
    }

    private func startFlow(with linkProducer: SignalProducer<Link, LinkParserError>) {
        linkProducer.flatMap(.latest) { link -> SignalProducerConvertible in
            return SignalProducer { observer, _ in
                print(link)
                observer.sendCompleted()
            }
        }
    }
}

let deepLinker = Linker()


let forceTouchActivity = NSUserActivity(activityType: "ForceTouchType")
let universalLinkActivity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)

deepLinker.handle(forceTouchActivity)

deepLinker.handle(universalLinkActivity)
deepLinker.handle(URL(string: "http://www.o2.pl")!)



