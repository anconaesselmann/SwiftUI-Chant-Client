//  Created by Axel Ancona Esselmann on 8/21/21.
//

import Foundation

extension String {

    enum Padding {
        case left
        case right
    }

    func padded(with padingChar: String, lentgh: Int, padding: Padding = .left) -> String? {
        guard padingChar.count == 1, count < lentgh else {
            return nil
        }
        let paddingString = String(Array(repeating: padingChar, count: lentgh - count).joined())
        switch padding {
        case .left: return paddingString + self
        case .right: return self + paddingString
        }
    }
}
