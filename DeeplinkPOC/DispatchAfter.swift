//
//  DispatchAfter.swift
//  DeeplinkPOC
//
//  Created by Kamil Tustanowski on 05.04.2018.
//  Copyright © 2018 ktustanowski. All rights reserved.
//

import Foundation

public func dispatchAfter(_ delay: Double, closure: @escaping () -> ()) {
    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
        closure()
    }
}
