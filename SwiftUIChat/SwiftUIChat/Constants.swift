//  Created by Axel Ancona Esselmann on 8/17/21.
//

import Foundation

struct Constants {
    static let socketUrlString = URL(string: "127.0.0.1")!
//    static let socketUrlString = URL(string: "135.180.65.243")!
    static let socketPort: UInt32 = 20212
}

import SwiftUI

extension Color {
    static let sentMessageBackground = Color(UIColor(named: "SentMessageBackground")!)
    static let backgroundShaddow = Color(UIColor(named: "BackgroundShaddow")!)
    static let receivedMessageBackground = Color(UIColor(named: "ReceivedMessageBackground")!)

    static let textOnBackground = Color(UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1))
}

extension CGFloat {
    static let extraSmallPadding: CGFloat = 4
    static let smallPadding: CGFloat = 8
    static let mediumPadding: CGFloat = 16
}

enum Shadows {
    case background

    var shadow: ShowdowModifier.Shadow {
        switch self {
        case .background:
            return ShowdowModifier.Shadow(
                color: Color.backgroundShaddow,
                radius: 6,
                x: 0,
                y: 0)
        }
    }
}
