//: [Previous](@previous)

import Foundation

let url = URL(string: "dlpoc://Item/2/Content/3")!


let components = url.pathComponents.filter{ $0 != "/"}
let parentName = url.host! + " " + components.first!
let childName = parentName + " " + components[1] + " " + components.last!

//print(error.localizedDescription)
//: [Next](@next)
