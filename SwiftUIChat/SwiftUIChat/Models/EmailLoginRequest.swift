//  Created by Axel Ancona Esselmann on 8/20/21.
//

import Foundation

enum Padding {
    case left
    case right
}

func padd(_ string: String, with padingChar: String, lentgh: Int, padding: Padding = .left) -> String? {
    guard padingChar.count == 1, string.count < lentgh else {
        return nil
    }
    let paddingString = String(Array(repeating: padingChar, count: lentgh - string.count).joined())
    switch padding {
    case .left: return paddingString + string
    case .right: return string + paddingString
    }
}
